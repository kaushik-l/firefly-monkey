%% plot population
function PlotPopulation(this,unit_type,plot_type,prs)
    behv = this.behaviours;
    if isempty(unit_type), unit_type={'singleunit','multiunit'}; end
    PlotPopulation(behv,this.populations.units,find(strcmp({this.units.type},unit_type)),plot_type,prs);
end