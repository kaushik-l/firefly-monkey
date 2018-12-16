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