%% add behaviour
function AddBehaviours(this,prs)
    cd(prs.filepath_behv);
    this.behaviours = behaviour(prs.comments);
    this.behaviours.AddTrials(prs);
    this.behaviours.AnalyseBehaviour(prs);
    this.behaviours.UseDatatype('single');
end