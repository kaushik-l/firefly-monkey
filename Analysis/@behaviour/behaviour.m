classdef behaviour < handle
    %%
    properties
        comments
        trials
        epochs
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