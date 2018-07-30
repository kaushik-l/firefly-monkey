classdef lfp < handle
    %%
    properties
        channel_id
        trials
        stats
    end
    %%
    methods
        %% class constructor
        function this = lfp(channel_id)
            this.channel_id = channel_id;
        end
        %% add lfps
        function AddTrials(this,lfp,fs,eventtimes,behaviours,prs)
            this.trials = AddTrials2Lfp(lfp,fs,eventtimes,behaviours.trials,prs);
        end
        %% analyse spikes
        function AnalyseLfp(this,behaviours,prs)
            this.stats = AnalyseLfp(this.trials,behaviours.trials,behaviours.stats,prs);
        end
    end
end