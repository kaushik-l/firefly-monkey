%% add lfps
function AddTrials(this,lfp,fs,eventtimes,behaviours,prs)
     [this.trials, this.stationary, this.mobile, this.eyesfixed, this.eyesfree, this.eyesfree_mobile , this.eyesfree_stationary, this.eyesfixed_mobile, this.eyesfixed_stationary] = AddTrials2Lfp(lfp,fs,eventtimes,behaviours,prs);
end