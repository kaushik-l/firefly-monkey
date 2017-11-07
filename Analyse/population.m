classdef population < handle
    %%
    properties
        units
        singleunits
        multiunits
        lfps
    end
    
    %%
    methods
        %% function to add sessions
        function AnalysePopulation(this,units,unittype,behaviours,prs)
            this.(unittype) = AnalysePopulation(units,behaviours.trials,behaviours.stats,prs);
        end
    end
end