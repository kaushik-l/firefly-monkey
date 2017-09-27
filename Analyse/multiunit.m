classdef multiunit < handle
    %%
    properties
        channel_no
        spkwf
        trials
        stats
        weights
    end
    %%
    methods
        %% class constructor
        function this = multiunit(unit)
            this.channel_no = []; %unit.chnl;
            this.spkwf = []; %mean(unit.spkwf);
        end
        %% add spike times
        function AddTrials(this,tspk,events_spk,behaviours,prs)
            this.trials = AddTrials2Unit(tspk,events_spk,behaviours.trials,prs);
        end
        %% analyse spikes
        function AnalyseUnit(this,behaviours,prs)
            [this.trials,this.stats] = AnalyseRates(this.trials,behaviours.trials,behaviours.stats,prs);
%             this.weights = ComputeWeights(exp_name,this.trials,behaviours.trials,prs); % requires neuroGLM package: https://github.com/pillowlab/neuroGLM
        end
        %% destroy spike times
        function destroy_spks(this)
            this.spks = [];
            this.tspk = [];
        end
    end
end