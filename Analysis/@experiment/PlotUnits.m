%% function to plot neural data
function PlotUnits(this,monk_id,sess_id,unit_id,plot_type)
    prs = default_prs(monk_id,sess_id);
    monk_ids = [this.sessions.monk_id];
    sess_ids = [this.sessions.sess_id];
    indx = (monk_ids == monk_id) & (sess_ids == sess_id);
    this.sessions(indx).PlotUnits(unit_id,plot_type,prs);
end