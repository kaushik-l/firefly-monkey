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
        function AddSessions(this,monk_id,sess_id,content) % e.g. content = {'behv','lfps','units','pop'}
            islfps = strcmp(content,'lfps'); isunits = strcmp(content,'units'); ispop = strcmp(content,'pop');
            allsessions = this.sessions; old_instance = find([allsessions.monk_id] == monk_id & [allsessions.sess_id] == sess_id);
            if ~isempty(old_instance)
                ovwrt = logical(input('This session was already analysed once. Press 1 to overwrite, 0 to quit \n'));
                if ovwrt
                    %% overwrite old instance
                    prs = default_prs(monk_id,sess_id);
                    this.sessions(old_instance).AddBehaviours(prs);
                    if islfps
                        this.sessions(old_instance).AddLfps(prs);
                        this.sessions(old_instance).AnalyseLfps(prs);
                    end
                    if isunits
                        this.sessions(old_instance).AddUnits(prs);
                        this.sessions(old_instance).AnalyseUnits(prs);
                    end
                    if ispop && isunits, this.sessions(old_instance).AddPopulation('units',prs);
                    elseif ispop && islfps, this.sessions(old_instance).AddPopulation('lfps',prs);
                    end
                end
            else
                %% make new instance
                prs = default_prs(monk_id,sess_id);
                this.sessions(end+1) = session(monk_id,sess_id,prs.coord);
                this.sessions(end).AddBehaviours(prs);
                if islfps
                    this.sessions(end).AddLfps(prs);
                    this.sessions(end).AnalyseLfps(prs);
                end
                if isunits
                    this.sessions(end).AddUnits(prs);
                    this.sessions(end).AnalyseUnits(prs);
                end
                if ispop && isunits, this.sessions(end).AddPopulation('units',prs);
                elseif ispop && islfps, this.sessions(end).AddPopulation('lfps',prs);
                end
            end
        end
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
        %% function to plot neural data
        function PlotUnits(this,monk_id,sess_id,unit_id,plot_type)
            prs = default_prs(monk_id,sess_id);
            monk_ids = [this.sessions.monk_id];
            sess_ids = [this.sessions.sess_id];
            indx = (monk_ids == monk_id) & (sess_ids == sess_id);
            this.sessions(indx).PlotUnits(unit_id,plot_type,prs);
        end
        %% function to plot LFP data
        function PlotLFP(this,monk_id,sess_id,channel_id,electrode_id,plot_type)
            prs = default_prs(monk_id,sess_id);
            monk_ids = [this.sessions.monk_id];
            sess_ids = [this.sessions.sess_id];
            indx = (monk_ids == monk_id) & (sess_ids == sess_id);
            this.sessions(indx).PlotLFP(channel_id,electrode_id,plot_type,prs);
        end
        %% function to plot neural population data
        function PlotPopulation(this,monk_id,sess_id,unit_type,plot_type)
            prs = default_prs(monk_id,sess_id);
            monk_ids = [this.sessions.monk_id];
            sess_ids = [this.sessions.sess_id];
            indx = (monk_ids == monk_id) & (sess_ids == sess_id);
            this.sessions(indx).PlotPopulation(unit_type,plot_type,prs);
        end
    end
end