function trials = AddTrials2Unit(tspk,events_spk,trials_behv,prs)

pretrial = prs.pretrial;
posttrial = prs.posttrial;
ntrls = length(events_spk.t_end);
tspk = double(tspk)/prs.fs;

%% trials
trials(ntrls) = struct();
for i=1:ntrls
    t_beg = events_spk.t_beg(i);
    t_end = events_spk.t_end(i);
    t_move = trials_behv(i).continuous.ts(1);
    trials(i).tspk = tspk(tspk > (t_beg + t_move - pretrial) & tspk < (t_end + posttrial)) - t_beg;
end