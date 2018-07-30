classdef unit < handle
    %%
    properties
        channel_id
        spkwf
        type
        trials
        stats
    end
    %%
    methods
        %% class constructor
        function this = unit(unittype)
            this.channel_id = []; %unit.chnl;
            this.spkwf = []; %mean(unit.spkwf);
            this.type = unittype;
        end
        %% add spike times
        function AddTrials(this,tspk,events_spk,behaviours,prs)
            this.trials = AddTrials2Unit(tspk,events_spk,behaviours.trials,prs);
        end
        %% analyse spikes
        function AnalyseUnit(this,behaviours,prs)
            this.stats = AnalyseUnit(this.trials,behaviours.trials,behaviours.stats,prs);
        end
    end
end