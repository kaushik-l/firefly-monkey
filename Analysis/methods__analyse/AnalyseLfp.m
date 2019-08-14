function stats = AnalyseLfp(trials_lfps,epochs_lfps,trials_behv,behv_stats,prs)

stats = [];
%% load analysis params
dt = prs.dt; % sampling resolution (s)
fs_lfp = prs.fs_lfp;
temporal_binwidth = prs.temporal_binwidth;
corr_lag = prs.corr_lag;
duration_zeropad = prs.duration_zeropad;
nbootstraps = prs.nbootstraps;
peaktimewindow = prs.peaktimewindow;
minpeakprominence = prs.minpeakprominence.neural;
mintrialsforstats = prs.mintrialsforstats;
event_potential = prs.event_potential;
compute_spectrum = prs.compute_spectrum;
analyse_lfpepochs = prs.analyse_lfpepochs;
analyse_trialperiods = prs.analyse_trialperiods;
analyse_eventtriggeredlfp = prs.analyse_eventtriggeredlfp;
analyse_theta = prs.analyse_theta;
analyse_beta = prs.analyse_beta;
ntrls = length(trials_lfps);
fixateduration = prs.fixateduration;
eyefreeduration = prs.eyemove_duration;
spectrum_minwinlength = prs.spectrum_minwinlength;
eventtriggeredepochlength = prs.eventtriggeredepochlength;

%% load cases
trialtypes = fields(behv_stats.trialtype);
events = cell2mat({trials_behv.events});
continuous = cell2mat({trials_behv.continuous});

