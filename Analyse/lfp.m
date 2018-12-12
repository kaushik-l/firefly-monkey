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
        stats
    end
    %%
    methods
        %% class constructor
        function this = lfp(channel_id,electrode_id)
            this.channel_id = channel_id;
            this.electrode_id = electrode_id;
        end
        %% add lfps
        function AddTrials(this,lfp,fs,eventtimes,behaviours,prs)
            [this.trials, this.stationary, this.mobile, this.eyesfixed, this.eyesfree] = AddTrials2Lfp(lfp,fs,eventtimes,behaviours.trials,prs);
        end
        %% analyse spikes
        function AnalyseLfp(this,behaviours,prs)
            this.stats = AnalyseLfp(this.trials,this.stationary,this.mobile,this.eyesfixed,this.eyesfree,behaviours.trials,behaviours.stats,prs);
        end
    end
end