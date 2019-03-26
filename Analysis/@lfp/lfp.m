classdef lfp < handle
    %%
    properties
        channel_id
        electrode_id
        trials
        epochs
        stats
    end
    %%
    methods
        %% class constructor
        function this = lfp(channel_id,electrode_id)
            this.channel_id = channel_id;
            this.electrode_id = electrode_id;
        end
    end
end