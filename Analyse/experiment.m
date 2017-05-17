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
        function AddSessions(this,monk_id,session_id)
            prs = default_prs(monk_id,session_id);
            this.sessions(end+1) = session(monk_id,session_id,prs.coord);
            this.sessions(end).AddTrials(prs);
            this.sessions(end).AnalyseBehaviour(prs);
            this.sessions(end).AddUnits(prs);
        end
        %% function to plot data
        function Plot(this,monk_id,sess_id,unit_id)
            monk_ids = [this.sessions.monk_id];
            sess_ids = [this.sessions.session_id];
            data = this.sessions((monk_ids == monk_id) & (sess_ids == sess_id));
            plotdata(data,unit_id);
        end
    end
end