function [trials_spks,stats] = AnalyseRates(trials_spks,trials_behv,behv_stats,prs)

%% load analysis params
x0 = prs.x0; y0 = prs.y0; % position of the subject at trial onset
dt = prs.dt; % sampling resolution (s)
temporal_binwidth = prs.temporal_binwidth;
corr_lag = prs.corr_lag;
duration_zeropad = prs.duration_zeropad;
bootstrap_trl = prs.bootstrap_trl;
peaktimewindow = prs.peaktimewindow;
minpeakprominence = prs.minpeakprominence;

%% load cases
trialtypes = fields(behv_stats.trialtype);
events = cell2mat({trials_behv.events});
continuous = cell2mat({trials_behv.continuous});

%% event-aligned, trial-averaged firing rates
for i=1:length(trialtypes)
    nconds = length(behv_stats.trialtype.(trialtypes{i}));
    for j=1:nconds
        trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
        events_temp = events(trlindx);
        trials_spks_temp = trials_spks(trlindx);
        %% aligned to movement onset
        trials_spks_temp2 = ShiftSpikes(trials_spks_temp,[events_temp.t_move]);
        [nspk,ts] = Spiketimes2Rate(trials_spks_temp2,prs.ts.movementaligned,temporal_binwidth);
        stats.trialtype.(trialtypes{i})(j).events.move.rate = nspk;
        stats.trialtype.(trialtypes{i})(j).events.move.time = ts;
        stats.trialtype.(trialtypes{i})(j).events.move.peakresp = ...           % significance of peak response
            EvaluatePeakresponse(trials_spks_temp2,prs.ts.movementaligned,temporal_binwidth,peaktimewindow,minpeakprominence,bootstrap_trl);
        %% aligned to target onset
        trials_spks_temp2 = ShiftSpikes(trials_spks_temp,[events_temp.t_beg]-[events_temp.t_beg]);
        [nspk,ts] = Spiketimes2Rate(trials_spks_temp2,prs.ts.targetaligned,temporal_binwidth);
        stats.trialtype.(trialtypes{i})(j).events.target.rate = nspk;
        stats.trialtype.(trialtypes{i})(j).events.target.time = ts;
        stats.trialtype.(trialtypes{i})(j).events.target.peakresp = ...         % significance of peak response
            EvaluatePeakresponse(trials_spks_temp2,prs.ts.targetaligned,temporal_binwidth,peaktimewindow,minpeakprominence,bootstrap_trl);
        %% aligned to movement stop
        trials_spks_temp2 = ShiftSpikes(trials_spks_temp,[events_temp.t_stop]);
        [nspk,ts] = Spiketimes2Rate(trials_spks_temp2,prs.ts.stopaligned,temporal_binwidth);
        stats.trialtype.(trialtypes{i})(j).events.stop.rate = nspk;
        stats.trialtype.(trialtypes{i})(j).events.stop.time = ts;
        stats.trialtype.(trialtypes{i})(j).events.stop.peakresp = ...           % significance of peak response
            EvaluatePeakresponse(trials_spks_temp2,prs.ts.stopaligned,temporal_binwidth,peaktimewindow,minpeakprominence,bootstrap_trl);
        %% aligned to reward
        trials_spks_temp2 = ShiftSpikes(trials_spks_temp,[events_temp.t_rew]);
        [nspk,ts] = Spiketimes2Rate(trials_spks_temp2,prs.ts.rewardaligned,temporal_binwidth);
        stats.trialtype.(trialtypes{i})(j).events.reward.rate = nspk;
        stats.trialtype.(trialtypes{i})(j).events.reward.time = ts;
        stats.trialtype.(trialtypes{i})(j).events.reward.peakresp = ...         % significance of peak response
            EvaluatePeakresponse(trials_spks_temp2,prs.ts.rewardaligned,temporal_binwidth,peaktimewindow,minpeakprominence,bootstrap_trl);
    end
end

