function trials = AddTrials2Lfp(lfp,fs,trialevents,trials_behv,prs)

pretrial = prs.pretrial;
posttrial = prs.posttrial;
ntrls = length(trialevents.t_end);
dt = 1/fs; 
nt = length(lfp);
ts = dt*(1:nt);

%% filter LFP
[b,a] = butter(prs.lfp_filtorder,[prs.lfp_freqmin prs.lfp_freqmax]/(fs/2));
lfp = filtfilt(b,a,lfp);

%% trials
trials(ntrls) = struct();
for i=1:ntrls
    t_beg = trialevents.t_beg(i) + trials_behv(i).events.t_beg_correction; % correction aligns t_beg with target onset
    t1 = trials_behv(i).continuous.ts(1); % read lfp from first behavioural sample of trial i
    t2 = trials_behv(i).continuous.ts(end); % till last behavioural sample of trial i
    lfp_raw = lfp(ts > (t_beg + t1) & ts < (t_beg + t2));
    t_raw = linspace(t1,t2,length(lfp_raw));
    trials(i).lfp = interp1(t_raw,lfp_raw,trials_behv(i).continuous.ts,'linear'); % resample to match behavioural recording
end