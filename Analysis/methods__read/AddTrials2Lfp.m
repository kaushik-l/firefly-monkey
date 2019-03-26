function [trials_lfp, epochs_lfp] = AddTrials2Lfp(lfp,fs,trialevents,behv,prs)

ntrls = length(trialevents.t_end);
trials_lfp(ntrls) = struct(); 

%% filter LFP
[b,a] = butter(prs.lfp_filtorder,[prs.lfp_freqmin 75]/(fs/2));
lfp = filtfilt(b,a,lfp);
if fs > prs.fs_lfp, N = round(fs/prs.fs_lfp); lfp = downsample(lfp,N); end

%%
dt = 1/prs.fs_lfp;
nt = length(lfp);
ts = dt*(1:nt);

%% trials (raw)
trials_lfp(ntrls) = struct();
for i=1:ntrls
    if ~isnan(trialevents.t_beg(i))
        t_beg = trialevents.t_beg(i) + behv.trials(i).events.t_beg_correction; % correction aligns t_beg with target onset
        t1 = behv.trials(i).continuous.ts(1); % read lfp from first behavioural sample of trial i
        t2 = behv.trials(i).continuous.ts(end); % till last behavioural sample of trial i
        lfp_raw = lfp(ts > (t_beg + t1) & ts < (t_beg + t2)); 
        t_raw = linspace(t1,t2,length(lfp_raw));
        trials_lfp(i).lfp = interp1(t_raw,lfp_raw,behv.trials(i).continuous.ts,'linear'); % resample to match behavioural recording
    else
        trials_lfp(i).lfp = nan(length(behv.trials(i).continuous.ts),1);
    end
end

%% trials (theta-band analytic form)
[b,a] = butter(prs.lfp_filtorder,[prs.lfp_theta(1) prs.lfp_theta(2)]/(fs/2));
lfp_theta = filtfilt(b,a,lfp);
lfp_theta_analytic = hilbert(lfp_theta);
for i=1:ntrls
    if ~isnan(trialevents.t_beg(i))
        t_beg = trialevents.t_beg(i) + behv.trials(i).events.t_beg_correction; % correction aligns t_beg with target onset
        t1 = behv.trials(i).continuous.ts(1); % read lfp from first behavioural sample of trial i
        t2 = behv.trials(i).continuous.ts(end); % till last behavioural sample of trial i
        lfp_raw = lfp_theta_analytic(ts > (t_beg + t1) & ts < (t_beg + t2)); t_raw = linspace(t1,t2,length(lfp_raw));
        trials_lfp(i).lfp_theta = interp1(t_raw,lfp_raw,behv.trials(i).continuous.ts,'linear'); % theta-band LFP
    else
        trials_lfp(i).lfp_theta = nan(length(behv.trials(i).continuous.ts),1);
    end
end


%% trials (beta-band analytic form)
[b,a] = butter(prs.lfp_filtorder,[prs.lfp_beta(1) prs.lfp_beta(2)]/(fs/2));
lfp_beta = filtfilt(b,a,lfp);
lfp_beta_analytic = hilbert(lfp_beta);
for i=1:ntrls
    if ~isnan(trialevents.t_beg(i))
        t_beg = trialevents.t_beg(i) + behv.trials(i).events.t_beg_correction; % correction aligns t_beg with target onset
        t1 = behv.trials(i).continuous.ts(1); % read lfp from first behavioural sample of trial i
        t2 = behv.trials(i).continuous.ts(end); % till last behavioural sample of trial i
        lfp_raw = lfp_beta_analytic(ts > (t_beg + t1) & ts < (t_beg + t2)); t_raw = linspace(t1,t2,length(lfp_raw));
        trials_lfp(i).lfp_beta = interp1(t_raw,lfp_raw,behv.trials(i).continuous.ts,'linear'); % beta-band LFP
    else
        trials_lfp(i).lfp_beta = nan(length(behv.trials(i).continuous.ts),1);
    end
end