%% cross-correlation and tuning to continuous variables
for i=1:length(trialtypes)
    nconds = length(behv_stats.trialtype.(trialtypes{i}));
    for j=1:nconds
        trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
        events_temp = events(trlindx);
        continuous_temp = continuous(trlindx);
        trials_spks_temp = trials_spks(trlindx);
        %% define time window for tuning
        timewindow(:,1) = [events_temp.t_move]'; timewindow(:,2) = [events_temp.t_stop]'; % when the subject is moving
        %% linear velocity
        stats.trialtype.(trialtypes{i})(j).continuous.v = ...
            ComputeTuning({continuous_temp.v},{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.v,bootstrap_trl);
        %% angular velocity
        stats.trialtype.(trialtypes{i})(j).continuous.w = ...
            ComputeTuning({continuous_temp.w},{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.w,bootstrap_trl);
        %% linear acceleration
        a = cellfun(@(x) diff(x)/dt,{continuous_temp.v},'UniformOutput',false);
        a_ts = cellfun(@(x) x(2:end),{continuous_temp.ts},'UniformOutput',false);
        stats.trialtype.(trialtypes{i})(j).continuous.a = ...
            ComputeTuning(a,a_ts,{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.a,bootstrap_trl);
        %% angular acceleration
        alpha = cellfun(@(x) diff(x)/dt,{continuous_temp.w},'UniformOutput',false);
        alpha_ts = cellfun(@(x) x(2:end),{continuous_temp.ts},'UniformOutput',false);
        stats.trialtype.(trialtypes{i})(j).continuous.alpha = ...
            ComputeTuning(alpha,alpha_ts,{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.alpha,bootstrap_trl);
        %% magnitude of linear velocity
        v_abs = cellfun(@abs,{continuous_temp.v},'UniformOutput',false);
        stats.trialtype.(trialtypes{i})(j).continuous.v_abs = ...
            ComputeTuning(v_abs,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.v_abs,bootstrap_trl);
        %% magnitude of angular velocity
        w_abs = cellfun(@abs,{continuous_temp.w},'UniformOutput',false);
        stats.trialtype.(trialtypes{i})(j).continuous.w_abs = ...
            ComputeTuning(w_abs,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.w_abs,bootstrap_trl);
        %% magnitude of linear acceleration
        a_abs = cellfun(@(x) abs(diff(x)/dt),{continuous_temp.v},'UniformOutput',false);
        a_abs_ts = cellfun(@(x) x(2:end),{continuous_temp.ts},'UniformOutput',false);
        stats.trialtype.(trialtypes{i})(j).continuous.a_abs = ...
            ComputeTuning(a_abs,a_abs_ts,{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.a_abs,bootstrap_trl);
        %% magnitude of angular acceleration
        alpha_abs = cellfun(@(x) abs(diff(x)/dt),{continuous_temp.w},'UniformOutput',false);
        alpha_abs_ts = cellfun(@(x) x(2:end),{continuous_temp.ts},'UniformOutput',false);
        stats.trialtype.(trialtypes{i})(j).continuous.alpha_abs = ...
            ComputeTuning(alpha_abs,alpha_abs_ts,{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.alpha_abs,bootstrap_trl);
        %% horizontal eye position
        heye = cellfun(@(x,y) nanmean([x(:)' ; y(:)']),{continuous_temp.yle},{continuous_temp.yre},'UniformOutput',false); % average both eyes (if available)
        stats.trialtype.(trialtypes{i})(j).continuous.heye = ...
            ComputeTuning(heye,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.heye,bootstrap_trl);
        %% vertical eye position
        veye = cellfun(@(x,y) nanmean([x(:)' ; y(:)']),{continuous_temp.zle},{continuous_temp.zre},'UniformOutput',false); % average both eyes (if available)
        stats.trialtype.(trialtypes{i})(j).continuous.veye = ...
            ComputeTuning(veye,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.veye,bootstrap_trl);
        %% define time window for tuning (refine this -- use t_targ instead of 0?)
        timewindow(:,2) = [events_temp.t_stop]'; timewindow(:,1) = 0; % when the subject is integrating path
        %% displacement
        r = cellfun(@(x,y) sqrt((x(:)-x0).^2 + (y(:)-y0).^2),{continuous_temp.xmp},{continuous_temp.ymp},'UniformOutput',false);
        stats.trialtype.(trialtypes{i})(j).continuous.r = ...
            ComputeTuning(r,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.r,bootstrap_trl);
        %% bearing
        theta = cellfun(@(x,y) atan2d(x(:)-x0,y(:)-y0),{continuous_temp.xmp},{continuous_temp.ymp},'UniformOutput',false);
        stats.trialtype.(trialtypes{i})(j).continuous.theta = ...
            ComputeTuning(theta,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.theta,bootstrap_trl);
        %% distance (refine -- use t_targ instead of 0?)
        d = cellfun(@(x,y) [zeros(1,sum(y<=0)) cumsum(x(y>0)*dt)'],{continuous_temp.v},{continuous_temp.ts},'UniformOutput',false);
        stats.trialtype.(trialtypes{i})(j).continuous.d = ...
            ComputeTuning(d,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.d,bootstrap_trl);
        %% heading
        phi = cellfun(@(x,y) [zeros(1,sum(y<=0)) cumsum(x(y>0)*dt)'],{continuous_temp.w},{continuous_temp.ts},'UniformOutput',false);
        stats.trialtype.(trialtypes{i})(j).continuous.phi = ...
            ComputeTuning(phi,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.phi,bootstrap_trl);
        %% distance to target
        dist2fly = behv_stats.pos_rel.r_fly(trlindx);
        stats.trialtype.(trialtypes{i})(j).continuous.dist2fly = ...
            ComputeTuning(dist2fly,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.dist2fly,bootstrap_trl);
        %% distance to stop
        dist2stop = behv_stats.pos_rel.r_stop(trlindx);
        stats.trialtype.(trialtypes{i})(j).continuous.dist2stop = ...
            ComputeTuning(dist2stop,{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.dist2stop,bootstrap_trl);
        %% 
        y=1;
    end
end