%% add lfps
function AddTrials(this,lfp,fs,eventtimes,behaviours,prs)
    [this.trials, this.stationary, this.mobile, this.eyesfixed, this.eyesfree] = AddTrials2Lfp(lfp,fs,eventtimes,behaviours.trials,prs);
end