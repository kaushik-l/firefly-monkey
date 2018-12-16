%% plot population
function PlotPopulation(this,unit_type,plot_type,prs)
    behv = this.behaviours;
    PlotPopulation(behv,this.populations.(unit_type),plot_type,prs);
end