classdef lfp < handle
    %%
    properties
        channel_id
        electrode_id
        electrode_type
        brain_area
        trials
        stationary
        mobile
        eyesfixed
        eyesfree
        stats
    end
    %%
    methods
        %% class constructor
        function this = lfp(channel_id,electrode_id,electrode_type)
            this.channel_id = channel_id;
            this.electrode_id = electrode_id;
            this.electrode_type = electrode_type;
        end
    end
end