%% extract epochs corresponding to movement (of both eyes and self) periods
if prs.analyse_lfpepochs
    %% stationary period (raw)
    epochs_lfp.stationary(ntrls-1) = struct(); % obviously only N-1 inter-trials
    for i=1:ntrls-1
        if ~isnan(trialevents.t_beg(i))
            t_beg1 = trialevents.t_beg(i) + behv.trials(i).events.t_beg_correction;
            t_beg2 = trialevents.t_beg(i+1) + behv.trials(i+1).events.t_beg_correction;
            t_stop = t_beg1 + behv.trials(i).events.t_stop;
            t_move = t_beg2 + behv.trials(i+1).events.t_move;
            if (t_move-t_stop) > prs.min_stationary + prs.dt
                lfp_raw = lfp(ts > t_stop & ts < t_move);
                t_raw = linspace(0,1,length(lfp_raw));
                t_interp = linspace(0,1,round(length(lfp_raw)*(dt/prs.dt)));
                epochs_lfp.stationary(i).lfp = interp1(t_raw,lfp_raw,t_interp,'linear'); % resample to match behavioural recording
            end
        end
    end
    
    %% motion period (raw)
    epochs_lfp.mobile(ntrls) = struct(); % obviously only N-1 inter-trials
    for i=1:ntrls
        if ~isnan(trialevents.t_beg(i))
            t_beg = trialevents.t_beg(i) + behv.trials(i).events.t_beg_correction;
            t_move = t_beg + behv.trials(i).events.t_move;
            t_stop = t_beg + behv.trials(i).events.t_stop;
            if (t_stop-t_move) > prs.min_mobile + prs.dt
                lfp_raw = lfp(ts > t_move & ts < t_stop);
                t_raw = linspace(0,1,length(lfp_raw));
                t_interp = linspace(0,1,round(length(lfp_raw)*(dt/prs.dt)));
                epochs_lfp.mobile(i).lfp = interp1(t_raw,lfp_raw,t_interp,'linear'); % resample to match behavioural recording
            end
        end
    end
    
    %% eye move
    epochs_behv = behv.epochs; nfiles = numel(epochs_behv);
    sMarkers = []; if nfiles ~= numel(trialevents.t_start), nfiles = numel(trialevents.t_start); end
    for i = 1:nfiles,  if ~isempty(epochs_behv(i).free), sMarkers = [sMarkers ; epochs_behv(i).free + trialevents.t_start(i)]; end, end
    if ~isempty(sMarkers),epochs_lfp.eyesfree(size(sMarkers,1)) = struct();
        % extract lfp between sMarkers
        for i=1:size(sMarkers,1), epochs_lfp.eyesfree(i).lfp = lfp(ts>sMarkers(i,1) & ts<sMarkers(i,2)); end
    else
        epochs_lfp.eyesfree.lfp = [];
    end
    
    %% eye fixed
    epochs_behv = behv.epochs; nfiles = numel(epochs_behv);
    sMarkers = []; if nfiles ~= numel(trialevents.t_start), nfiles = numel(trialevents.t_start); end
    if nfiles ~= numel(trialevents.t_start), nfiles = numel(trialevents.t_start); end
    for i = 1:nfiles, if ~isempty(epochs_behv(i).fixed), sMarkers = [sMarkers ; epochs_behv(i).fixed + trialevents.t_start(i)];end, end
    if ~isempty(sMarkers), epochs_lfp.eyesfixed(size(sMarkers,1)) = struct();
        % extract lfp between sMarkers
        for i=1:size(sMarkers,1), epochs_lfp.eyesfixed(i).lfp = lfp(ts>sMarkers(i,1) & ts<sMarkers(i,2)); end
    else
        epochs_lfp.eyesfixed.lfp = [];
    end
        
    %% eye move + mobile
    epochs_behv = behv.epochs; nfiles = numel(epochs_behv);
    sMarkers = []; if nfiles ~= numel(trialevents.t_start), nfiles = numel(trialevents.t_start); end
    for i = 1:nfiles, if ~isempty(epochs_behv(i).free_mobile), sMarkers = [sMarkers ; epochs_behv(i).free_mobile + trialevents.t_start(i)]; end, end
    if ~isempty(sMarkers), epochs_lfp.eyesfree_mobile(size(sMarkers,1)) = struct();
        % extract lfp between sMarkers
        for i=1:size(sMarkers,1), epochs_lfp.eyesfree_mobile(i).lfp = lfp(ts>sMarkers(i,1) & ts<sMarkers(i,2)); end
    else
        epochs_lfp.eyesfree_mobile.lfp = [];
    end
    
    %% eye move + stationary
    epochs_behv = behv.epochs; nfiles = numel(epochs_behv);
    sMarkers = []; if nfiles ~= numel(trialevents.t_start), nfiles = numel(trialevents.t_start); end
    for i = 1:nfiles, if ~isempty(epochs_behv(i).free_stationary), sMarkers = [sMarkers ; epochs_behv(i).free_stationary + trialevents.t_start(i)];end, end
    if ~isempty(sMarkers),epochs_lfp.eyesfree_stationary(size(sMarkers,1)) = struct();
        % extract lfp between sMarkers
        for i=1:size(sMarkers,1), epochs_lfp.eyesfree_stationary(i).lfp = lfp(ts>sMarkers(i,1) & ts<sMarkers(i,2)); end
    else
        epochs_lfp.eyesfree_stationary.lfp = [];
    end
    
    %% eye fixed + mobile
    epochs_behv = behv.epochs; nfiles = numel(epochs_behv);
    sMarkers = []; if nfiles ~= numel(trialevents.t_start), nfiles = numel(trialevents.t_start); end
    for i = 1:nfiles, if ~isempty(epochs_behv(i).fixed_mobile), sMarkers = [sMarkers ; epochs_behv(i).fixed_mobile + trialevents.t_start(i)];end, end
    if ~isempty(sMarkers), epochs_lfp.eyesfixed_mobile(size(sMarkers,1)) = struct();
        % extract lfp between sMarkers
        for i=1:size(sMarkers,1), epochs_lfp.eyesfixed_mobile(i).lfp = lfp(ts>sMarkers(i,1) & ts<sMarkers(i,2)); end
    else
        epochs_lfp.eyesfixed_mobile.lfp = [];
    end
    
    %% eye fixed + stationary
    epochs_behv = behv.epochs; nfiles = numel(epochs_behv);
    sMarkers = []; if nfiles ~= numel(trialevents.t_start), nfiles = numel(trialevents.t_start); end
    for i = 1:nfiles, if ~isempty(epochs_behv(i).fixed_stationary), sMarkers = [sMarkers ; epochs_behv(i).fixed_stationary + trialevents.t_start(i)];end, end
    if ~isempty(sMarkers), epochs_lfp.eyesfixed_stationary(size(sMarkers,1)) = struct();
        % extract lfp between sMarkers
        for i=1:size(sMarkers,1), epochs_lfp.eyesfixed_stationary(i).lfp = lfp(ts>sMarkers(i,1) & ts<sMarkers(i,2)); end
    else
        epochs_lfp.eyesfixed_stationary.lfp = [];
    end
    
