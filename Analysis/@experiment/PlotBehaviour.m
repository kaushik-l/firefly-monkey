%% function to plot behavioural data
function PlotBehaviour(this,monk_id,sess_id,plot_type)
    monk_ids = [this.sessions.monk_id];
    sess_ids = [this.sessions.sess_id];
    if sess_id ~= 0
        prs = default_prs(monk_id,sess_id);
        indx = (monk_ids == monk_id) & (sess_ids == sess_id);
        this.sessions(indx).PlotBehaviour(plot_type,prs);
    else
        prs = default_prs(monk_id);
        indx = find(monk_ids == monk_id);
        count = 0;
        for i=indx
            count = count + 1;
            behv(count) = this.sessions(i).behaviours;
        end
        PlotBehaviour(behv,plot_type,prs)
    end
end
