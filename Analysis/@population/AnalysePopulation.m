%% function to add sessions
function AnalysePopulation(this,units,unittype,behaviours,lfps,prs)
    if strcmp(unittype,'units') || strcmp(unittype,'singleunit') || strcmp(unittype,'multiunit')
        if prs.fitGAM_tuning
            this.(unittype).stats = AnalysePopulation(units,behaviours.trials,behaviours.stats,lfps,prs);
        else
            this.(unittype).stats = AnalysePopulation(units,behaviours.trials,behaviours.stats,lfps,prs,[]);
        end
    elseif strcmp(unittype,'lfps')
        this.(unittype).stats = AnalysePopulation(units,behaviours.trials,behaviours.stats,lfps,prs);
    end
end