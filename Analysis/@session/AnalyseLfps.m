%% analyse lfps
function AnalyseLfps(this,prs)
    nlfps = length(this.lfps);
    for i=1:nlfps
        fprintf(['... Analysing lfp ' num2str(i) ' :: channel ' num2str(this.lfps(i).channel_id) '\n']);
        this.lfps(i).AnalyseLfp(this.behaviours,prs);
    end
end