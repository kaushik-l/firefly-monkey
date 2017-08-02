function [tseries, trials] = AddTrials2Unit(tspk,events_spk,events_smr,prs)

ntrls = events_smr.ntrls;
ntrls_cum = cumsum(ntrls);
ntrls_tot = sum(ntrls);
tspk = double(tspk)/prs.fs;

%% tseries
nsmr = length(ntrls);
for i=1:nsmr
    t_start = events_spk.t_start(i);
    t_end = t_start + events_smr.t_end(ntrls(i));
    tseries.smr(i).tspk = tspk(tspk>t_start & tspk<t_end) - t_start;
end

%% trials
trials(ntrls_tot) = struct();
for i=1:ntrls_tot
    t_start = events_spk.t_start(find(i<=ntrls_cum,1));
    trials(i).tspk = tspk(tspk > (t_start + events_smr.t_beg(i)) & tspk < (t_start + events_smr.t_end(i))) -...
        (t_start + events_smr.t_beg(i));
end