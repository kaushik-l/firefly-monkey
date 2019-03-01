function [trials, stationary, mobile, eyesfixed, eyesfree, eyesfree_mobile, eyesfree_stationary, eyesfixed_mobile, eyesfixed_stationary] = AddTrials2Lfp(lfp,fs,trialevents,trials_behv,prs)

ntrls = length(trialevents.t_end);
trials(ntrls) = struct(); 
stationary(ntrls) = struct(); mobile(ntrls) = struct();
dt = 1/fs;
nt = length(lfp);
ts = dt*(1:nt);

%% filter LFP
[b,a] = butter(prs.lfp_filtorder,[prs.lfp_freqmin prs.lfp_freqmax]/(fs/2));
lfp = filtfilt(b,a,lfp);

%% trials (raw)
trials(ntrls) = struct();
for i=1:ntrls
    if ~isnan(trialevents.t_beg(i))
        t_beg = trialevents.t_beg(i) + trials_behv.trials(i).events.t_beg_correction; % correction aligns t_beg with target onset
        t1 = trials_behv.trials(i).continuous.ts(1); % read lfp from first behavioural sample of trial i
        t2 = trials_behv.trials(i).continuous.ts(end); % till last behavioural sample of trial i
        lfp_raw = lfp(ts > (t_beg + t1) & ts < (t_beg + t2)); 
        t_raw = linspace(t1,t2,length(lfp_raw));
        trials(i).lfp = interp1(t_raw,lfp_raw,trials_behv.trials(i).continuous.ts,'linear'); % resample to match behavioural recording
    else
        trials(i).lfp = nan(length(trials_behv.trials(i).continuous.ts),1);
    end
end

%% stationary period (raw)
stationary(ntrls-1) = struct(); % obviously only N-1 inter-trials
for i=1:ntrls-1
    if ~isnan(trialevents.t_beg(i))
        t_beg1 = trialevents.t_beg(i) + trials_behv.trials(i).events.t_beg_correction;
        t_beg2 = trialevents.t_beg(i+1) + trials_behv.trials(i+1).events.t_beg_correction;
        t_stop = t_beg1 + trials_behv.trials(i).events.t_stop;
        t_move = t_beg2 + trials_behv.trials(i+1).events.t_move;
        if (t_move-t_stop) > prs.min_stationary + prs.dt
            lfp_raw = lfp(ts > t_stop & ts < t_move);
            t_raw = linspace(0,1,length(lfp_raw));
            t_interp = linspace(0,1,round(length(lfp_raw)*(dt/prs.dt)));
            stationary(i).lfp = interp1(t_raw,lfp_raw,t_interp,'linear'); % resample to match behavioural recording
        end
    end
end

%% motion period (raw)
mobile(ntrls) = struct(); % obviously only N-1 inter-trials
for i=1:ntrls
    if ~isnan(trialevents.t_beg(i))
        t_beg = trialevents.t_beg(i) + trials_behv.trials(i).events.t_beg_correction;
        t_move = t_beg + trials_behv.trials(i).events.t_move;
        t_stop = t_beg + trials_behv.trials(i).events.t_stop;
        if (t_stop-t_move) > prs.min_mobile + prs.dt
            lfp_raw = lfp(ts > t_move & ts < t_stop);
            t_raw = linspace(0,1,length(lfp_raw));
            t_interp = linspace(0,1,round(length(lfp_raw)*(dt/prs.dt)));
            mobile(i).lfp = interp1(t_raw,lfp_raw,t_interp,'linear'); % resample to match behavioural recording
        end
    end
end

%% trials (theta-band analytic form)
[b,a] = butter(prs.lfp_filtorder,[prs.lfp_theta(1) prs.lfp_theta(2)]/(fs/2));
lfp_theta = filtfilt(b,a,lfp);
lfp_theta_analytic = hilbert(lfp_theta);
for i=1:ntrls
    if ~isnan(trialevents.t_beg(i))
        t_beg = trialevents.t_beg(i) + trials_behv.trials(i).events.t_beg_correction; % correction aligns t_beg with target onset
        t1 = trials_behv.trials(i).continuous.ts(1); % read lfp from first behavioural sample of trial i
        t2 = trials_behv.trials(i).continuous.ts(end); % till last behavioural sample of trial i
        lfp_raw = lfp_theta_analytic(ts > (t_beg + t1) & ts < (t_beg + t2)); t_raw = linspace(t1,t2,length(lfp_raw));
        trials(i).lfp_theta = interp1(t_raw,lfp_raw,trials_behv.trials(i).continuous.ts,'linear'); % theta-band LFP
    else
        trials(i).lfp_theta = nan(length(trials_behv.trials(i).continuous.ts),1);
    end
end

