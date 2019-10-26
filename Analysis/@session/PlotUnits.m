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
        conditions = this.units(unit_id).stats.trialtype.(trial_type); nconds = numel(conditions);
        for k=1:nconds, condition(k) = conditions(k).GAM.log; end
        PlotUnit(prs,behv,condition,plot_type,trial_type);
    end
else % plot all units
    units = this.units;
    selectedunits = true;
    for k = 1:numel(unit_id), selectedunits = logical(selectedunits.*(strcmpi({units.brain_area} ,unit_id{k}) + strcmpi({units.type} ,unit_id{k}))); end
    if ~strcmpi(plot_type(1:3),'gam')        
        PlotUnits(prs,behv,units(selectedunits),plot_type,trial_type); % plot data from all units
    else
        conditions = this.populations.units.stats.trialtype.(trial_type); nconds = numel(conditions);
        for k=1:nconds, condition{k} = conditions(k).models.log.units(selectedunits); end
    end
end