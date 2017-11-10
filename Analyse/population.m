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
        %% class constructor
        function this = population()
            this.units = [];
            this.singleunits = [];
            this.multiunits = [];
            this.lfps = [];
        end
        %% function to add sessions
        function AnalysePopulation(this,units,unittype,behaviours,prs)
            this.(unittype).stats = AnalysePopulation(units,behaviours.trials,behaviours.stats,prs);
        end
    end
end