%% analyse spikes
function AnalyseLfp(this,behaviours,prs)
    this.stats = AnalyseLfp(this.trials,this.stationary,this.mobile,this.eyesfixed,this.eyesfree,behaviours.trials,behaviours.stats,prs);
end