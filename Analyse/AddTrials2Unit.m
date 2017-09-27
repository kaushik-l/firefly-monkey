function trials = AddTrials2Unit(tspk,events_spk,trials_behv,prs)

ntrls = length(events_spk.t_end);
tspk = double(tspk)/prs.fs;

%% trials
trials(ntrls) = struct();
for i=1:ntrls
    trials(i).tspk = tspk(tspk > (events_spk.t_beg(i) + trials_behv(i).ts(1)) & tspk < (events_spk.t_end(i))) - (events_spk.t_beg(i));
end