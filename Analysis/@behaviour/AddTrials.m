%% add trials
function AddTrials(this,prs)
    cd(prs.filepath_behv);
    this.trials = AddTrials2Behaviour(prs);
end