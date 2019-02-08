function stats = AnalyseLfp(trials_lfps,stationary_lfps,mobile_lfps,eyesfixed_lfps,eyesfree_lfps,eyesfixed_mobile_lfps,eyesfixed_stationary_lfps,eyesfree_mobile_lfps,eyesfree_stationary_lfps,trials_behv,behv_stats,prs)

stats = [];
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
analyse_theta = prs.analyse_theta;
analyse_beta = prs.analyse_beta;
ntrls = length(trials_lfps);
fixateduration = prs.fixateduration;
eyefreeduration = prs.eyemove_duration;

%% load cases
trialtypes = fields(behv_stats.trialtype);
events = cell2mat({trials_behv.events});
continuous = cell2mat({trials_behv.continuous});

%% event-aligned, trial-averaged LFP
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
end

%% power spectral density
if compute_spectrum
    spectralparams.tapers = prs.spectrum_tapers;
    spectralparams.Fs = 1/dt;
    spectralparams.trialave = prs.spectrum_trialave;
    
    %%     Uncomment for trial LFP
    % during trials
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
    %%
        % stationary period
        stationary_lfps_temp = []; sMarkers = [];
        for i=1:length(stationary_lfps)
            if ~isempty(stationary_lfps(i).lfp) % gather available inter-trials
                stationary_lfps_temp(end+1).lfp = stationary_lfps(i).lfp;
            end
        end
        lfp_concat = cell2mat({stationary_lfps_temp.lfp}); % concatenate trials
        triallen = cellfun(@(x) length(x), {stationary_lfps_temp.lfp});
        sMarkers(:,1) = cumsum([1 triallen(1:end-1)]); sMarkers(:,2) = cumsum(triallen); % demarcate trial onset and end
        [stats.trialtype.stationary.spectrum.psd , stats.trialtype.stationary.spectrum.freq] = ...
            mtspectrumc_unequal_length_trials(lfp_concat(:), [1 1] , spectralparams, sMarkers); % needs http://chronux.org/
    
        % mobile period
        mobile_lfps_temp = []; sMarkers = [];
        trlindx = behv_stats.trialtype.all.trlindx; mobile_lfps = mobile_lfps(trlindx);
        for i=1:length(mobile_lfps)
            if ~isempty(mobile_lfps(i).lfp) % gather available inter-trials
                mobile_lfps_temp(end+1).lfp = mobile_lfps(i).lfp;
            end
        end
        lfp_concat = cell2mat({mobile_lfps_temp.lfp}); % concatenate trials
        triallen = cellfun(@(x) length(x), {mobile_lfps_temp.lfp});
        sMarkers(:,1) = cumsum([1 triallen(1:end-1)]); sMarkers(:,2) = cumsum(triallen); % demarcate trial onset and end
        [stats.trialtype.mobile.spectrum.psd , stats.trialtype.mobile.spectrum.freq] = ...
            mtspectrumc_unequal_length_trials(lfp_concat(:), [1 1] , spectralparams, sMarkers); % needs http://chronux.org/
    
