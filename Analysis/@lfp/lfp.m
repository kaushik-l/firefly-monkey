classdef lfp < handle
    %%
    properties
        channel_id
        electrode_id
        trials
        stationary
        mobile
        eyesfixed
        eyesfree
        eyesfree_mobile
        eyesfree_stationary
        eyesfixed_mobile
        eyesfixed_stationary
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