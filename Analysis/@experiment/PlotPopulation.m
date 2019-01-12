%% function to plot neural population data
function PlotPopulation(this,monk_id,sess_id,unit_type,plot_type)
    if monk_id~=0 && sess_id ~= 0
        prs = default_prs(monk_id,sess_id);
        monk_ids = [this.sessions.monk_id];
        sess_ids = [this.sessions.sess_id];
        indx = (monk_ids == monk_id) & (sess_ids == sess_id);
        this.sessions(indx).PlotPopulation(unit_type,plot_type,prs);
    elseif monk_id ~= 0 && sess_id == 0
        prs = default_prs(monk_id,this.sessions(1).sess_id);
        monk_ids = [this.sessions.monk_id];
        indx = (monk_ids == monk_id);
        PlotSessions(this.sessions(indx),unit_type,plot_type,prs);
    elseif monk_id == 0 && sess_id == 0
        prs = default_prs(this.sessions(1).monk_id,this.sessions(1).sess_id);
    else, error('monkey id needs to be specified if sess_id = 0');
    end
end