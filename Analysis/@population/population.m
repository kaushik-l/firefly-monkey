classdef population < handle
    %%
    properties
        units
        singleunit
        multiunit
        lfps
    end
    
    %%
    methods
        %% class constructor
        function this = population()
            this.units = [];
            this.singleunit = [];
            this.multiunit = [];
            this.lfps =  [];
        end
    end
end