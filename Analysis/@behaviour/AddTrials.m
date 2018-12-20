%% add trials
function AddTrials(this,prs)
    cd(prs.filepath_behv);
    [this.trials, this.states] = AddTrials2Behaviour(prs);
end