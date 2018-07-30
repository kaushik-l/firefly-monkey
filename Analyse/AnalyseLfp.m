function stats = AnalyseLfp(trials_lfps,trials_behv,behv_stats,prs)

%% load analysis params
dt = prs.dt; % sampling resolution (s)
temporal_binwidth = prs.temporal_binwidth;
corr_lag = prs.corr_lag;
duration_zeropad = prs.duration_zeropad;
nbootstraps = prs.nbootstraps;
peaktimewindow = prs.peaktimewindow;
minpeakprominence = prs.minpeakprominence.neural;
mintrialsforstats = prs.mintrialsforstats;
event_potential = prs.event_potential;
compute_spectrum = prs.compute_spectrum;

%% load cases
trialtypes = fields(behv_stats.trialtype);
events = cell2mat({trials_behv.events});
continuous = cell2mat({trials_behv.continuous});

%% event-aligned, trial-averaged LFP
if event_potential
    gettuning = prs.tuning_events;
    for i=1:length(trialtypes)
        nconds = length(behv_stats.trialtype.(trialtypes{i}));
        for j=1:nconds
            trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
            events_temp = events(trlindx);
            continuous_temp = continuous(trlindx);
            trials_lfps_temp = trials_lfps(trlindx);
            %% aligned to movement onset
            if any(strcmp(gettuning,'move'))
                [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_move]);
                lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.move)';
                stats.trialtype.(trialtypes{i})(j).events.move.potential_mu = nanmean(lfps_temp2);
                stats.trialtype.(trialtypes{i})(j).events.move.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                stats.trialtype.(trialtypes{i})(j).events.move.time = prs.ts.move;
            end
            %% aligned to target onset
            if any(strcmp(gettuning,'target'))
                [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_targ]);
                lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.target)';
                stats.trialtype.(trialtypes{i})(j).events.target.potential_mu = nanmean(lfps_temp2);
                stats.trialtype.(trialtypes{i})(j).events.target.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                stats.trialtype.(trialtypes{i})(j).events.target.time = prs.ts.target;
            end
            %% aligned to movement stop
            if any(strcmp(gettuning,'stop'))
                [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_stop]);
                lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.stop)';
                stats.trialtype.(trialtypes{i})(j).events.stop.potential_mu = nanmean(lfps_temp2);
                stats.trialtype.(trialtypes{i})(j).events.stop.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                stats.trialtype.(trialtypes{i})(j).events.stop.time = prs.ts.stop;
            end
            %% aligned to reward
            if any(strcmp(gettuning,'reward'))
                [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_rew]);
                lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.reward)';
                stats.trialtype.(trialtypes{i})(j).events.reward.potential_mu = nanmean(lfps_temp2);
                stats.trialtype.(trialtypes{i})(j).events.reward.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                stats.trialtype.(trialtypes{i})(j).events.reward.time = prs.ts.reward;
            end
        end
    end
end

%% power spectral density
if compute_spectrum
    spectralparams.tapers = prs.spectrum_tapers;
    spectralparams.Fs = 1/dt;
    spectralparams.trialave = prs.spectrum_trialave;
    for i=1:length(trialtypes)
        nconds = length(behv_stats.trialtype.(trialtypes{i}));
        for j=1:nconds
            trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
            trials_lfps_temp = trials_lfps(trlindx);
            %%
            lfp_concat = cell2mat({trials_lfps_temp.lfp}'); % concatenate trials
            triallen = cellfun(@(x) length(x), {trials_lfps_temp.lfp});
            sMarkers(:,1) = cumsum([1 triallen(1:end-1)]); sMarkers(:,2) = cumsum(triallen); % demarcate trial onset and end
            [stats.trialtype.(trialtypes{i})(j).spectrum.psd , stats.trialtype.(trialtypes{i})(j).spectrum.freq] = ...
                mtspectrumc_unequal_length_trials(lfp_concat, prs.spectrum_movingwin , spectralparams, sMarkers); % needs http://chronux.org/
        end
    end
end