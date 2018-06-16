function trials = AddTrials2Unit(tspk,events_spk,trials_behv,prs)

pretrial = prs.pretrial;
posttrial = prs.posttrial;
ntrls = length(events_spk.t_end);
if isfield(prs,'fs_spk'), tspk = double(tspk)/prs.fs_spk; end % convert samples to times

%% trials
trials(ntrls) = struct();
for i=1:ntrls
    t_beg = events_spk.t_beg(i);
    t1 = trials_behv(i).continuous.ts(1); % read spikes from first behavioural sample of trial i
    t2 = trials_behv(i).continuous.ts(end); % till last behavioural sample of trial i
    trials(i).tspk = tspk(tspk > (t_beg + t1) & tspk < (t_beg + t2)) - t_beg;
end