%% function to plot neural data
function PlotUnits(this,monk_id,sess_id,unit_id,plot_type,trial_type)
    prs = default_prs(monk_id,sess_id);
    monk_ids = [this.sessions.monk_id];
    sess_ids = [this.sessions.sess_id];
    indx = (monk_ids == monk_id) & (sess_ids == sess_id);
    if nargin<6, trial_type = 'all'; end
    this.sessions(indx).PlotUnits(unit_id,plot_type,trial_type,prs);
end