classdef behaviour < handle
    %%
    properties
        comments
        tseries
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
            flist_smr=dir('*.smr'); nfile = length(flist_smr);
            flist_log=dir('*.log');
            flist_mat=dir('*.mat');
            for i=1:length(flist_smr)
                fprintf(['... reading ' flist_smr(i).name '\n']);
                data_smr = ImportSMR(flist_smr(i).name);
                [this.tseries.smr(i),trials_temp] = AddSMRData(data_smr,prs);
                trials_temp = AddLOGData(flist_log(i).name,trials_temp);
                trials_temp = AddMATData(flist_mat(i).name,trials_temp);
                this.trials = [this.trials trials_temp];
                clear trials_temp;
            end
        end
        %% analyse behaviour
        function AnalyseBehaviour(this,prs)
            this.stats = AnalyseBehaviour(this.trials,prs);
        end
    end
end