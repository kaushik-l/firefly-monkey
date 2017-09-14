function trials = AddTrials2Unit(tspk,events_spk,prs)

ntrls = length(events_spk.t_end);
tspk = double(tspk)/prs.fs;

%% trials
trials(ntrls) = struct();
for i=1:ntrls
    trials(i).tspk = tspk(tspk > (events_spk.t_beg(i) - prs.pretrial) & tspk < (events_spk.t_end(i) +  prs.posttrial)) - (events_spk.t_beg(i));
end