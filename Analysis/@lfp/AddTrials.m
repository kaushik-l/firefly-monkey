%% add lfps
function AddTrials(this,lfp,fs,eventtimes,behaviours,prs)
     [this.trials, this.epochs] = AddTrials2Lfp(lfp,fs,eventtimes,behaviours,prs);
end