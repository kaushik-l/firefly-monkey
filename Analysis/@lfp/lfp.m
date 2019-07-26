classdef lfp < handle
    %%
    properties
        channel_id
        electrode_id
        electrode_type
        brain_area
        coord
        trials
        epochs
        stats
    end
    %%
    methods
        %% class constructor
        function this = lfp(channel_id,electrode_id,electrode_type,brain_area,coord)
            this.channel_id = channel_id;
            this.electrode_id = electrode_id;
            this.electrode_type = electrode_type;
            this.brain_area = brain_area;
            this.coord = coord;
        end
    end
end