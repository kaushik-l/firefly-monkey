%% analyse spikes
function AnalyseUnit(this,behaviours,lfps,prs)
    prs.channel_id = this.channel_id; % slip in the channel_id property into prs for analysis
    this.stats = AnalyseUnit(this.trials,behaviours.trials,behaviours.stats,lfps,prs);
end