function stats = AnalysePopulation(units,trials_behv,behv_stats,prs)

regress_popreadout = prs.regress_popreadout;
dt = prs.dt; % sampling resolution (s)
temporal_binwidth = prs.temporal_binwidth; % binwidth to use for analysis

%% load cases
trialtypes = fields(behv_stats.trialtype);
events = cell2mat({trials_behv.events});
continuous = cell2mat({trials_behv.continuous});

%% compute population readout weights via ordinary-least-squares
if regress_popreadout
    getreadout = prs.popreadout_continuous;
    prs.popreadout_continuous = {'d','phi'};
    GD_alpha = prs.GD_alpha;
    GD_niters = prs.GD_niters;
    GD_featurescale = prs.GD_featurescale;
    GD_modelname = prs.GD_modelname;
    neuralfiltwidth = prs.neuralfiltwidth;
    for i=1 % i=1 means compute only for all trials together
        nconds = length(behv_stats.trialtype.(trialtypes{i}));
        for j=1:nconds
            trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
            events_temp = events(trlindx);
            timewindow_move = [[events_temp.t_move]' [events_temp.t_stop]']; % only consider data when the subject is integrating path
            timewindow_path = [[events_temp.t_targ]' [events_temp.t_stop]']; % only consider data when the subject is integrating path
            continuous_temp = continuous(trlindx);
            nunits = length(units);
            %% linear velocity, v
            if any(strcmp(getreadout,'v'))
                xt = []; Yt = [];
                for k=1:nunits
                    trials_spks_temp = units(k).trials(trlindx);
                    [xt,Yt(:,k)] = ConcatenateTrials({continuous_temp.v},{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_move);
                end                
                Yt = SmoothSpikes(Yt, neuralfiltwidth); % smooth spiketrains before fitting model
                [stats.(GD_modelname).v.theta, J] = GradientDescent(Yt, xt, GD_alpha, GD_niters, GD_featurescale, GD_modelname); % Init weights (theta) and run Gradient Descent
            end
            %% distance to target, r_targ
            if any(strcmp(getreadout,'r_targ'))
                xt = []; Yt = [];
                r_targ = behv_stats.pos_rel.r_targ(trlindx);
                for k=1:nunits
                    trials_spks_temp = units(k).trials(trlindx);
                    [xt,Yt(:,k)] = ConcatenateTrials(r_targ,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path);
                end
                Yt = SmoothSpikes(Yt, neuralfiltwidth); % smooth spiketrains before fitting model
                [stats.(GD_modelname).r_targ.theta, J] = GradientDescent(Yt, xt, GD_alpha, GD_niters, GD_featurescale, GD_modelname); % Init weights (theta) and run Gradient Descent
            end
            %% distance, d
            if any(strcmp(getreadout,'d'))
                xt = []; Yt = [];
                d = cellfun(@(x,y) [zeros(sum(y<=0),1) ; cumsum(x(y>0)*dt)],{continuous_temp.v},{continuous_temp.ts},'UniformOutput',false);
                for k=1:nunits
                    trials_spks_temp = units(k).trials(trlindx);
                    [xt,Yt(:,k)] = ConcatenateTrials(d,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path);
                end
                Yt = SmoothSpikes(Yt, neuralfiltwidth); % smooth spiketrains before fitting model
                [stats.(GD_modelname).d.theta, J] = GradientDescent(Yt, xt, GD_alpha, GD_niters, GD_featurescale, GD_modelname); % Init weights (theta) and run Gradient Descent
            end
            %% heading, phi
            if any(strcmp(getreadout,'phi'))
                xt = []; Yt = [];
                phi = cellfun(@(x,y) [zeros(sum(y<=0),1) ; cumsum(x(y>0)*dt)],{continuous_temp.w},{continuous_temp.ts},'UniformOutput',false);
                for k=1:nunits
                    trials_spks_temp = units(k).trials(trlindx);
                    [xt,Yt(:,k)] = ConcatenateTrials(phi,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path);
                end
                Yt = SmoothSpikes(Yt, neuralfiltwidth); % smooth spiketrains before fitting model
                [stats.(GD_modelname).phi.theta, J] = GradientDescent(Yt, xt, GD_alpha, GD_niters, GD_featurescale, GD_modelname); % Init weights (theta) and run Gradient Descent
            end
        end
    end
end