%% event-aligned LFP for trial-specific events
if event_potential
    gettuning = prs.tuning_events;
    for i=1:length(trialtypes)
        nconds = length(behv_stats.trialtype.(trialtypes{i}));
        if ~strcmp((trialtypes{i}),'all') && nconds==1, copystats = true; else, copystats = false; end % only one condition means variable was not manipulated
        for j=1:nconds
            if copystats % if only one condition present, no need to recompute stats --- simply copy them from 'all' trials
                stats.trialtype.(trialtypes{i})(j).events = stats.trialtype.all.events;
            else
                trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
                events_temp = events(trlindx);
                continuous_temp = continuous(trlindx);
                trials_lfps_temp = trials_lfps(trlindx);
                %% aligned to movement onset
                if any(strcmp(gettuning,'move'))
                    [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_move],'lfp');
                    lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.move)';
                    stats.trialtype.(trialtypes{i})(j).events.move.raw.potential_mu = nanmean(lfps_temp2);
                    stats.trialtype.(trialtypes{i})(j).events.move.raw.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                    stats.trialtype.(trialtypes{i})(j).events.move.raw.time = prs.ts.move;
                    
                    [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_move],'lfp_theta');
                    lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.move)';
                    stats.trialtype.(trialtypes{i})(j).events.move.theta.potential_mu = nanmean(lfps_temp2);
                    stats.trialtype.(trialtypes{i})(j).events.move.theta.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                    stats.trialtype.(trialtypes{i})(j).events.move.theta.time = prs.ts.move;
                    
                    [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_move],'lfp_beta');
                    lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.move)';
                    stats.trialtype.(trialtypes{i})(j).events.move.beta.potential_mu = nanmean(lfps_temp2);
                    stats.trialtype.(trialtypes{i})(j).events.move.beta.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                    stats.trialtype.(trialtypes{i})(j).events.move.beta.time = prs.ts.move;
                end
                %% aligned to target onset
                if any(strcmp(gettuning,'target'))
                    [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_targ],'lfp');
                    lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.target)';
                    stats.trialtype.(trialtypes{i})(j).events.target.raw.potential_mu = nanmean(lfps_temp2);
                    stats.trialtype.(trialtypes{i})(j).events.target.raw.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                    stats.trialtype.(trialtypes{i})(j).events.target.raw.time = prs.ts.target;
                    
                    [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_targ],'lfp_theta');
                    lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.target)';
                    stats.trialtype.(trialtypes{i})(j).events.target.theta.potential_mu = nanmean(lfps_temp2);
                    stats.trialtype.(trialtypes{i})(j).events.target.theta.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                    stats.trialtype.(trialtypes{i})(j).events.target.theta.time = prs.ts.target;
                    
                    [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_targ],'lfp_beta');
                    lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.target)';
                    stats.trialtype.(trialtypes{i})(j).events.target.beta.potential_mu = nanmean(lfps_temp2);
                    stats.trialtype.(trialtypes{i})(j).events.target.beta.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                    stats.trialtype.(trialtypes{i})(j).events.target.beta.time = prs.ts.target;
                end
                %% aligned to movement stop
                if any(strcmp(gettuning,'stop'))
                    [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_stop],'lfp');
                    lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.stop)';
                    stats.trialtype.(trialtypes{i})(j).events.stop.raw.potential_mu = nanmean(lfps_temp2);
                    stats.trialtype.(trialtypes{i})(j).events.stop.raw.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                    stats.trialtype.(trialtypes{i})(j).events.stop.raw.time = prs.ts.stop;
                    
                    [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_stop],'lfp_theta');
                    lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.stop)';
                    stats.trialtype.(trialtypes{i})(j).events.stop.theta.potential_mu = nanmean(lfps_temp2);
                    stats.trialtype.(trialtypes{i})(j).events.stop.theta.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                    stats.trialtype.(trialtypes{i})(j).events.stop.theta.time = prs.ts.stop;
                    
                    [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_stop],'lfp_beta');
                    lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.stop)';
                    stats.trialtype.(trialtypes{i})(j).events.stop.beta.potential_mu = nanmean(lfps_temp2);
                    stats.trialtype.(trialtypes{i})(j).events.stop.beta.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                    stats.trialtype.(trialtypes{i})(j).events.stop.beta.time = prs.ts.stop;
                end
                %% aligned to reward
                if any(strcmp(gettuning,'reward'))
                    [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_rew],'lfp');
                    lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.reward)';
                    stats.trialtype.(trialtypes{i})(j).events.reward.raw.potential_mu = nanmean(lfps_temp2);
                    stats.trialtype.(trialtypes{i})(j).events.reward.raw.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                    stats.trialtype.(trialtypes{i})(j).events.reward.raw.time = prs.ts.reward;
                    
                    [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_rew],'lfp_theta');
                    lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.reward)';
                    stats.trialtype.(trialtypes{i})(j).events.reward.theta.potential_mu = nanmean(lfps_temp2);
                    stats.trialtype.(trialtypes{i})(j).events.reward.theta.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                    stats.trialtype.(trialtypes{i})(j).events.reward.theta.time = prs.ts.reward;
                    
                    [trials_lfps_temp2,ts] = ShiftLfps(trials_lfps_temp,continuous_temp,[events_temp.t_rew],'lfp_beta');
                    lfps_temp2 = interp1(ts,(trials_lfps_temp2),prs.ts.reward)';
                    stats.trialtype.(trialtypes{i})(j).events.reward.beta.potential_mu = nanmean(lfps_temp2);
                    stats.trialtype.(trialtypes{i})(j).events.reward.beta.potential_sem = nanstd(lfps_temp2)/sqrt(size(lfps_temp2,1));
                    stats.trialtype.(trialtypes{i})(j).events.reward.beta.time = prs.ts.reward;
                end
            end
        end
    end
end