%         % eyes-fixed period
%         spectralparams.Fs = 500;
%         eyesfixed_lfps_temp = []; sMarkers = [];
%         for i=1:length(eyesfixed_lfps)
%             if ~isempty(eyesfixed_lfps(i).lfp)
%                 ts_filt = linspace(-pi/2,pi/2,length(eyesfixed_lfps(i).lfp));
%                 cos_filter = cos(ts_filt);
%                 eyesfixed_lfps_temp(end+1).lfp = (eyesfixed_lfps(i).lfp).*(cos_filter);
%             end
%         end
%         lfp_concat = cell2mat({eyesfixed_lfps_temp.lfp}); % concatenate trials
%         triallen = cellfun(@(x) length(x), {eyesfixed_lfps_temp.lfp});
%         %     sMarkers(:,1) = cumsum([1 triallen(1:end-1)]); sMarkers(:,2) = cumsum(triallen); % demarcate trial onset and end
%         sMarkers(:,1) = size(lfp_concat,1); sMarkers(:,2) =  size(lfp_concat,2); % demarcate trial onset and end
%         [stats.trialtype.eyesfixed.spectrum.psd , stats.trialtype.eyesfixed.spectrum.freq] = ...
%             mtspectrumc_unequal_length_trials(lfp_concat(:), [fixateduration fixateduration] , spectralparams, sMarkers); % needs http://chronux.org/
%     
%         % eyes-free period
%         eyesfree_lfps_temp = []; sMarkers = [];
%         for i=1:length(eyesfree_lfps)
%             if ~isempty(eyesfree_lfps(i).lfp)
%                 ts_filt = linspace(-pi/2,pi/2,length(eyesfree_lfps(i).lfp));
%                 cos_filter = cos(ts_filt);
%                 eyesfree_lfps_temp(end+1).lfp = (eyesfree_lfps(i).lfp).*(cos_filter);
%             end
%         end
%         lfp_concat = cell2mat({eyesfree_lfps_temp.lfp}); % concatenate trials
%         triallen = cellfun(@(x) length(x), {eyesfree_lfps_temp.lfp});
%         %     sMarkers(:,1) = cumsum([1 triallen(1:end-1)]); sMarkers(:,2) = cumsum(triallen); % demarcate trial onset and end
%         sMarkers(:,1) = size(lfp_concat,1); sMarkers(:,2) =  size(lfp_concat,2); % demarcate trial onset and end
%         [stats.trialtype.eyesfree.spectrum.psd , stats.trialtype.eyesfree.spectrum.freq] = ...
%             mtspectrumc_unequal_length_trials(lfp_concat(:), [fixateduration fixateduration] , spectralparams, sMarkers); % needs http://chronux.org/
    
    % eyes free, mobile period
    fs = 500; dt = 1/fs;
    spectralparams.tapers = prs.spectrum_tapers;
    spectralparams.Fs = 1/dt;
    spectralparams.trialave = prs.spectrum_trialave;
    
    %% eyes free mobile
    %     eyesfree_mobile_lfps_temp = []; sMarkers = [];
    %         tstart = eyesfree_mobile_lfps.tstart_file;
    %         if ~isempty(eyesfree_mobile_lfps.lfp)
    %             for i=1:length(tstart)
    %             indx_file(i,:)= find(eyesfree_mobile_lfps.ts(tstart(1):tstart(2)));  % get samples to maks per file
    %             ts_mask(i,:) = linspace(-pi/2,pi/2,length(indx_file)); %create mask for every file
    %             cos_mask(i,:) = cos(ts_mask(i,:));
    %             eyesfree_mobile_lfps_temp = [eyesfree_mobile_lfps_temp (eyesfree_mobile_lfps.lfp(indx_file)).*(cos_mask(i,:))];
    %             end
    %         end
    %     eyesfree_mobile_lfps_temp.lfp = (eyesfree_mobile_lfps.lfp).*(cos_mask);
    clear lfp_concat sMarkers
    lfp_concat = eyesfree_mobile_lfps.lfp(:); % concatenate trials
    triallen = cellfun(@(x) length(x), {eyesfree_mobile_lfps.lfp});
    sMarkers(:,1) = size(lfp_concat,2); sMarkers(:,2) =  size(lfp_concat,1); % demarcate trial onset and end
    [stats.trialtype.eyesfree_mobile.spectrum.psd , stats.trialtype.eyesfree_mobile.spectrum.freq] = ...
        mtspectrumc_unequal_length_trials(lfp_concat(:), [fixateduration fixateduration] , spectralparams, sMarkers); % needs http://chronux.org/
    
    %% eyes free, stationary period
    %     eyesfree_stationary_lfps_temp = []; sMarkers = [];
    %     for i=1:length(eyesfree_stationary_lfps)
    %         if ~isempty(eyesfree_stationary_lfps(i).lfp)
    %             ts_mask = linspace(-pi/2,pi/2,length(eyesfree_stationary_lfps(i).lfp));
    %             cos_mask = cos(ts_mask);
    %             eyesfree_stationary_lfps_temp(end+1).lfp = (eyesfree_stationary_lfps(i).lfp).*(cos_mask);
    %         end
    %     end
    clear lfp_concat sMarkers
    lfp_concat = eyesfree_stationary_lfps.lfp(:); % concatenate trials
    triallen = cellfun(@(x) length(x), {eyesfree_stationary_lfps.lfp});
    sMarkers(:,1) = size(lfp_concat,2); sMarkers(:,2) =  size(lfp_concat,1); % demarcate trial onset and end
    [stats.trialtype.eyesfree_stationary.spectrum.psd , stats.trialtype.eyesfree_stationary.spectrum.freq] = ...
        mtspectrumc_unequal_length_trials(lfp_concat(:), [fixateduration fixateduration] , spectralparams, sMarkers); % needs http://chronux.org/
    
    %% eyes fixed, mobile period
    %     eyesfixed_mobile_lfps_temp = []; sMarkers = [];
    %     for i=1:length(eyesfixed_mobile_lfps)
    %         if ~isempty(eyesfixed_mobile_lfps(i).lfp)
    %             ts_mask = linspace(-pi/2,pi/2,length(eyesfixed_mobile_lfps(i).lfp));
    %             cos_mask = cos(ts_mask);
    %             eyesfixed_mobile_lfps_temp(end+1).lfp = (eyesfixed_mobile_lfps(i).lfp).*(cos_mask);
    %         end
    %     end
    clear lfp_concat sMarkers
    lfp_concat = eyesfixed_mobile_lfps.lfp(:); % concatenate trials
    triallen = cellfun(@(x) length(x), {eyesfixed_mobile_lfps.lfp});
    sMarkers(:,1) = size(lfp_concat,2); sMarkers(:,2) =  size(lfp_concat,1); % demarcate trial onset and end
    [stats.trialtype.eyesfixed_mobile.spectrum.psd , stats.trialtype.eyesfixed_mobile.spectrum.freq] = ...
        mtspectrumc_unequal_length_trials(lfp_concat(:), [fixateduration fixateduration] , spectralparams, sMarkers); % needs http://chronux.org/
    
    
    %% eyes fixed, stationary period
    %     eyesfixed_stationary_lfps_temp = []; sMarkers = [];
    %     for i=1:length(eyesfixed_stationary_lfps)
    %         if ~isempty(eyesfixed_stationary_lfps(i).lfp)
    %             ts_mask = linspace(-pi/2,pi/2,length(eyesfixed_stationary_lfps(i).lfp));
    %             cos_mask = cos(ts_mask);
    %             eyesfixed_stationary_lfps_temp(end+1).lfp = (eyesfixed_stationary_lfps(i).lfp).*(cos_mask);
    %         end
    %     end
    clear lfp_concat sMarkers
    lfp_concat = eyesfixed_stationary_lfps.lfp(:); % concatenate trials
    triallen = cellfun(@(x) length(x), {eyesfixed_stationary_lfps.lfp});
    sMarkers(:,1) = size(lfp_concat,2); sMarkers(:,2) =  size(lfp_concat,1); % demarcate trial onset and end
    [stats.trialtype.eyesfixed_stationary.spectrum.psd , stats.trialtype.eyesfixed_stationary.spectrum.freq] = ...
        mtspectrumc_unequal_length_trials(lfp_concat(:), [fixateduration fixateduration] , spectralparams, sMarkers); % needs http://chronux.org/
    
    
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
    for i=1:length(trialtypes)
        nconds = length(behv_stats.trialtype.(trialtypes{i}));
        for j=1:nconds
            trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
            events_temp = events(trlindx);
            continuous_temp = continuous(trlindx);
            trials_theta_temp = trials_theta(trlindx);
            %% define time windows for computing tuning
            timewindow_move = [[events_temp.t_move]' [events_temp.t_stop]']; % when the subject is moving
            %% linear v                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 elocity, v
            stats.trialtype.(trialtypes{i})(j).continuous.v.thetafreq = ...
                ComputeTuning({continuous_temp.v},{continuous_temp.ts},{trials_theta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            %% angular velocity, w
            stats.trialtype.(trialtypes{i})(j).continuous.w.thetafreq = ...
                ComputeTuning({continuous_temp.w},{continuous_temp.ts},{trials_theta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            %% vw
            stats.trialtype.(trialtypes{i})(j).continuous.vw.thetafreq = ...
                ComputeTuning2D({continuous_temp.v},{continuous_temp.w},{continuous_temp.ts},{trials_theta_temp.freq},timewindow_move,prs.tuning,prs.tuning_method);
            %% horizontal eye velocity
            heye = cellfun(@(x,y) nanmean([x(:)' ; y(:)']),{continuous_temp.yle},{continuous_temp.yre},'UniformOutput',false); % average both eyes (if available)
            heyevel = cellfun(@(x) [0 ; diff(x)'/dt],heye,'UniformOutput',false); heyevel_abs = cellfun(@(x) abs(x),heyevel,'UniformOutput',false); clear heyevel_abs_nosacc
            for m = 1:length(heyevel_abs) % remove saccades
                temp_vel = heyevel_abs{m};
                temp_vel(temp_vel>25)=NaN;
                heyevel_abs_nosacc{m}= temp_vel;
            end
            stats.trialtype.(trialtypes{i})(j).continuous.heyevel.thetafreq = ...
                ComputeTuning(heyevel_abs_nosacc,{continuous_temp.ts},{trials_theta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method,prs.binrange.heye_vel);
            %% vertical velocity
            veye = cellfun(@(x,y) nanmean([x(:)' ; y(:)']),{continuous_temp.zle},{continuous_temp.zre},'UniformOutput',false); % average both eyes (if available)
            veyevel = cellfun(@(x) [0 ; diff(x)'/dt],veye,'UniformOutput',false);  veyevel_abs = cellfun(@(x) abs(x),veyevel,'UniformOutput',false); clear veyevel_abs_nosacc
            for m = 1:length(veyevel_abs) % remove saccades
                temp_vel = veyevel_abs{m};
                temp_vel(temp_vel>25)=NaN;
                veyevel_abs_nosacc{m}= temp_vel;
            end
            stats.trialtype.(trialtypes{i})(j).continuous.veyevel.thetafreq = ...
                ComputeTuning(veyevel_abs_nosacc,{continuous_temp.ts},{trials_theta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method,prs.binrange.veye_vel);
            %% v_w_heye_veye
            for k=1:length(continuous_temp), continuous_temp(k).w_abs = abs(continuous_temp(k).w); end % take abs value for w
            stats.trialtype.(trialtypes{i})(j).continuous.vwhv.thetafreq = ...
                MultiRegress({continuous_temp.v},{continuous_temp.w_abs},heyevel_abs_nosacc,veyevel_abs_nosacc,{continuous_temp.ts},{trials_theta_temp.freq},timewindow_move,prs.tuning,prs.tuning_method);           
        end
    end
end
%
%% beta LFP
trials_beta(ntrls) = struct();
if analyse_beta
    for i=1:ntrls
        trials_beta(i).lfp = trials_lfps(i).lfp_beta(:); % read as column vector
        beta_freq = [(1/dt)/(2*pi)*diff(unwrap(angle(trials_beta(i).lfp))) ; nan];
        beta_freq(beta_freq<prs.lfp_beta(1) | beta_freq>prs.lfp_beta(2)) = nan;
        trials_beta(i).freq = beta_freq;
    end
    for i=1:length(trialtypes)
        nconds = length(behv_stats.trialtype.(trialtypes{i}));
        for j=1:nconds
            trlindx = behv_stats.trialtype.(trialtypes{i})(j).trlindx;
            events_temp = events(trlindx);
            continuous_temp = continuous(trlindx);
            trials_beta_temp = trials_beta(trlindx);
            %% define time windows for computing tuning
            timewindow_move = [[events_temp.t_move]' [events_temp.t_stop]']; % when the subject is moving
            %% linear velocity, v
            stats.trialtype.(trialtypes{i})(j).continuous.v.betafreq = ...
                ComputeTuning({continuous_temp.v},{continuous_temp.ts},{trials_beta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            %% angular velocity, w
            stats.trialtype.(trialtypes{i})(j).continuous.w.betafreq = ...
                ComputeTuning({continuous_temp.w},{continuous_temp.ts},{trials_beta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method);
            %% vw
            stats.trialtype.(trialtypes{i})(j).continuous.vw.betafreq = ...
                ComputeTuning2D({continuous_temp.v},{continuous_temp.w},{continuous_temp.ts},{trials_beta_temp.freq},timewindow_move,prs.tuning,prs.tuning_method);
            %% horizontal eye velocity
            heye = cellfun(@(x,y) nanmean([x(:)' ; y(:)']),{continuous_temp.yle},{continuous_temp.yre},'UniformOutput',false); % average both eyes (if available) and take abs value
            heyevel = cellfun(@(x) [0 ; diff(x)'/dt],heye,'UniformOutput',false); heyevel_abs = cellfun(@(x) abs(x),heyevel,'UniformOutput',false); clear heyevel_abs_nosacc
             for m = 1:length(heyevel_abs) % remove saccades
                temp_vel = heyevel_abs{m};
                temp_vel(temp_vel>25)=NaN;
                heyevel_abs_nosacc{m}= temp_vel;
            end
            stats.trialtype.(trialtypes{i})(j).continuous.heyevel.betafreq = ...
                ComputeTuning(heyevel_abs_nosacc,{continuous_temp.ts},{trials_beta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method,prs.binrange.heye_vel);
            %% vertical velocity
            veye = cellfun(@(x,y) nanmean([x(:)' ; y(:)']),{continuous_temp.zle},{continuous_temp.zre},'UniformOutput',false); % average both eyes (if available) and take abs value
            veyevel = cellfun(@(x) [0 ; diff(x)'/dt],veye,'UniformOutput',false);  veyevel_abs = cellfun(@(x) abs(x),veyevel,'UniformOutput',false); clear veyevel_abs_nosacc
            for m = 1:length(veyevel_abs) % remove saccades
                temp_vel = veyevel_abs{m};
                temp_vel(temp_vel>25)=NaN;
                veyevel_abs_nosacc{m}= temp_vel;
            end
            stats.trialtype.(trialtypes{i})(j).continuous.veyevel.betafreq = ...
                ComputeTuning(veyevel_abs_nosacc,{continuous_temp.ts},{trials_beta_temp.freq},timewindow_move,duration_zeropad,corr_lag,nbootstraps,prs.tuning,prs.tuning_method,prs.binrange.veye_vel);
            %% v_w_heye_veye
              for k=1:length(continuous_temp), continuous_temp(k).w_abs = abs(continuous_temp(k).w); end % take abs value for w
            stats.trialtype.(trialtypes{i})(j).continuous.vwhv.betafreq = ...
                MultiRegress({continuous_temp.v},{continuous_temp.w_abs},heyevel_abs_nosacc,veyevel_abs_nosacc,{continuous_temp.ts},{trials_beta_temp.freq},timewindow_move,prs.tuning,prs.tuning_method);
        end
    end
end