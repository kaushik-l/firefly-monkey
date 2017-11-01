function stats = AnalyseRates(trials_spks,trials_behv,behv_stats,prs)

%% load analysis params
x0 = prs.x0; y0 = prs.y0; % position of the subject at trial onset
dt = prs.dt; % sampling resolution (s)
temporal_binwidth = prs.temporal_binwidth;
corr_lag = prs.corr_lag;
duration_zeropad = prs.duration_zeropad;
nbootstraps = prs.nbootstraps;
peaktimewindow = prs.peaktimewindow;
minpeakprominence = prs.minpeakprominence;
mintrialsforstats = prs.mintrialsforstats;

%% load cases
trialtypes = fields(behv_stats.trialtype);
events = cell2mat({trials_behv.events});
continuous = cell2mat({trials_behv.continuous});

%% event-aligned, trial-averaged firing rates
gettuning = prs.tuning_events;
for i=1:length(trialtypes)
    nconds = length(behv_stats.trialtype.(trialtypes{i}));
    for j=1:nconds
        trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
        events_temp = events(trlindx);
        trials_spks_temp = trials_spks(trlindx);
        %% aligned to movement onset
        if any(strcmp(gettuning,'move'))
            trials_spks_temp2 = ShiftSpikes(trials_spks_temp,[events_temp.t_move]);
            [nspk,ts] = Spiketimes2Rate(trials_spks_temp2,prs.ts.move,temporal_binwidth);
            stats.trialtype.(trialtypes{i})(j).events.move.rate = nspk;
            stats.trialtype.(trialtypes{i})(j).events.move.time = ts;
            stats.trialtype.(trialtypes{i})(j).events.move.peakresp = ...           % significance of peak response
                EvaluatePeakresponse(trials_spks_temp2,prs.ts.move,temporal_binwidth,peaktimewindow,minpeakprominence,nbootstraps,mintrialsforstats);
        end
        %% aligned to target onset
        if any(strcmp(gettuning,'target'))
            trials_spks_temp2 = ShiftSpikes(trials_spks_temp,[events_temp.t_beg]-[events_temp.t_beg]);
            [nspk,ts] = Spiketimes2Rate(trials_spks_temp2,prs.ts.target,temporal_binwidth);
            stats.trialtype.(trialtypes{i})(j).events.target.rate = nspk;
            stats.trialtype.(trialtypes{i})(j).events.target.time = ts;
            stats.trialtype.(trialtypes{i})(j).events.target.peakresp = ...         % significance of peak response
                EvaluatePeakresponse(trials_spks_temp2,prs.ts.target,temporal_binwidth,peaktimewindow,minpeakprominence,nbootstraps,mintrialsforstats);
        end
        %% aligned to movement stop
        if any(strcmp(gettuning,'stop'))
            trials_spks_temp2 = ShiftSpikes(trials_spks_temp,[events_temp.t_stop]);
            [nspk,ts] = Spiketimes2Rate(trials_spks_temp2,prs.ts.stop,temporal_binwidth);
            stats.trialtype.(trialtypes{i})(j).events.stop.rate = nspk;
            stats.trialtype.(trialtypes{i})(j).events.stop.time = ts;
            stats.trialtype.(trialtypes{i})(j).events.stop.peakresp = ...           % significance of peak response
                EvaluatePeakresponse(trials_spks_temp2,prs.ts.stop,temporal_binwidth,peaktimewindow,minpeakprominence,nbootstraps,mintrialsforstats);
        end
        %% aligned to reward
        if any(strcmp(gettuning,'reward'))
            trials_spks_temp2 = ShiftSpikes(trials_spks_temp,[events_temp.t_rew]);
            [nspk,ts] = Spiketimes2Rate(trials_spks_temp2,prs.ts.reward,temporal_binwidth);
            stats.trialtype.(trialtypes{i})(j).events.reward.rate = nspk;
            stats.trialtype.(trialtypes{i})(j).events.reward.time = ts;
            stats.trialtype.(trialtypes{i})(j).events.reward.peakresp = ...         % significance of peak response
                EvaluatePeakresponse(trials_spks_temp2,prs.ts.reward,temporal_binwidth,peaktimewindow,minpeakprominence,nbootstraps,mintrialsforstats);
        end
    end
end

