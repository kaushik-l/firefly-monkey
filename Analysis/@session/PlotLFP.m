%% plot LFP
function PlotLFP(this,channel_id,electrode_id,plot_type,prs)
    if ~isempty(electrode_id)
        PlotLFP(this.lfps,this.populations.lfps,electrode_id,plot_type,prs);
    elseif ~isempty(channel_id)
        if channel_id==0
            PlotLFP(this.lfps,this.populations.lfps,channel_id,plot_type,prs);
        else
            [~,electrode_id] = MapChannel2Electrode('utah96'); % hardcoding utah96 for now -- need to generalise
            PlotLFP(this.lfps,this.populations.lfps,electrode_id(channel_id),plot_type,prs);
        end
    end
end