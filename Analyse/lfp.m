classdef lfp < handle
    %%
    properties
        monk_id
        session_id
        channel_no
        coord
        wave
    end
    %%
    methods
        %% class constructor
        function this = lfp(monk_id,session_id,channel_no,maxchannels,coord)
            this.monk_id = monk_id;
            this.session_id = session_id;
            this.channel_no = channel_no;
            this.get_coord(maxchannels,coord);
        end
        %% add row, col, depth of recording
        function get_coord(this,maxchannels,coord)
            this.coord = coord;
            this.coord.depth = coord.depth + (this.channel_no-maxchannels)*100;
        end
        %% add spike times
        function add_lfps(this,lfp,tstim,ntrls,prs)
            this.wave = addlfps(lfp,tstim,ntrls,prs);
        end
        %% analyse lfp
        function analyse_lfps(this,exp_name,prs)
        end
        %% destroy lfps
        function destroy_wave(this)
            this.wave = [];
        end
        %% plot
        function plot(this,lfp_num,exp_name,plottype)
            plotlfp(this,lfp_num,exp_name,plottype);
        end
    end
end