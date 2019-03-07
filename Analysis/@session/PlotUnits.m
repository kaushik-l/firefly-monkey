%% plot units
function PlotUnits(this,unit_id,unit_type,plot_type,prs)
    behv = this.behaviours;
    if length(unit_id)~=1
        error('unit id should be an non-negative integer');
    end
    if unit_id~=0
        if ~strcmp(plot_type,'GAM')
            unit = this.units(unit_id);
            figure; hold on; suptitle(['m' num2str(this.monk_id) 's' num2str(this.sess_id) 'u' num2str(unit_id)]);
            PlotUnit(behv,unit,plot_type,prs);        % plot data from one specific unit
        else
            unit = this.populations.(unit_type).stats.trialtype.all.models.log.units(unit_id);
            PlotUnit(behv,unit,plot_type,prs);
        end
    else
        if strcmp(unit_type,'units')
            PlotUnits(behv,this.units,plot_type,prs); % plot data from all units
        else
            PlotUnits(behv,this.units(strcmp({this.units.type},unit_type)),plot_type,prs); % plot data from all units
        end
    end
end