%% event-aligned LFP for other events
if analyse_eventtriggeredlfp
    %% aligned to fixation
    if any(strcmp(gettuning,'fixate'))
        nevents = numel({epochs_lfps.fixationevent.lfp});
        stats.eventtype.fixate.raw.potential_mu = nanmean(cell2mat({epochs_lfps.fixationevent.lfp}'));
        stats.eventtype.fixate.raw.potential_sem = nanstd(cell2mat({epochs_lfps.fixationevent.lfp}'))/sqrt(nevents);
        stats.eventtype.fixate.raw.time = linspace(-eventtriggeredepochlength/2,eventtriggeredepochlength/2,length(stats.eventtype.fixate.raw.potential_mu));
        
        stats.eventtype.fixate.theta.potential_mu = nanmean(real(cell2mat({epochs_lfps.fixationevent.lfp_theta}')));
        stats.eventtype.fixate.theta.potential_sem = nanstd(real(cell2mat({epochs_lfps.fixationevent.lfp_theta}')))/sqrt(nevents);
        stats.eventtype.fixate.theta.phase_mu = nanmean(angle(cell2mat({epochs_lfps.fixationevent.lfp_theta}')));
        stats.eventtype.fixate.theta.phase_sem = nanstd(angle(cell2mat({epochs_lfps.fixationevent.lfp_theta}')))/sqrt(nevents);
        stats.eventtype.fixate.theta.time = linspace(-eventtriggeredepochlength/2,eventtriggeredepochlength/2,length(stats.eventtype.fixate.theta.potential_mu));
        
        stats.eventtype.fixate.beta.potential_mu = nanmean(real(cell2mat({epochs_lfps.fixationevent.lfp_beta}')));
        stats.eventtype.fixate.beta.potential_sem = nanstd(real(cell2mat({epochs_lfps.fixationevent.lfp_beta}')))/sqrt(nevents);
        stats.eventtype.fixate.beta.phase_mu = nanmean(angle(cell2mat({epochs_lfps.fixationevent.lfp_beta}')));
        stats.eventtype.fixate.beta.phase_sem = nanstd(angle(cell2mat({epochs_lfps.fixationevent.lfp_beta}')))/sqrt(nevents);
        stats.eventtype.fixate.beta.time = linspace(-eventtriggeredepochlength/2,eventtriggeredepochlength/2,length(stats.eventtype.fixate.beta.potential_mu));
    end
    %% aligned to saccade
    if any(strcmp(gettuning,'saccade'))
        nevents = numel({epochs_lfps.saccadicevent.lfp});
        stats.eventtype.saccade.raw.potential_mu = nanmean(cell2mat({epochs_lfps.saccadicevent.lfp}'));
        stats.eventtype.saccade.raw.potential_sem = nanstd(cell2mat({epochs_lfps.saccadicevent.lfp}'))/sqrt(nevents);
        stats.eventtype.saccade.raw.time = linspace(-eventtriggeredepochlength/2,eventtriggeredepochlength/2,length(stats.eventtype.saccade.raw.potential_mu));
        
        stats.eventtype.saccade.theta.potential_mu = nanmean(real(cell2mat({epochs_lfps.saccadicevent.lfp_theta}')));
        stats.eventtype.saccade.theta.potential_sem = nanstd(real(cell2mat({epochs_lfps.saccadicevent.lfp_theta}')))/sqrt(nevents);
        stats.eventtype.saccade.theta.phase_mu = nanmean(angle(cell2mat({epochs_lfps.saccadicevent.lfp_theta}')));
        stats.eventtype.saccade.theta.phase_sem = nanstd(angle(cell2mat({epochs_lfps.saccadicevent.lfp_theta}')))/sqrt(nevents);
        stats.eventtype.saccade.theta.time = linspace(-eventtriggeredepochlength/2,eventtriggeredepochlength/2,length(stats.eventtype.saccade.theta.potential_mu));
        
        stats.eventtype.saccade.beta.potential_mu = nanmean(real(cell2mat({epochs_lfps.saccadicevent.lfp_beta}')));
        stats.eventtype.saccade.beta.potential_sem = nanstd(real(cell2mat({epochs_lfps.saccadicevent.lfp_beta}')))/sqrt(nevents);
        stats.eventtype.saccade.beta.phase_mu = nanmean(angle(cell2mat({epochs_lfps.saccadicevent.lfp_beta}')));
        stats.eventtype.saccade.beta.phase_sem = nanstd(angle(cell2mat({epochs_lfps.saccadicevent.lfp_beta}')))/sqrt(nevents);
        stats.eventtype.saccade.beta.time = linspace(-eventtriggeredepochlength/2,eventtriggeredepochlength/2,length(stats.eventtype.saccade.beta.potential_mu));
    end
end

%% power spectral density
if compute_spectrum
    spectralparams.tapers = prs.spectrum_tapers;
    spectralparams.Fs = 1/dt;
    spectralparams.trialave = prs.spectrum_trialave;
    
    %% trial periods
    if analyse_trialperiods
        for i=1:length(trialtypes)
            nconds = length(behv_stats.trialtype.(trialtypes{i}));
            if ~strcmp((trialtypes{i}),'all') && nconds==1, copystats = true; else, copystats = false; end % only one condition means variable was not manipulated
            for j=1:nconds
                if copystats % if only one condition present, no need to recompute stats --- simply copy them from 'all' trials
                    stats.trialtype.(trialtypes{i})(j).spectrum = stats.trialtype.all.spectrum;
                else
                    sMarkers = [];
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
    end
    
    %% epochs
    if analyse_lfpepochs
        % stationary period
        stationary_lfps_temp = []; sMarkers = [];
        for i=1:length(epochs_lfps.stationary)
            if ~isempty(epochs_lfps.stationary(i).lfp) % gather available inter-trials
                stationary_lfps_temp(end+1).lfp = epochs_lfps.stationary(i).lfp;
            end
        end
        lfp_concat = cell2mat({stationary_lfps_temp.lfp}); % concatenate trials
        triallen = cellfun(@(x) length(x), {stationary_lfps_temp.lfp});
        sMarkers(:,1) = cumsum([1 triallen(1:end-1)]); sMarkers(:,2) = cumsum(triallen); % demarcate trial onset and end
        [stats.epoch.stationary.spectrum.psd , stats.epoch.stationary.spectrum.freq] = ...
            mtspectrumc_unequal_length_trials(lfp_concat(:), [1 1] , spectralparams, sMarkers); % needs http://chronux.org/
        
        % mobile period
        mobile_lfps_temp = []; sMarkers = [];
        trlindx = behv_stats.trialtype.all.trlindx; mobile_lfps = epochs_lfps.mobile(trlindx);
        for i=1:length(mobile_lfps)
            if ~isempty(mobile_lfps(i).lfp) % gather available inter-trials
                mobile_lfps_temp(end+1).lfp = mobile_lfps(i).lfp;
            end
        end
        lfp_concat = cell2mat({mobile_lfps_temp.lfp}); % concatenate trials
        triallen = cellfun(@(x) length(x), {mobile_lfps_temp.lfp});
        sMarkers(:,1) = cumsum([1 triallen(1:end-1)]); sMarkers(:,2) = cumsum(triallen); % demarcate trial onset and end
        [stats.epoch.mobile.spectrum.psd , stats.epoch.mobile.spectrum.freq] = ...
            mtspectrumc_unequal_length_trials(lfp_concat(:), [1 1] , spectralparams, sMarkers); % needs http://chronux.org/
        
        %%
        spectralparams.Fs = fs_lfp;
        spectrum_minwinlength = 0.5;
        spectralparams.tapers = [1 1];
        % eyes free
        clear lfp_concat sMarkers
        lfp_concat = cell2mat({epochs_lfps.eyesfree.lfp}); % concatenate trials
        triallen = cellfun(@(x) length(x), {epochs_lfps.eyesfree.lfp});
        sMarkers(:,1) = 1; sMarkers(:,2) = sum(triallen); % demarcate trial onset and end
        if ~isempty(lfp_concat)
            [stats.epoch.eyesfree.spectrum.psd , stats.epoch.eyesfree.spectrum.freq] = ...
                mtspectrumc_unequal_length_trials(lfp_concat(:), [1 1] , spectralparams, sMarkers); % needs http://chronux.org/
        else
            stats.epoch.eyesfree.spectrum.psd = [];
            stats.epoch.eyesfree.spectrum.freq = [];
        end
        
        % eyes fixed
        clear lfp_concat sMarkers
        lfp_concat = cell2mat({epochs_lfps.eyesfixed.lfp}); % concatenate trials
        triallen = cellfun(@(x) length(x), {epochs_lfps.eyesfixed.lfp});
        sMarkers(:,1) = 1; sMarkers(:,2) = sum(triallen); % demarcate trial onset and end
        if ~isempty(lfp_concat)
            [stats.epoch.eyesfixed.spectrum.psd , stats.epoch.eyesfixed.spectrum.freq] = ...
                mtspectrumc_unequal_length_trials(lfp_concat(:), [1 1] , spectralparams, sMarkers); % needs http://chronux.org/
        else
            stats.epoch.eyesfixed.spectrum.psd = [];
            stats.epoch.eyesfixed.spectrum.freq = [];
        end
        
        % eyes free, mobile
        clear lfp_concat sMarkers
        lfp_concat = cell2mat({epochs_lfps.eyesfree_mobile.lfp}); % concatenate trials
        triallen = cellfun(@(x) length(x), {epochs_lfps.eyesfree_mobile.lfp});
        sMarkers(:,1) = 1; sMarkers(:,2) = sum(triallen); % demarcate trial onset and end
        if ~isempty(lfp_concat)
            [stats.epoch.eyesfree_mobile.spectrum.psd , stats.epoch.eyesfree_mobile.spectrum.freq] = ...
                mtspectrumc_unequal_length_trials(lfp_concat(:), [1 1] , spectralparams, sMarkers); % needs http://chronux.org/
        else
            stats.epoch.eyesfree_mobile.spectrum.psd = [];
            stats.epoch.eyesfree_mobile.spectrum.freq = [];
        end
        
        % eyes free, stationary period
        clear lfp_concat sMarkers
        lfp_concat = cell2mat({epochs_lfps.eyesfree_stationary.lfp}); % concatenate trials
        triallen = cellfun(@(x) length(x), {epochs_lfps.eyesfree_stationary.lfp});
        sMarkers(:,1) = 1; sMarkers(:,2) = sum(triallen); % demarcate trial onset and end
        if ~isempty(lfp_concat)
            [stats.epoch.eyesfree_stationary.spectrum.psd , stats.epoch.eyesfree_stationary.spectrum.freq] = ...
                mtspectrumc_unequal_length_trials(lfp_concat(:), [1 1] , spectralparams, sMarkers); % needs http://chronux.org/
        else
            stats.epoch.eyesfree_stationary.spectrum.psd = [];
            stats.epoch.eyesfree_stationary.spectrum.freq = [];
        end
        
        % eyes fixed, mobile period
        clear lfp_concat sMarkers
        lfp_concat = cell2mat({epochs_lfps.eyesfixed_mobile.lfp}); % concatenate trials
        triallen = cellfun(@(x) length(x), {epochs_lfps.eyesfixed_mobile.lfp});
        sMarkers(:,1) = 1; sMarkers(:,2) = sum(triallen); % demarcate trial onset and end
        if ~isempty(lfp_concat)
            [stats.epoch.eyesfixed_mobile.spectrum.psd , stats.epoch.eyesfixed_mobile.spectrum.freq] = ...
                mtspectrumc_unequal_length_trials(lfp_concat(:), [1 1] , spectralparams, sMarkers); % needs http://chronux.org/
        else
            stats.epoch.eyesfixed_mobile.spectrum.psd = [];
            stats.epoch.eyesfixed_mobile.spectrum.freq = [];
        end
        
        % eyes fixed, stationary period
        clear lfp_concat sMarkers
        lfp_concat = cell2mat({epochs_lfps.eyesfixed_stationary.lfp}); % concatenate trials
        triallen = cellfun(@(x) length(x), {epochs_lfps.eyesfixed_stationary.lfp});
        sMarkers(:,1) = 1; sMarkers(:,2) = sum(triallen); % demarcate trial onset and end
        if ~isempty(lfp_concat)
            [stats.epoch.eyesfixed_stationary.spectrum.psd , stats.epoch.eyesfixed_stationary.spectrum.freq] = ...
                mtspectrumc_unequal_length_trials(lfp_concat(:), [1 1] , spectralparams, sMarkers); % needs http://chronux.org/
        else
            stats.epoch.eyesfixed_stationary.spectrum.psd = [];
            stats.epoch.eyesfixed_stationary.spectrum.freq = [];
        end
    end
    
    %% event aligned spectrograms
    if analyse_eventtriggeredlfp
        %%
        spectralparams.Fs = fs_lfp;
        spectrum_minwinlength = eventtriggeredepochlength/2;
        spectralparams.tapers = [1 1];
        
        % fixation
        spectralparams.pad = 0;
        clear lfp_concat sMarkers
        lfp_concat = cell2mat({epochs_lfps.fixationevent.lfp}); % concatenate trials
        triallen = cellfun(@(x) length(x), {epochs_lfps.fixationevent.lfp});
        sMarkers(:,1) = cumsum([1 triallen(1:end-1)]); sMarkers(:,2) = cumsum(triallen); % demarcate trial onset and end
        [stats.eventtype.fixate.spectrum.psd , stats.eventtype.fixate.spectrum.freq] = ...
            mtspectrumc_unequal_length_trials(lfp_concat(:), [1 1] , spectralparams, sMarkers); % needs http://chronux.org/
        spectralparams.pad = 2;
        [stats.eventtype.fixate.tfspectrum.psd , stats.eventtype.fixate.tfspectrum.time, stats.eventtype.fixate.tfspectrum.freq] = ...
            mtspecgramtrigc(lfp_concat(:), floor(mean(sMarkers,2))/fs_lfp, [1 1], [0.5 0.01] , spectralparams); % needs http://chronux.org/
        
        % saccade
        spectralparams.pad = 0;
        clear lfp_concat sMarkers
        lfp_concat = cell2mat({epochs_lfps.saccadicevent.lfp}); % concatenate trials
        triallen = cellfun(@(x) length(x), {epochs_lfps.saccadicevent.lfp});
        sMarkers(:,1) = cumsum([1 triallen(1:end-1)]); sMarkers(:,2) = cumsum(triallen); % demarcate trial onset and end
        [stats.eventtype.saccade.spectrum.psd , stats.eventtype.saccade.spectrum.freq] = ...
            mtspectrumc_unequal_length_trials(lfp_concat(:), [1 1] , spectralparams, sMarkers); % needs http://chronux.org/
        spectralparams.pad = 2;
        [stats.eventtype.saccade.tfspectrum.psd , stats.eventtype.saccade.tfspectrum.time, stats.eventtype.saccade.tfspectrum.freq] = ...
            mtspecgramtrigc(lfp_concat(:), floor(mean(sMarkers,2))/fs_lfp, [1 1], [0.5 0.01] , spectralparams); % needs http://chronux.org/
        
        %%
        spectralparams.Fs = 1/dt;
        
        % target
        trlindx = behv_stats.trialtype.all.trlindx;
        events_temp = events(trlindx);
        continuous_temp = continuous(trlindx);
        trials_lfps_temp = trials_lfps(trlindx);
        clear lfp_concat sMarkers
        lfp_concat = cell2mat({trials_lfps_temp.lfp}'); % concatenate trials
        triallen = cellfun(@(x) length(x), {trials_lfps_temp.lfp}'); cumtriallen = cumsum(triallen); cumtriallen = cumtriallen(:);
        eventtimes = arrayfun(@(x,y) find(x.ts > y.t_targ,1), continuous_temp, events_temp); eventtimes = eventtimes(:);
        eventtimes = eventtimes + [0 ; cumtriallen(1:end-1)]; eventtimes = eventtimes*dt; eventtimes([1 end]) = [];
        spectralparams.pad = 2;
        [stats.eventtype.target.tfspectrum.psd , stats.eventtype.target.tfspectrum.time, stats.eventtype.target.tfspectrum.freq] = ...
            mtspecgramtrigc(lfp_concat(:), eventtimes, [1 1], [0.5 0.01] , spectralparams); % needs http://chronux.org/
        
        % move
        trlindx = behv_stats.trialtype.all.trlindx;
        events_temp = events(trlindx);
        continuous_temp = continuous(trlindx);
        trials_lfps_temp = trials_lfps(trlindx);
        clear lfp_concat sMarkers
        lfp_concat = cell2mat({trials_lfps_temp.lfp}'); % concatenate trials
        triallen = cellfun(@(x) length(x), {trials_lfps_temp.lfp}'); cumtriallen = cumsum(triallen); cumtriallen = cumtriallen(:);
        eventtimes = arrayfun(@(x,y) find(x.ts > y.t_move,1), continuous_temp, events_temp); eventtimes = eventtimes(:);
        eventtimes = eventtimes + [0 ; cumtriallen(1:end-1)]; eventtimes = eventtimes*dt; eventtimes([1 end]) = [];
        spectralparams.pad = 2;
        [stats.eventtype.move.tfspectrum.psd , stats.eventtype.move.tfspectrum.time, stats.eventtype.move.tfspectrum.freq] = ...
            mtspecgramtrigc(lfp_concat(:), eventtimes, [1 1], [0.5 0.01] , spectralparams); % needs http://chronux.org/
        
        % stop
        trlindx = behv_stats.trialtype.all.trlindx;
        events_temp = events(trlindx);
        continuous_temp = continuous(trlindx);
        trials_lfps_temp = trials_lfps(trlindx);
        clear lfp_concat sMarkers
        lfp_concat = cell2mat({trials_lfps_temp.lfp}'); % concatenate trials
        triallen = cellfun(@(x) length(x), {trials_lfps_temp.lfp}'); cumtriallen = cumsum(triallen); cumtriallen = cumtriallen(:);
        eventtimes = arrayfun(@(x,y) find(x.ts > y.t_stop,1), continuous_temp, events_temp); eventtimes = eventtimes(:);
        eventtimes = eventtimes + [0 ; cumtriallen(1:end-1)]; eventtimes = eventtimes*dt; eventtimes([1 end]) = [];
        spectralparams.pad = 2;
        [stats.eventtype.stop.tfspectrum.psd , stats.eventtype.stop.tfspectrum.time, stats.eventtype.stop.tfspectrum.freq] = ...
            mtspecgramtrigc(lfp_concat(:), eventtimes, [1 1], [0.5 0.01] , spectralparams); % needs http://chronux.org/
        
        % reward
        trlindx = behv_stats.trialtype.reward(2).trlindx;
        events_temp = events(trlindx);
        continuous_temp = continuous(trlindx);
        trials_lfps_temp = trials_lfps(trlindx);
        clear lfp_concat sMarkers
        lfp_concat = cell2mat({trials_lfps_temp.lfp}'); % concatenate trials
        triallen = cellfun(@(x) length(x), {trials_lfps_temp.lfp}'); cumtriallen = cumsum(triallen); cumtriallen = cumtriallen(:);
        eventtimes = arrayfun(@(x,y) find(x.ts > y.t_rew,1), continuous_temp, events_temp); eventtimes = eventtimes(:);
        eventtimes = eventtimes + [0 ; cumtriallen(1:end-1)]; eventtimes = eventtimes*dt; eventtimes([1 end]) = [];
        spectralparams.pad = 2;
        [stats.eventtype.reward.tfspectrum.psd , stats.eventtype.reward.tfspectrum.time, stats.eventtype.reward.tfspectrum.freq] = ...
            mtspecgramtrigc(lfp_concat(:), eventtimes, [1 1], [0.5 0.01] , spectralparams); % needs http://chronux.org/
        
        
    end
    
end

%% theta LFP
trials_theta(ntrls) = struct();
if analyse_theta
    for i=1:ntrls
        trials_theta(i).lfp = trials_lfps(i).lfp_theta(:); % read as column vector
        theta_freq = [(1/dt)/(2*pi)*diff(unwrap(angle(trials_theta(i).lfp))) ; nan];
        theta_freq(theta_freq<prs.lfp_theta(1) | theta_freq>prs.lfp_theta(2)) = nan;
        trials_theta(i).freq = theta_freq;
    end
    for i=1%:length(trialtypes)
        nconds = length(behv_stats.trialtype.(trialtypes{i}));
        for j=1:nconds
            trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
            events_temp = events(trlindx);
            continuous_temp = continuous(trlindx);
            trials_theta_temp = trials_theta(trlindx);
            %% define time windows for computing tuning
            timewindow_move = [[events_temp.t_move]' [events_temp.t_stop]']; % when the subject is moving
            %% linear velocity, v
            corr_lag = 200; % number of samples
            stats.trialtype.(trialtypes{i})(j).continuous.v.thetafreq = ...
                ComputeTuning({continuous_temp.v},{continuous_temp.ts},{trials_theta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method,prs.binrange.v);
            %% angular velocity, w
            corr_lag = 200; % number of samples
            stats.trialtype.(trialtypes{i})(j).continuous.w.thetafreq = ...
                ComputeTuning({continuous_temp.w},{continuous_temp.ts},{trials_theta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method,prs.binrange.w);
            %% vw
            stats.trialtype.(trialtypes{i})(j).continuous.vw.thetafreq = ...
                ComputeTuning2D({continuous_temp.v},{continuous_temp.w},{continuous_temp.ts},{trials_theta_temp.freq},timewindow_move,prs.tuning,prs.tuning_method);
            %% horizontal eye velocity
            heye = cellfun(@(x,y) nanmean([x(:)' ; y(:)']),{continuous_temp.yle},{continuous_temp.yre},'UniformOutput',false); % average both eyes (if available)
            heyevel = cellfun(@(x) [0 ; diff(x)'/dt],heye,'UniformOutput',false);
            for m=1:length(heyevel), heyevel{m}(abs(heyevel{m})>25) = NaN; end
            heyevel_abs = cellfun(@(x) abs(x),heyevel,'UniformOutput',false);
            stats.trialtype.(trialtypes{i})(j).continuous.heyevel.thetafreq = ...
                ComputeTuning(heyevel,{continuous_temp.ts},{trials_theta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method,prs.binrange.heye_vel);
            %% vertical velocity
            veye = cellfun(@(x,y) nanmean([x(:)' ; y(:)']),{continuous_temp.zle},{continuous_temp.zre},'UniformOutput',false); % average both eyes (if available)
            veyevel = cellfun(@(x) [0 ; diff(x)'/dt],veye,'UniformOutput',false);
            for m=1:length(heyevel), veyevel{m}(abs(veyevel{m})>25) = NaN; end
            veyevel_abs = cellfun(@(x) abs(x),veyevel,'UniformOutput',false);
            stats.trialtype.(trialtypes{i})(j).continuous.veyevel.thetafreq = ...
                ComputeTuning(veyevel,{continuous_temp.ts},{trials_theta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method,prs.binrange.veye_vel);
            %% v_w_heye_veye
            for k=1:length(continuous_temp), continuous_temp(k).w_abs = abs(continuous_temp(k).w); continuous_temp(k).v_abs = abs(continuous_temp(k).v); end % take abs value for w
            stats.trialtype.(trialtypes{i})(j).continuous.vwhv.thetafreq = ...
                MultiRegress({continuous_temp.v_abs},{continuous_temp.w_abs},heyevel_abs,veyevel_abs,{continuous_temp.ts},{trials_theta_temp.freq},timewindow_move);
        end
    end
end

%% beta LFP
trials_beta(ntrls) = struct();
if analyse_beta
    for i=1:ntrls
        trials_beta(i).lfp = trials_lfps(i).lfp_beta(:); % read as column vector
        beta_freq = [(1/dt)/(2*pi)*diff(unwrap(angle(trials_beta(i).lfp))) ; nan];
        beta_freq(beta_freq<prs.lfp_beta(1) | beta_freq>prs.lfp_beta(2)) = nan;
        trials_beta(i).freq = beta_freq;
    end
    for i=1%:length(trialtypes)
        nconds = length(behv_stats.trialtype.(trialtypes{i}));
        for j=1:nconds
            trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
            events_temp = events(trlindx);
            continuous_temp = continuous(trlindx);
            trials_beta_temp = trials_beta(trlindx);
            %% define time windows for computing tuning
            timewindow_move = [[events_temp.t_move]' [events_temp.t_stop]']; % when the subject is moving
            %% linear velocity, v
            corr_lag = 200; % number of samples
            stats.trialtype.(trialtypes{i})(j).continuous.v.betafreq = ...
                ComputeTuning({continuous_temp.v},{continuous_temp.ts},{trials_beta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method,prs.binrange.v);
            %% angular velocity, w
            corr_lag = 200; % number of samples
            stats.trialtype.(trialtypes{i})(j).continuous.w.betafreq = ...
                ComputeTuning({continuous_temp.w},{continuous_temp.ts},{trials_beta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method,prs.binrange.w);
            %% vw
            stats.trialtype.(trialtypes{i})(j).continuous.vw.betafreq = ...
                ComputeTuning2D({continuous_temp.v},{continuous_temp.w},{continuous_temp.ts},{trials_beta_temp.freq},timewindow_move,prs.tuning,prs.tuning_method);
            %% horizontal eye velocity
            heye = cellfun(@(x,y) nanmean([x(:)' ; y(:)']),{continuous_temp.yle},{continuous_temp.yre},'UniformOutput',false); % average both eyes (if available)
            heyevel = cellfun(@(x) [0 ; diff(x)'/dt],heye,'UniformOutput',false);
            for m=1:length(heyevel), heyevel{m}(abs(heyevel{m})>25) = NaN; end
            heyevel_abs = cellfun(@(x) abs(x),heyevel,'UniformOutput',false);
            stats.trialtype.(trialtypes{i})(j).continuous.heyevel.betafreq = ...
                ComputeTuning(heyevel,{continuous_temp.ts},{trials_beta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method,prs.binrange.heye_vel);
            %% vertical velocity
            veye = cellfun(@(x,y) nanmean([x(:)' ; y(:)']),{continuous_temp.zle},{continuous_temp.zre},'UniformOutput',false); % average both eyes (if available)
            veyevel = cellfun(@(x) [0 ; diff(x)'/dt],veye,'UniformOutput',false);
            for m=1:length(heyevel), veyevel{m}(abs(veyevel{m})>25) = NaN; end
            veyevel_abs = cellfun(@(x) abs(x),veyevel,'UniformOutput',false);
            stats.trialtype.(trialtypes{i})(j).continuous.veyevel.betafreq = ...
                ComputeTuning(veyevel,{continuous_temp.ts},{trials_beta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method,prs.binrange.veye_vel);
            %% v_w_heye_veye
            for k=1:length(continuous_temp), continuous_temp(k).w_abs = abs(continuous_temp(k).w); continuous_temp(k).v_abs = abs(continuous_temp(k).v); end % take abs value for w
            stats.trialtype.(trialtypes{i})(j).continuous.vwhv.betafreq = ...
                MultiRegress({continuous_temp.v_abs},{continuous_temp.w_abs},heyevel_abs,veyevel_abs,{continuous_temp.ts},{trials_beta_temp.freq},timewindow_move);
        end
    end
end