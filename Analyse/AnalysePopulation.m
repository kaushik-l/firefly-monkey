function stats = AnalysePopulation(units,trials_behv,behv_stats,prs)

nunits = length(units);
regress_popreadout = prs.regress_popreadout;
fit_GAMcoupled = prs.fit_GAMcoupled;
dt = prs.dt; % sampling resolution (s)
temporal_binwidth = prs.temporal_binwidth; % binwidth to use for analysis

%% load cases
trialtypes = fields(behv_stats.trialtype);
events = cell2mat({trials_behv.events});
continuous = cell2mat({trials_behv.continuous});

stats = [];
%% fit GAM with cross-neuronal coupling
if fit_GAMcoupled
    GAM_prs.varname = prs.GAM_varname; varname = GAM_prs.varname;
    GAM_prs.vartype = prs.GAM_vartype;
    GAM_prs.nbins = prs.GAM_nbins;
    GAM_prs.binrange = [];
    GAM_prs.nfolds = prs.nfolds;
    GAM_prs.dt = dt;
    GAM_prs.filtwidth = 3; %prs.neuralfiltwidth;
    GAM_prs.linkfunc = prs.GAM_linkfunc;
    GAM_prs.lambda = prs.GAM_lambda;
    GAM_prs.alpha = prs.GAM_alpha;
    for i=1% if i=1, fit model using data from all trials rather than separately to data from each condition
        nconds = length(behv_stats.trialtype.(trialtypes{i}));
        if ~strcmp((trialtypes{i}),'all') && nconds==1, copystats = true; else, copystats = false; end % only one condition means variable was not manipulated
        fprintf(['.........fitting GAM model :: trialtype: ' (trialtypes{i}) '\n']);
        for j=1:nconds
            if copystats % if only one condition present, no need to recompute stats --- simply copy them from 'all' trials
                stats.trialtype.(trialtypes{i})(j).models.(GAM_prs.linkfunc) = stats.trialtype.all.models.(GAM_prs.linkfunc);
            else
                trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
                events_temp = events(trlindx);
                continuous_temp = continuous(trlindx);
                %% select variables of interest and load their details
                vars = cell(length(varname),1);
                GAM_prs.binrange = cell(1,length(varname));
                for k=1:length(varname)
                    if isfield(continuous_temp,varname(k)), vars{k} = {continuous_temp.(varname{k})};
                    elseif isfield(behv_stats.pos_rel,varname(k)), vars{k} = behv_stats.pos_rel.(varname{k})(trlindx);
                    elseif strcmp(varname(k),'d')
                        vars{k} = cellfun(@(x,y) [zeros(sum(y<=0),1) ; cumsum(x(y>0)*dt)],{continuous_temp.v},{continuous_temp.ts},'UniformOutput',false);
                    elseif strcmp(varname(k),'phi')
                        vars{k} = cellfun(@(x,y) [zeros(sum(y<=0),1) ; cumsum(x(y>0)*dt)],{continuous_temp.w},{continuous_temp.ts},'UniformOutput',false);
                    end
                    GAM_prs.binrange{k} = prs.binrange.(varname{k});
                end
                %% define time windows for computing tuning
                timewindow_path = [[events_temp.t_targ]' [events_temp.t_stop]']; % when the subject is integrating path
                %% concatenate stimulus data from all trials
                trials_spks_temp = units(1).trials(trlindx);
                xt = [];
                for k=1:length(vars)
                    xt(:,k) = ConcatenateTrials(vars{k},{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path);
                end
                %% concatenate units
                Yt = zeros(size(xt,1),nunits);
                for k=1:nunits
                    trials_spks_temp = units(k).trials(trlindx);
                    [~,Yt(:,k)] = ConcatenateTrials(vars{1},{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path);
                end
                %% fit fully coupled GAM model to each unit
                xt = mat2cell(xt,size(xt,1),ones(1,size(xt,2))); % convert to cell
                for k=1:nunits
                    models = BuildGAMCoupled(xt,Yt(:,k),Yt(:,[1:k-1 k+1:nunits]),GAM_prs);
                    stats.trialtype.(trialtypes{i})(j).models.(GAM_prs.linkfunc).units(k) = models;
                end
            end
        end
    end
end

%% cannonical correlation analysis
if compute_canoncorr

    for i=1% if i=1, fit model using data from all trials rather than separately to data from each condition
        nconds = length(behv_stats.trialtype.(trialtypes{i}));
        if ~strcmp((trialtypes{i}),'all') && nconds==1, copystats = true; else, copystats = false; end % only one condition means variable was not manipulated
        fprintf(['.........fitting GAM model :: trialtype: ' (trialtypes{i}) '\n']);
        for j=1:nconds
            if copystats % if only one condition present, no need to recompute stats --- simply copy them from 'all' trials
                stats.trialtype.(trialtypes{i})(j).models.(GAM_prs.linkfunc) = stats.trialtype.all.models.(GAM_prs.linkfunc);
            else
                trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
                events_temp = events(trlindx);
                continuous_temp = continuous(trlindx);
                %% select variables of interest and load their details
                vars = cell(length(varname),1);
                GAM_prs.binrange = cell(1,length(varname));
                for k=1:length(varname)
                    if isfield(continuous_temp,varname(k)), vars{k} = {continuous_temp.(varname{k})};
                    elseif isfield(behv_stats.pos_rel,varname(k)), vars{k} = behv_stats.pos_rel.(varname{k})(trlindx);
                    elseif strcmp(varname(k),'d')
                        vars{k} = cellfun(@(x,y) [zeros(sum(y<=0),1) ; cumsum(x(y>0)*dt)],{continuous_temp.v},{continuous_temp.ts},'UniformOutput',false);
                    elseif strcmp(varname(k),'phi')
                        vars{k} = cellfun(@(x,y) [zeros(sum(y<=0),1) ; cumsum(x(y>0)*dt)],{continuous_temp.w},{continuous_temp.ts},'UniformOutput',false);
                    end
                    GAM_prs.binrange{k} = prs.binrange.(varname{k});
                end
                %% define time windows for computing tuning
                timewindow_path = [[events_temp.t_targ]' [events_temp.t_stop]']; % when the subject is integrating path
                %% concatenate stimulus data from all trials
                trials_spks_temp = units(1).trials(trlindx);
                xt = [];
                for k=1:length(vars)
                    xt(:,k) = ConcatenateTrials(vars{k},{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path);
                end
                %% concatenate units
                Yt = zeros(size(xt,1),nunits);
                for k=1:nunits
                    trials_spks_temp = units(k).trials(trlindx);
                    [~,Yt(:,k)] = ConcatenateTrials(vars{1},{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path);
                end
                %% fit fully coupled GAM model to each unit
                xt = mat2cell(xt,size(xt,1),ones(1,size(xt,2))); % convert to cell
                for k=1:nunits
                    models = BuildGAMCoupled(xt,Yt(:,k),Yt(:,[1:k-1 k+1:nunits]),GAM_prs);
                    stats.trialtype.(trialtypes{i})(j).models.(GAM_prs.linkfunc).units(k) = models;
                end
            end
        end
    end
end

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