end

%% extract epochs around events
if prs.analyse_eventtriggeredlfp
    epochlength = prs.eventtriggeredepochlength;
    trials_behv = behv.trials; events_behv = [trials_behv.events];
    
    %% epochs aligned to fixation
    nevents = 0;
    for i=1:ntrls
        if ~isnan(trialevents.t_beg(i))
            t_beg = trialevents.t_beg(i) + behv.trials(i).events.t_beg_correction; % correction aligns t_beg with target onset
            for j=1:length(events_behv(i).t_fix)
                nevents = nevents + 1;
                epochs_lfp.fixationevent(nevents).lfp = ...
                    lfp(ts>(t_beg + events_behv(i).t_fix(j) - epochlength/2) & ts<(t_beg + events_behv(i).t_fix(j) + epochlength/2));
                epochs_lfp.fixationevent(nevents).lfp_theta = ...
                    lfp_theta_analytic(ts>(t_beg + events_behv(i).t_fix(j) - epochlength/2) & ts<(t_beg + events_behv(i).t_fix(j) + epochlength/2));
                epochs_lfp.fixationevent(nevents).lfp_beta = ...
                    lfp_beta_analytic(ts>(t_beg + events_behv(i).t_fix(j) - epochlength/2) & ts<(t_beg + events_behv(i).t_fix(j) + epochlength/2));
            end
        end
    end
    
    % remove epochs with extra/missing samples
    nt = unique(cellfun(@(x) numel(x), {epochs_lfp.fixationevent.lfp}));
    if nt>1, for i=1:length(nt), if sum(cellfun(@(x) numel(x), {epochs_lfp.fixationevent.lfp}) == nt(i)) < 0.05*numel({epochs_lfp.fixationevent.lfp})
                epochs_lfp.fixationevent(cellfun(@(x) numel(x), {epochs_lfp.fixationevent.lfp})==nt(i)) = [];
                epochs_lfp.fixationevent(cellfun(@(x) numel(x), {epochs_lfp.fixationevent.lfp_theta})==nt(i)) = [];
                epochs_lfp.fixationevent(cellfun(@(x) numel(x), {epochs_lfp.fixationevent.lfp_beta})==nt(i)) = []; end; end; end
    
    %% epochs aligned to saccade
    nevents = 0;
    for i=1:ntrls
        if ~isnan(trialevents.t_beg(i))
            t_beg = trialevents.t_beg(i) + behv.trials(i).events.t_beg_correction; % correction aligns t_beg with target onset
            for j=1:length(events_behv(i).t_sac)
                nevents = nevents + 1;
                epochs_lfp.saccadicevent(nevents).lfp = ...
                    lfp(ts>(t_beg + events_behv(i).t_sac(j) - epochlength/2) & ts<(t_beg + events_behv(i).t_sac(j) + epochlength/2));
                epochs_lfp.saccadicevent(nevents).lfp_theta = ...
                    lfp_theta_analytic(ts>(t_beg + events_behv(i).t_sac(j) - epochlength/2) & ts<(t_beg + events_behv(i).t_sac(j) + epochlength/2));
                epochs_lfp.saccadicevent(nevents).lfp_beta = ...
                    lfp_beta_analytic(ts>(t_beg + events_behv(i).t_sac(j) - epochlength/2) & ts<(t_beg + events_behv(i).t_sac(j) + epochlength/2));
            end
        end
    end
    
    % remove epochs with extra/missing samples
    nt = unique(cellfun(@(x) numel(x), {epochs_lfp.saccadicevent.lfp}));
    if nt>1, for i=1:length(nt), if sum(cellfun(@(x) numel(x), {epochs_lfp.saccadicevent.lfp}) == nt(i)) < 0.05*numel({epochs_lfp.saccadicevent.lfp})
                epochs_lfp.saccadicevent(cellfun(@(x) numel(x), {epochs_lfp.saccadicevent.lfp})==nt(i)) = [];
                epochs_lfp.saccadicevent(cellfun(@(x) numel(x), {epochs_lfp.saccadicevent.lfp_theta})==nt(i)) = [];
                epochs_lfp.saccadicevent(cellfun(@(x) numel(x), {epochs_lfp.saccadicevent.lfp_beta})==nt(i)) = []; end; end; end
    
end