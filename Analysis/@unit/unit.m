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
    end
end