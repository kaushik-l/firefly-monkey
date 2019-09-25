classdef session < handle
    %%
    properties
        monk_id
        sess_id
        sess_date
        behaviours = behaviour.empty();                                     % trial
        units = unit.empty();                                               % single/multiunit
        lfps = lfp.empty();                                                 % lfp
        populations = population.empty();                                   % population
    end
    %%
    methods
        %% class constructor
        function this = session(monk_id,sess_id,sess_date)
            this.monk_id = monk_id;
            this.sess_id = sess_id;
            this.sess_date = sess_date;
        end
    end
end