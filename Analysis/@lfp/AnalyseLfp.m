%% analyse spikes
function AnalyseLfp(this,behaviours,prs)
    this.stats = AnalyseLfp(this.trials,this.stationary,this.mobile,this.eyesfixed,this.eyesfree,this.eyesfixed_mobile,this.eyesfixed_stationary,this.eyesfree_mobile,this.eyesfree_stationary,behaviours.trials,behaviours.stats,prs);
end