%% trials (beta-band analytic form)
[b,a] = butter(prs.lfp_filtorder,[prs.lfp_beta(1) prs.lfp_beta(2)]/(fs/2));
lfp_beta = filtfilt(b,a,lfp);
lfp_beta_analytic = hilbert(lfp_beta);
for i=1:ntrls
    if ~isnan(trialevents.t_beg(i))
        t_beg = trialevents.t_beg(i) + trials_behv.trials(i).events.t_beg_correction; % correction aligns t_beg with target onset
        t1 = trials_behv.trials(i).continuous.ts(1); % read lfp from first behavioural sample of trial i
        t2 = trials_behv.trials(i).continuous.ts(end); % till last behavioural sample of trial i
        lfp_raw = lfp_beta_analytic(ts > (t_beg + t1) & ts < (t_beg + t2)); t_raw = linspace(t1,t2,length(lfp_raw));
        trials(i).lfp_beta = interp1(t_raw,lfp_raw,trials_behv.trials(i).continuous.ts,'linear'); % beta-band LFP
    else
        trials(i).lfp_beta = nan(length(trials_behv.trials(i).continuous.ts),1);
    end
end

%% fixation period (raw)
% eyesfixed = struct(); count = 0;
% for i=1:ntrls
%     if ~isnan(trialevents.t_beg(i))
%         t_beg = trialevents.t_beg(i) + trials_behv.trials(i).events.t_beg_correction;
%         if ~isempty(trials_behv.trials(i).events.t_fix)
%             for k=1:numel(trials_behv.trials(i).events.t_fix)
%                 count = count + 1;
%                 t_fix = trials_behv.trials(i).events.t_fix(k);
%                 lfp_raw = lfp(ts > (t_beg + t_fix) & ts < (t_beg + t_fix + prs.fixateduration));
%                 t_raw = linspace(0,1,length(lfp_raw));
%                 t_interp = linspace(0,1,round(length(lfp_raw)*(dt/prs.dt)));
%                 eyesfixed(count).lfp = interp1(t_raw,lfp_raw,t_interp,'linear'); % resample to match behavioural recording
%             end
%         end
%     end
% end

%% Comparison periods
if prs.extract_motion_states
    %% eye move
    states = trials_behv.states; nfiles = numel(states);
    sMarkers = [];
    for i = 1:nfiles, sMarkers = [sMarkers ; states(i).free_sMarkers + trialevents.t_start(i)]; end
    eyesfree(size(sMarkers,1)) = struct();
    % extract lfp between sMarkers
    for i=1:size(sMarkers,1), eyesfree(i).lfp = lfp(ts>sMarkers(i,1) & ts<sMarkers(i,2)); end
    
    %% eye fixed
    states = trials_behv.states; nfiles = numel(states);
    sMarkers = [];
    for i = 1:nfiles, sMarkers = [sMarkers ; states(i).fixed_sMarkers + trialevents.t_start(i)]; end
    eyesfixed(size(sMarkers,1)) = struct();
    % extract lfp between sMarkers
    for i=1:size(sMarkers,1), eyesfixed(i).lfp = lfp(ts>sMarkers(i,1) & ts<sMarkers(i,2)); end
    
    %% eye move + mobile
    states = trials_behv.states; nfiles = numel(states);
    sMarkers = [];
    for i = 1:nfiles, sMarkers = [sMarkers ; states(i).free_mobile_sMarkers + trialevents.t_start(i)]; end
    eyesfree_mobile(size(sMarkers,1)) = struct();
    % extract lfp between sMarkers
    for i=1:size(sMarkers,1), eyesfree_mobile(i).lfp = lfp(ts>sMarkers(i,1) & ts<sMarkers(i,2)); end
    
    %% eye move + stationary
    states = trials_behv.states; nfiles = numel(states);
    sMarkers = [];
    for i = 1:nfiles, sMarkers = [sMarkers ; states(i).free_stationary_sMarkers + trialevents.t_start(i)]; end
    eyesfree_stationary(size(sMarkers,1)) = struct();
    % extract lfp between sMarkers
    for i=1:size(sMarkers,1), eyesfree_stationary(i).lfp = lfp(ts>sMarkers(i,1) & ts<sMarkers(i,2)); end
    
    %% eye fixed + mobile
    states = trials_behv.states; nfiles = numel(states);
    sMarkers = [];
    for i = 1:nfiles, sMarkers = [sMarkers ; states(i).fixed_mobile_sMarkers + trialevents.t_start(i)]; end
    eyesfixed_mobile(size(sMarkers,1)) = struct();
    % extract lfp between sMarkers
    for i=1:size(sMarkers,1), eyesfixed_mobile(i).lfp = lfp(ts>sMarkers(i,1) & ts<sMarkers(i,2)); end    
    
    %% eye fixed + stationary
    states = trials_behv.states; nfiles = numel(states);
    sMarkers = [];
    for i = 1:nfiles, sMarkers = [sMarkers ; states(i).fixed_stationary_sMarkers + trialevents.t_start(i)]; end
    eyesfixed_stationary(size(sMarkers,1)) = struct();
    % extract lfp between sMarkers
    for i=1:size(sMarkers,1), eyesfixed_stationary(i).lfp = lfp(ts>sMarkers(i,1) & ts<sMarkers(i,2)); end
    
end