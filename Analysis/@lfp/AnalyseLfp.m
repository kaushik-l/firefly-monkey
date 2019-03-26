%% analyse spikes
function AnalyseLfp(this,behaviours,prs)
    this.stats = AnalyseLfp(this.trials,this.epochs,behaviours.trials,behaviours.stats,prs);
end