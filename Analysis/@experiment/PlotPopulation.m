%% function to plot neural population data
function PlotPopulation(this,monk_id,sess_id,unit_type,plot_type)
    prs = default_prs(monk_id,sess_id);
    monk_ids = [this.sessions.monk_id];
    sess_ids = [this.sessions.sess_id];
    indx = (monk_ids == monk_id) & (sess_ids == sess_id);
    this.sessions(indx).PlotPopulation(unit_type,plot_type,prs);
end