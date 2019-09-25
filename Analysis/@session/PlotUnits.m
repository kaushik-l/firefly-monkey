%% plot units
function PlotUnits(this,unit_id,plot_type,trial_type,prs)
    behv = this.behaviours;
    if ~iscell(unit_id) % plot specific unit
        if length(unit_id)~=1, error('unit id should be a positive integer'); end
        if ~strcmpi(plot_type(1:3),'gam')
            unit = this.units(unit_id);
            figure; hold on; suptitle(['m' num2str(this.monk_id) 's' num2str(this.sess_id) 'u' num2str(unit_id)]);
            PlotUnit(prs,behv,unit,plot_type,trial_type);        % plot data from one specific unit
        else
            conditions = this.populations.units.stats.trialtype.(trial_type); nconds = numel(conditions);
            for k=1:nconds, condition(k) = conditions(k).models.log.units(unit_id); end
            PlotUnit(prs,behv,condition,plot_type,trial_type);
        end
    else % plot all units
        if strcmp(unit_type,'units')
            PlotUnits(behv,this.units,plot_type,prs); % plot data from all units
        else
            PlotUnits(behv,this.units(strcmp({this.units.type},unit_type)),plot_type,prs); % plot data from all units
        end
    end
end