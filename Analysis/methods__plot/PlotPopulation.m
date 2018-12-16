function PlotPopulation(behv,units,plot_type,prs)

%% parameters
binwidth_abs = prs.binwidth_abs;
binwidth_warp = prs.binwidth_warp;
trlkrnlwidth = prs.trlkrnlwidth;

correct = behv.stats.trialtype.reward(1).trlindx;
incorrect = behv.stats.trialtype.reward(2).trlindx;
crazy = ~(behv.stats.trialtype.all.trlindx);
indx_all = ~crazy;

% behavioural data
behv_all = behv.trials(~crazy); ntrls_all = length(behv_all);
behv_correct = behv.trials(correct); ntrls_correct = length(behv_correct);
behv_incorrect = behv.trials(incorrect); ntrls_incorrect = length(behv_incorrect);

%%
switch plot_type
    case 'GAM'
        units = units.stats.trialtype.all.models.log.units;
        nunits = length(units);        
end