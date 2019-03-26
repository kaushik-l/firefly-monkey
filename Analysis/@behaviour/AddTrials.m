%% add trials
function AddTrials(this,prs)
    cd(prs.filepath_behv);
    [this.trials, this.epochs] = AddTrials2Behaviour(prs);
end