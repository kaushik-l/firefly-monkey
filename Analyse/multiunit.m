classdef multiunit < handle
    %%
    properties
        channel_no
        spkwf
        trials
        corrgrams
    end
    %%
    methods
        %% class constructor
        function this = multiunit(unit)
            this.channel_no = []; %unit.chnl;
            this.spkwf = []; %mean(unit.spkwf);
        end
        %% add spike times
        function AddTrials(this,tspk,events_spk,prs)
            this.trials = AddTrials2Unit(tspk,events_spk,prs);
        end
        %% analyse spikes
        function AnalyseUnit(this,exp_name,behaviours,prs)
            [this.trials,this.corrgrams] = ...
                AnalyseUnit(exp_name,this.trials,behaviours.trials,prs);
        end
        %% destroy spike times
        function destroy_spks(this)
            this.spks = [];
            this.tspk = [];
        end
    end
end