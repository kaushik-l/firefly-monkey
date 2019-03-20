%% function to add sessions
function AddSessions(this,monk_id,sess_id,content,ovwrt) % e.g. content = {'behv','lfps','units','pop'}
    islfps = any(strcmp(content,'lfps')); isunits = any(strcmp(content,'units')); ispop = any(strcmp(content,'pop'));
    allsessions = this.sessions; old_instance = find([allsessions.monk_id] == monk_id & [allsessions.sess_id] == sess_id);
    if ~isempty(old_instance)
        if (nargin < 5) || (ovwrt~=0 && ovwrt~=1)
            ovwrt = logical(input('This session was already analysed once. Press 1 to overwrite, 0 to quit \n'));
        end
        if ~ovwrt, return;
        else, new_instance = old_instance; % overwrite old instance
        end
    else        
        %% make new instance
        new_instance = numel(allsessions) + 1;
    end
    prs = default_prs(monk_id,sess_id);
    this.sessions(new_instance) = session(monk_id,sess_id,prs.coord);
    this.sessions(new_instance).AddBehaviours(prs);
    if islfps
        this.sessions(new_instance).AddLfps(prs);
        this.sessions(new_instance).AnalyseLfps(prs);
    end
    if isunits
        this.sessions(new_instance).AddUnits(prs);
        this.sessions(new_instance).AnalyseUnits(prs);
    end
    if ispop && isunits, this.sessions(new_instance).AddPopulation('units',prs);
    elseif ispop && islfps, this.sessions(new_instance).AddPopulation('lfps',prs);
    end
end