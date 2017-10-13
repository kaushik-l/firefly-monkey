function [trials_spks,stats] = AnalyseRates(trials_spks,trials_behv,behv_stats,prs)

%% load analysis params
temporal_binwidth = prs.temporal_binwidth;
corr_lag = prs.corr_lag;
duration_zeropad = prs.duration_zeropad;
bootstrap_trl = prs.bootstrap_trl;
peaktimewindow = prs.peaktimewindow;

%% load cases
trialtypes = fields(behv_stats.trialtype);
events = cell2mat({trials_behv.events});
continuous = cell2mat({trials_behv.continuous});

%% trial-averaged firing rates
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
            EvaluatePeakresponse(trials_spks_temp2,prs.ts.movementaligned,temporal_binwidth,peaktimewindow,bootstrap_trl);
        %% aligned to target onset
        trials_spks_temp2 = ShiftSpikes(trials_spks_temp,[events_temp.t_beg]-[events_temp.t_beg]);
        [nspk,ts] = Spiketimes2Rate(trials_spks_temp2,prs.ts.targetaligned,temporal_binwidth);
        stats.trialtype.(trialtypes{i})(j).events.target.rate = nspk;
        stats.trialtype.(trialtypes{i})(j).events.target.time = ts;
        stats.trialtype.(trialtypes{i})(j).events.target.peakresp = ...         % significance of peak response
            EvaluatePeakresponse(trials_spks_temp2,prs.ts.targetaligned,temporal_binwidth,peaktimewindow,bootstrap_trl);
        %% aligned to movement stop
        trials_spks_temp2 = ShiftSpikes(trials_spks_temp,[events_temp.t_stop]);
        [nspk,ts] = Spiketimes2Rate(trials_spks_temp2,prs.ts.stopaligned,temporal_binwidth);
        stats.trialtype.(trialtypes{i})(j).events.stop.rate = nspk;
        stats.trialtype.(trialtypes{i})(j).events.stop.time = ts;
        stats.trialtype.(trialtypes{i})(j).events.stop.peakresp = ...           % significance of peak response
            EvaluatePeakresponse(trials_spks_temp2,prs.ts.stopaligned,temporal_binwidth,peaktimewindow,bootstrap_trl);
        %% aligned to reward
        trials_spks_temp2 = ShiftSpikes(trials_spks_temp,[events_temp.t_rew]);
        [nspk,ts] = Spiketimes2Rate(trials_spks_temp2,prs.ts.rewardaligned,temporal_binwidth);
        stats.trialtype.(trialtypes{i})(j).events.reward.rate = nspk;
        stats.trialtype.(trialtypes{i})(j).events.reward.time = ts;
        stats.trialtype.(trialtypes{i})(j).events.reward.peakresp = ...         % significance of peak response
            EvaluatePeakresponse(trials_spks_temp2,prs.ts.rewardaligned,temporal_binwidth,peaktimewindow,bootstrap_trl);
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
        %% linear velocity
        timewindow(:,1) = [events_temp.t_move]'; timewindow(:,2) = [events_temp.t_stop]';
        stats.trialtype.(trialtypes{i})(j).continuous.v = ...
            ComputeTuning({continuous_temp.v},{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.v,bootstrap_trl);
        %% angular velocity
        timewindow(:,1) = [events_temp.t_move]'; timewindow(:,2) = [events_temp.t_stop]';
        stats.trialtype.(trialtypes{i})(j).continuous.w = ...
            ComputeTuning({continuous_temp.w},{continuous_temp.ts},{trials_spks_temp.tspk},timewindow,duration_zeropad,corr_lag,prs.tuning_binedges.w,bootstrap_trl);
        %% linear acceleration
        a = cellfun(@diff,{continuous_temp.v});
        %% angular acceleration
        
        %% magnitude of linear velocity
        
        %% magnitude of angular velocity
        
        %% magnitude of linear acceleration
        
        %% magnitude of angular acceleration
        
        %% horizontal eye position
        
        %% vertical eye position
        
        %% displacement
        
        %% bearing
        
        %% distance
        
        %% heading
        
        %% distance to target
        
        %% distance to stop
        
    end
end