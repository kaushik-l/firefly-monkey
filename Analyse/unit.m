classdef unit < handle
    %%
    properties
        channel_no
        spkwf
        type
        trials
        stats
    end
    %%
    methods
        %% class constructor
        function this = unit(unittype)
            this.channel_no = []; %unit.chnl;
            this.spkwf = []; %mean(unit.spkwf);
            this.type = unittype;
        end
        %% add spike times
        function AddTrials(this,tspk,events_spk,behaviours,prs)
            this.trials = AddTrials2Unit(tspk,events_spk,behaviours.trials,prs);
        end
        %% analyse spikes
        function AnalyseUnit(this,behaviours,prs)
            this.stats = AnalyseRates(this.trials,behaviours.trials,behaviours.stats,prs);
%             this.weights = FitGLM(this.trials,behaviours.trials,behaviours.stats,prs); % requires neuroGLM package: https://github.com/pillowlab/neuroGLM
%             [this.trials,this.stats] = PredictGLM(this.weights,this.trials,this.stats,behaviours.trials,behaviours.stats,prs); % requires neuroGLM package: https://github.com/pillowlab/neuroGLM
        end
    end
end