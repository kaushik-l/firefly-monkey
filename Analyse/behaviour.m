classdef behaviour < handle
    %%
    properties
        comments
        trials
        stats
    end    
    %%
    methods
        %% class constructor
        function this = behaviour(comments)
            this.comments = comments;
        end
        %% add trials
        function AddTrials(this,prs)
            cd(prs.filepath_behv);
            this.trials = AddTrials2Behaviour(prs);
        end
        %% change datatype (to save memory)
        function UseDatatype(this,data_type)
            UseDatatype_behv(this,data_type);
        end
        %% analyse behaviour
        function AnalyseBehaviour(this,prs)
            this.stats = AnalyseBehaviour(this.trials,prs);
        end
    end
end