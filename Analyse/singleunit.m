classdef singleunit < handle
    %%
    properties
        channel_no
        spkwf
        trials
    end
    %%
    methods
        %% class constructor
        function this = singleunit(unit)
            this.channel_no = unit.chnl;
            this.spkwf = mean(unit.spkwf);
        end
        %% add spike times
        function AddTrials(this,tspk,t_events,prs)
            this.trials = AddTrials2Unit(tspk,t_events,prs);
        end
        %% analyse spikes
        function analyse_spks(this,exp_name,prs)
            
        end
        %% destroy spike times
        function destroy_spks(this)
            this.spks = [];
            this.tspk = [];
        end
        %% plot
        function plot(this,unit_num,exp_name,plottype)
            plotunit(this,unit_num,exp_name,plottype);
        end
    end
end