%% cross-correlation and tuning to continuous variables
gettuning = prs.tuning_continuous;
for i=1 % compute tuning curves using all trials, rather than separately for each condition
    nconds = length(behv_stats.trialtype.(trialtypes{i}));
    if ~strcmp((trialtypes{i}),'all') && nconds==1, copystats = true; else, copystats = false; end % only one condition means variable was not manipulated
    fprintf(['.........estimating tuning curves :: trialtype: ' (trialtypes{i}) '\n']);
    for j=1:nconds
        if copystats % if only one condition present, no need to recompute stats --- simply copy them from 'all' trials
            for k=1:length(gettuning)
                stats.trialtype.(trialtypes{i})(j).continuous.(gettuning{k}) = stats.trialtype.all.continuous.(gettuning{k});
            end
        else
            trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
            events_temp = events(trlindx);
            continuous_temp = continuous(trlindx);
            trials_spks_temp = trials_spks(trlindx);
            %% define time windows for computing tuning
            timewindow_move = [[events_temp.t_move]' [events_temp.t_stop]']; % when the subject is moving
            timewindow_path = [[events_temp.t_targ]' [events_temp.t_stop]']; % when the subject is integrating path
            timewindow_full = [[events_temp.t_move]' [events_temp.t_end]']; % from movement onset to end of trial
            %% linear velocity, v
            if any(strcmp(gettuning,'v'))
                stats.trialtype.(trialtypes{i})(j).continuous.v = ...
                    ComputeTuning({continuous_temp.v},{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% angular velocity, w
            if any(strcmp(gettuning,'w'))
                stats.trialtype.(trialtypes{i})(j).continuous.w = ...
                    ComputeTuning({continuous_temp.w},{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% velocity, vw (two dimensional)
            if any(strcmp(gettuning,'vw'))
                stats.trialtype.(trialtypes{i})(j).continuous.vw = ...
                    ComputeTuning2D({continuous_temp.v},{continuous_temp.w},{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_move,prs.tuning,prs.tuning_method);
            end
            %% linear acceleration, a
            if any(strcmp(gettuning,'a'))
                a = cellfun(@(x) diff(x)/dt,{continuous_temp.v},'UniformOutput',false);
                a_ts = cellfun(@(x) x(2:end),{continuous_temp.ts},'UniformOutput',false);
                stats.trialtype.(trialtypes{i})(j).continuous.a = ...
                    ComputeTuning(a,a_ts,{trials_spks_temp.tspk},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% angular acceleration, alpha
            if any(strcmp(gettuning,'alpha'))
                alpha = cellfun(@(x) diff(x)/dt,{continuous_temp.w},'UniformOutput',false);
                alpha_ts = cellfun(@(x) x(2:end),{continuous_temp.ts},'UniformOutput',false);
                stats.trialtype.(trialtypes{i})(j).continuous.alpha = ...
                    ComputeTuning(alpha,alpha_ts,{trials_spks_temp.tspk},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% acceleration, aalpha (two dimensional)
            if any(strcmp(gettuning,'aalpha'))
                stats.trialtype.(trialtypes{i})(j).continuous.aalpha = ...
                    ComputeTuning2D(a,alpha,a_ts,{trials_spks_temp.tspk},timewindow_move,prs.tuning,prs.tuning_method);
            end
            %% magnitude of linear velocity, |v|
            if any(strcmp(gettuning,'v_abs'))
                v_abs = cellfun(@abs,{continuous_temp.v},'UniformOutput',false);
                stats.trialtype.(trialtypes{i})(j).continuous.v_abs = ...
                    ComputeTuning(v_abs,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% magnitude of angular velocity, |w|
            if any(strcmp(gettuning,'w_abs'))
                w_abs = cellfun(@abs,{continuous_temp.w},'UniformOutput',false);
                stats.trialtype.(trialtypes{i})(j).continuous.w_abs = ...
                    ComputeTuning(w_abs,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% magnitude of linear acceleration, |a|
            if any(strcmp(gettuning,'a_abs'))
                a_abs = cellfun(@(x) abs(diff(x)/dt),{continuous_temp.v},'UniformOutput',false);
                a_abs_ts = cellfun(@(x) x(2:end),{continuous_temp.ts},'UniformOutput',false);
                stats.trialtype.(trialtypes{i})(j).continuous.a_abs = ...
                    ComputeTuning(a_abs,a_abs_ts,{trials_spks_temp.tspk},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% magnitude of angular acceleration, |alpha|
            if any(strcmp(gettuning,'alpha_abs'))
                alpha_abs = cellfun(@(x) abs(diff(x)/dt),{continuous_temp.w},'UniformOutput',false);
                alpha_abs_ts = cellfun(@(x) x(2:end),{continuous_temp.ts},'UniformOutput',false);
                stats.trialtype.(trialtypes{i})(j).continuous.alpha_abs = ...
                    ComputeTuning(alpha_abs,alpha_abs_ts,{trials_spks_temp.tspk},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% vertical eye position, veye
            if any(strcmp(gettuning,'veye'))
                veye = cellfun(@(x,y) nanmean([x(:)' ; y(:)']),{continuous_temp.zle},{continuous_temp.zre},'UniformOutput',false); % average both eyes (if available)
                stats.trialtype.(trialtypes{i})(j).continuous.veye = ...
                    ComputeTuning(veye,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% horizontal eye position, heye
            if any(strcmp(gettuning,'heye'))
                heye = cellfun(@(x,y) nanmean([x(:)' ; y(:)']),{continuous_temp.yle},{continuous_temp.yre},'UniformOutput',false); % average both eyes (if available)
                stats.trialtype.(trialtypes{i})(j).continuous.heye = ...
                    ComputeTuning(heye,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% eye position, vheye (two dimensional)
            if any(strcmp(gettuning,'vheye'))
                stats.trialtype.(trialtypes{i})(j).continuous.vheye = ...
                    ComputeTuning2D(veye,heye,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_move,prs.tuning,prs.tuning_method);
            end
            %% displacement, r
            if any(strcmp(gettuning,'r'))
                r = cellfun(@(x,y) sqrt((x(:)-x0).^2 + (y(:)-y0).^2),{continuous_temp.xmp},{continuous_temp.ymp},'UniformOutput',false);
                stats.trialtype.(trialtypes{i})(j).continuous.r = ...
                    ComputeTuning(r,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% bearing, theta
            if any(strcmp(gettuning,'theta'))
                theta = cellfun(@(x,y) atan2d(x(:)-x0,y(:)-y0),{continuous_temp.xmp},{continuous_temp.ymp},'UniformOutput',false);
                stats.trialtype.(trialtypes{i})(j).continuous.theta = ...
                    ComputeTuning(theta,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% position, rtheta (two dimensional)
            if any(strcmp(gettuning,'rtheta'))
                stats.trialtype.(trialtypes{i})(j).continuous.rtheta = ...
                    ComputeTuning2D(r,theta,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path,prs.tuning,prs.tuning_method);
            end
            %% distance, d (refine -- use t_targ instead of 0?)
            if any(strcmp(gettuning,'d'))
                d = cellfun(@(x,y) [zeros(1,sum(y<=0)) cumsum(x(y>0)*dt)'],{continuous_temp.v},{continuous_temp.ts},'UniformOutput',false);
                stats.trialtype.(trialtypes{i})(j).continuous.d = ...
                    ComputeTuning(d,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% heading, phi
            if any(strcmp(gettuning,'phi'))
                phi = cellfun(@(x,y) [zeros(1,sum(y<=0)) cumsum(x(y>0)*dt)'],{continuous_temp.w},{continuous_temp.ts},'UniformOutput',false);
                stats.trialtype.(trialtypes{i})(j).continuous.phi = ...
                    ComputeTuning(phi,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% path, dphi (two dimensional)
            if any(strcmp(gettuning,'dphi'))
                stats.trialtype.(trialtypes{i})(j).continuous.dphi = ...
                    ComputeTuning2D(d,phi,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path,prs.tuning,prs.tuning_method);
            end
            %% distance to target, r_targ
            if any(strcmp(gettuning,'r_targ'))
                r_targ = behv_stats.pos_rel.r_targ(trlindx);
                stats.trialtype.(trialtypes{i})(j).continuous.r_targ = ...
                    ComputeTuning(r_targ,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
            %% distance to stop, r_stop
            if any(strcmp(gettuning,'r_stop'))
                r_stop = behv_stats.pos_rel.r_stop(trlindx);
                stats.trialtype.(trialtypes{i})(j).continuous.r_stop = ...
                    ComputeTuning(r_stop,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow_path,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            end
        end
    end
end

%% fit LN model
getvars = prs.LNmodel_vars;
for i=1 % fit model using all trials, rather than separately to data from each condition
    trlindx = behv_stats.trialtype.(trialtypes{i}).trlindx;
    events_temp = events(trlindx);
    continuous = continuous(trlindx);
    spks = trials_spks(trlindx);
    %% select variables of interest
    vars = cell(length(getvars),1);
    for j=1:length(getvars)
        if isfield(continuous,getvars(j)), vars{j} = {continuous.(getvars{j})};
        elseif isfield(behv_stats.pos_rel,getvars(j)), vars{j} = behv_stats.pos_rel.(getvars{j})(trlindx); end
        tuning_binedges(j,:) = prs.(getvars{j}).tuning_binedges;
    end
    %% define time windows for computing tuning
    timewindow_move = [[events_temp.t_move]' [events_temp.t_stop]']; % when the subject is moving
    timewindow_path = [[events_temp.t_targ]' [events_temp.t_stop]']; % when the subject is integrating path
    %% fit different model variants
    fprintf('......(1/1) Fitting linear-nonlinear (LN) models\n');
    LNmodels = FitLNmodels(vars,{continuous.ts},{spks.tspk},timewindow_path,tuning_binedges);
    %% find the simplest model that best describes the spike train
    fprintf('......(2/2) Performing forward model selection\n');
    LNmodels.selected_model = SelectLNmodel(LNmodels);
    stats.trialtype.(trialtypes{i}).LNmodels = LNmodels;
    %% plot tuning curves obtained from the model and from binning
    PlotLNmodel(LNmodels,stats.trialtype.(trialtypes{i}).continuous,tuning_binedges);
end

%% time-rescaling index
trlindx = behv_stats.trialtype.all.trlindx;
events_temp = events(trlindx);
trials_spks_temp = trials_spks(trlindx);
[stats.trialtype.all.intrinsic.scalingindex,stats.trialtype.all.intrinsic.lockingindex] = ...
    ComputeScalingindex(trials_spks_temp,events_temp,prs.ts_shortesttrialgroup,temporal_binwidth,prs.ntrialgroups);