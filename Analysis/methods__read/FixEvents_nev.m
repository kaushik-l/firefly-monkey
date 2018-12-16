function events_nev = FixEvents_nev(events_nev,behv_trials)

events_smr = cell2mat({behv_trials.events});
ntrls_smr = length(events_smr);
ntrls_nev = length(events_nev.t_beg);
if (ntrls_smr - ntrls_nev) < 0
    warning('Mismatch in number of trials in NEV and SMR -- could not fix the problem!');
else
    ntrls_missed = ntrls_smr - ntrls_nev;
    % check if neural recording was not started on time
    iti_smr = diff([events_smr.t_beg]); iti_smr = iti_smr((ntrls_missed+1):end);
    iti_nev = diff(events_nev.t_beg);
    badindx = (iti_smr>10 | iti_nev>10);
    iti_smr = iti_smr(~badindx); iti_nev = iti_nev(~badindx);
    if corr(iti_smr(:),iti_nev(:)) > 0.99 % this level of corr. is unlikely by chance
        warning('Mismatch in number of trials in NEV and SMR -- problem most likely fixed!');
        % yes, neural recording was not started on time
        events_nev.t_beg = [nan(1,ntrls_missed) events_nev.t_beg];
        events_nev.t_end = [nan(1,ntrls_missed) events_nev.t_end];
    end
end

