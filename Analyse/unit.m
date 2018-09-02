classdef unit < handle
    %%
    properties
        cluster_id
        channel_id
        electrode_id
        spkwf
        spkwidth
        type
        trials
        stats
    end
    %%
    methods
        %% class constructor
        function this = unit(unittype,unit,Fs)
            this.cluster_id = unit.cluster_id;
            this.channel_id = unit.channel_id;
            this.electrode_id = unit.electrode_id;
            this.spkwf = unit.spkwf; %mean spike-waveform;     
            this.spkwidth = Compute_SpikeWidth(unit.spkwf,Fs);
            this.type = unittype;
        end
        %% add spike times
        function AddTrials(this,tspk,events_spk,behaviours,prs)
            this.trials = AddTrials2Unit(tspk,events_spk,behaviours.trials,prs);
        end
        %% analyse spikes
        function AnalyseUnit(this,behaviours,lfps,prs)
            prs.channel_id = this.channel_id; % slip in the channel_id property into prs for analysis
            this.stats = AnalyseUnit(this.trials,behaviours.trials,behaviours.stats,lfps,prs);
        end
    end
end