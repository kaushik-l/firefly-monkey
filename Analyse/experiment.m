classdef experiment < handle
    %%
    properties
        name                                                                % protocol
        sessions = session.empty();
    end
    
    %%
    methods
        %% class constructor
        function this = experiment(exp_name)
            this.name = exp_name;
        end
        %% function to add sessions
        function AddSessions(this,monk_id,sess_id)
            prs = default_prs(monk_id,sess_id);
            this.sessions(end+1) = session(monk_id,sess_id,prs.coord);
            this.sessions(end).AddBehaviours(prs);
            this.sessions(end).AddUnits(prs);
        end
        %% function to plot data
        function Plot(this,monk_id,sess_id,unit_type,unit_id,plot_type)
            prs = default_prs(monk_id,sess_id);
            monk_ids = [this.sessions.monk_id];
            sess_ids = [this.sessions.sess_id];
            indx = (monk_ids == monk_id) & (sess_ids == sess_id);
            this.sessions(indx).PlotUnits(unit_type,unit_id,plot_type,prs);
        end
    end
end