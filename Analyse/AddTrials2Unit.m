function trials = AddTrials2Unit(tspk,trialevents,trials_behv,prs)

pretrial = prs.pretrial;
posttrial = prs.posttrial;
ntrls = length(trialevents.t_end);
if isfield(prs,'fs_spk'), tspk = double(tspk)/prs.fs_spk; end % convert samples to times

%% trials
trials(ntrls) = struct();
for i=1:ntrls
    if ~isnan(trialevents.t_beg(i))
        t_beg = trialevents.t_beg(i) + trials_behv(i).events.t_beg_correction; % correction aligns t_beg with target onset
        t1 = trials_behv(i).continuous.ts(1); % read spikes from first behavioural sample of trial i
        t2 = trials_behv(i).continuous.ts(end); % till last behavioural sample of trial i
        trials(i).tspk = tspk(tspk > (t_beg + t1) & tspk < (t_beg + t2)) - t_beg;
    end
end