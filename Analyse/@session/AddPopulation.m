%% add populations
function AddPopulation(this,unittype,prs)
    this.populations(end+1) = population();
    if strcmp(unittype,'lfps')
        this.populations.AnalysePopulation(this.lfps,'lfps',this.behaviours,this.lfps,prs);
    elseif ~strcmp(unittype,'units')
        this.populations.AnalysePopulation(this.units(strcmp({this.units.type},unittype)),unittype,this.behaviours,this.lfps,prs);
    else
        this.populations.AnalysePopulation(this.units,unittype,this.behaviours,this.lfps,prs);
    end
end