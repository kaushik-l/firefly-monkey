function trials = AddTrials2Unit(tspk,events_spk,events_smr,prs)

ntrls = events_smr.ntrls;
ntrls_tot = sum(ntrls);
t_start = events_spk.t_start;
for i=1:ntrls_tot
    trials(i).tspk = tspk(tspk > t_events.beg(i)-0.5 & tspk < t_events.end(i)) - t_events.beg(i);
    trials(i).t_rew = t_events.rew(i) - t_events.beg(i);
    trials(i).t_end = t_events.end(i) - t_events.beg(i);
end