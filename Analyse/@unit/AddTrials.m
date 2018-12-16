%% add spike times
function AddTrials(this,tspk,events_spk,behaviours,prs)
    this.trials = AddTrials2Unit(tspk,events_spk,behaviours.trials,prs);
end