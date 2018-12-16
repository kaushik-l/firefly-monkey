%% function to plot LFP data
function PlotLFP(this,monk_id,sess_id,channel_id,electrode_id,plot_type)
    prs = default_prs(monk_id,sess_id);
    monk_ids = [this.sessions.monk_id];
    sess_ids = [this.sessions.sess_id];
    indx = (monk_ids == monk_id) & (sess_ids == sess_id);
    this.sessions(indx).PlotLFP(channel_id,electrode_id,plot_type,prs);
end