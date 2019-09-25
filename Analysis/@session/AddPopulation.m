%% add populations
function AddPopulation(this,unittype,prs)
    this.populations(end+1) = population();
    if strcmp(unittype,'lfps')
        this.populations.AnalysePopulation(this.lfps,'lfps',this.behaviours,this.lfps,prs);
    elseif strcmp(unittype,'units')
        this.populations.AnalysePopulation(this.units,'units',this.behaviours,this.lfps,prs);
    elseif strcmp(unittype,'singleunit')
        this.populations.AnalysePopulation(this.units(strcmp({this.units.type},'singleunit')),'singleunit',this.behaviours,this.lfps,prs);
    elseif strcmp(unittype,'multiunit')
        this.populations.AnalysePopulation(this.units(strcmp({this.units.type},'multiunit')),'multiunit',this.behaviours,this.lfps,prs);
    end
end