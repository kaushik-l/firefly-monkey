classdef behaviour < handle
    %%
    properties
        comments
        trials
        stats
    end    
    %%
    methods
        %% class constructor
        function this = behaviour(comments)
            this.comments = comments;
        end
    end
end