%% analyse units
function AnalyseUnits(this,prs)
    nunits = length(this.units);
    for i=1:nunits
        fprintf(['... Analysing unit ' num2str(i) ' :: ' this.units(i).type '\n']);
        this.units(i).AnalyseUnit(this.behaviours,this.lfps,prs);
    end
end