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
        function AnalysePopulation(this,units,unittype,behaviours,lfps,prs)
            if strcmp(unittype,'units')
                if prs.fitGAM_tuning
                    this.(unittype).stats = AnalysePopulation(units,behaviours.trials,behaviours.stats,lfps,prs);
                else
                    this.(unittype).stats = AnalysePopulation(units,behaviours.trials,behaviours.stats,lfps,prs,[]);
                end
            elseif strcmp(unittype,'lfps')
                this.(unittype).stats = AnalysePopulation(units,behaviours.trials,behaviours.stats,lfps,prs);
            end
        end
    end
end