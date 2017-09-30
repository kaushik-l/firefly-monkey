function [trials_spks,stats_spks] = PredictGLM(weights,trials_spks,stats_spks,trials_behv,stats_behv,prs)

varlookup = prs.varlookup;
vars = fields(weights.mu);
nvars = length(vars);
ntrls = length(trials_behv);

% predict
for i = 1:ntrls
    nt = length(trials_behv(i).ts);
    trials_spks(i).nspk_predglm.total = exp(zeros(nt,1)); % initialise prediction
    for j=1:nvars
        if strcmp(vars{j},'spikehist'), continue; % cannot predict using spikehistory only
        else
            trials_spks(i).nspk_predglm.(vars{j}) = exp(conv(trials_behv(i).(varlookup(vars{j})),weights.mu.(vars{j}).data,'same')); % component prediction
            trials_spks(i).nspk_predglm.total = trials_spks(i).nspk_predglm.total.*trials_spks(i).nspk_predglm.(vars{j}); % total prediction
        end
    end
end