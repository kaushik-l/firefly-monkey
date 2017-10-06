function [trials_spks,stats_spks] = PredictGLM(weights,trials_spks,stats_spks,trials_behv,stats_behv,prs)

varlookup = prs.varlookup;
saccadeduration = prs.saccadeduration;
vars = fields(weights.mu);
nvars = length(vars);
ntrls = length(trials_behv);
nsim = prs.nsim;

% component-wise prediction
for i = 1:ntrls
    ts = trials_behv(i).ts;
    nt = length(trials_behv(i).ts);
    for j=1:nvars
        if strcmp(vars{j},'spikehist'), continue; % cannot predict using spikehistory only
        else
            switch vars{j}
                case 'saccade'
                    ts = trials_behv(i).ts; saccade = zeros(length(ts),1);
                    t_sac = trials_behv(i).t_sac;
                    for k=1:length(t_sac)
                        saccade(ts>t_sac(k) & ts<t_sac(k)+saccadeduration) = 1;
                    end
                    trials_spks(i).nspk_predglm.(vars{j}) = exp(conv(saccade,weights.mu.(vars{j}).data)); % component prediction
                    trials_spks(i).nspk_predglm.(vars{j}) = trials_spks(i).nspk_predglm.(vars{j})(1:length(ts));
                case {'linacc','angacc'}
                    trials_spks(i).nspk_predglm.(vars{j}) = exp(conv([0; diff(trials_behv(i).(varlookup(vars{j})))],weights.mu.(vars{j}).data)); % component prediction
                    trials_spks(i).nspk_predglm.(vars{j}) = trials_spks(i).nspk_predglm.(vars{j})(1:length(ts));
                case {'linvel','angvel','firefly','horeye','vereye'}
                    trials_spks(i).nspk_predglm.(vars{j}) = exp(conv(trials_behv(i).(varlookup(vars{j})),weights.mu.(vars{j}).data)); % component prediction
                    trials_spks(i).nspk_predglm.(vars{j}) = trials_spks(i).nspk_predglm.(vars{j})(1:length(ts));
                case {'dist2fly','dist2stop'}
                    trials_spks(i).nspk_predglm.(vars{j}) = exp(conv(stats_behv.pos_rel.(varlookup(vars{j})){i},weights.mu.(vars{j}).data)); % component prediction
                    trials_spks(i).nspk_predglm.(vars{j}) = trials_spks(i).nspk_predglm.(vars{j})(1:length(ts));
            end
        end
    end
end

% full prediction
for i=1:ntrls
    ts = trials_behv(i).ts;
    nt = length(trials_behv(i).ts);
    trials_spks(i).nspk_predglm.total = exp(zeros(nt,1)); % initialise prediction
    for j=1:length(vars)
        trials_spks(i).nspk_predglm.total = trials_spks(i).nspk_predglm.total.*trials_spks(i).nspk_predglm.(vars{j});
    end
end

% variance explained
nspk = struct2mat(trials_spks,'nspk','start');
trials_predglm = cell2mat({trials_spks.nspk_predglm});
vars = fields(trials_predglm);
for i=1:length(vars)
    nspk_glmpred = struct2mat(trials_predglm,vars{i},'start');
    stats_spks.varexp.(vars{i}) = 1 - var(nanmean((nspk - nspk_glmpred)))./var(nanmean(nspk));
end