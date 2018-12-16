classdef experiment < handle
    %%
    properties
        name                                                                % protocol
        sessions = session.empty();
    end
     
    %%
    methods
        %% class constructor
        function this = experiment(exp_name)
            this.name = exp_name;
        end
    end
end