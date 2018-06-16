function eye_movement = AnalyseEyemovement(x_fly,y_fly,zle,yle,zre,yre,t_sac,t_stop,ts,trlerrors,prs)

%% prs
delta = prs.interoculardist/2;
zt = -prs.height;
saccade_duration = prs.saccade_duration;
fly_ONduration = prs.fly_ONduration;
Nboots = prs.bootstrap_trl;
factor_downsample = 1; %prs.factor_downsample; % downsampling factor for storage
ntrls = length(x_fly);

%% sort trials by error
[~,errorindx] = sort(trlerrors);

%% eye position immediately after the first saccade following target onset
for i=1:ntrls
    % identify time of target fixation
    sacstart = []; sacend = []; sacampli = [];
    t_sac2 = t_sac{i};
    sac_indx = t_sac{i}>0 & t_sac{i}<2*fly_ONduration;
    if any(sac_indx)
        t_sacs = t_sac{i}(sac_indx);
        for j=1:length(t_sacs)
            sacstart(j) = find(ts{i}>(t_sacs(j)), 1);
            sacend(j) = find(ts{i}>(t_sacs(j) + saccade_duration), 1);
            sacampli(j) = nanmean([sum(abs(zle{i}(sacstart(j)) - zle{i}(sacend(j)))^2 + abs(yle{i}(sacstart(j)) - yle{i}(sacend(j)))^2) ...
                sum(abs(zre{i}(sacstart(j)) - zre{i}(sacend(j)))^2 + abs(yre{i}(sacstart(j)) - yre{i}(sacend(j)))^2)]);
        end
        t_fix(i) = t_sacs(sacampli == max(sacampli)) + saccade_duration/2;
    else, t_fix(i) = 0 + saccade_duration/2; 
    end % if no saccade detected, assume monkey was already fixating on target
    % remove saccade periods from eye position data
    sacstart = []; sacend = []; 
    for j=1:length(t_sac2)
        sacstart(j) = find(ts{i}>(t_sac2(j) - saccade_duration/2), 1);
        sacend(j) = find(ts{i}>(t_sac2(j) + saccade_duration/2), 1);
        xt{i}(sacstart(j):sacend(j)) = nan;  % fly x - position
        yle{i}(sacstart(j):sacend(j)) = nan; % left eye horizontal position
        yre{i}(sacstart(j):sacend(j)) = nan; % right eye horizontal position
        yt{i}(sacstart(j):sacend(j)) = nan;  % fly y - position
        zle{i}(sacstart(j):sacend(j)) = nan; % left eye vertical position
        zre{i}(sacstart(j):sacend(j)) = nan; % right eye vertical position
    end
    % select data between target fixation and end of movement
    xt{i} = x_fly{i}(ts{i}>t_fix(i) & ts{i}<t_stop(i)); yt{i} = y_fly{i}(ts{i}>t_fix(i) & ts{i}<t_stop(i));
    yle{i} = yle{i}(ts{i}>t_fix(i) & ts{i}<t_stop(i)); yre{i} = yre{i}(ts{i}>t_fix(i) & ts{i}<t_stop(i));
    zle{i} = zle{i}(ts{i}>t_fix(i) & ts{i}<t_stop(i)); zre{i} = zre{i}(ts{i}>t_fix(i) & ts{i}<t_stop(i));
    
    % ground truth prediction for eye position (if the monkey really followed the target)
    yle_pred{i} = atan2d(xt{i} + delta, sqrt(yt{i}.^2 + zt^2));
    yre_pred{i} = atan2d(xt{i} - delta, sqrt(yt{i}.^2 + zt^2));
    zle_pred{i} = atan2d(zt , sqrt(yt{i}.^2 + (xt{i} + delta).^2));
    zre_pred{i} = atan2d(zt , sqrt(yt{i}.^2 + (xt{i} - delta).^2));
    ver_mean_pred{i} = nanmean([zle_pred{i} , zre_pred{i}],2); % mean vertical eye position (of the two eyes)
    hor_mean_pred{i} = nanmean([yle_pred{i} , yre_pred{i}],2); % mean horizontal eye position
    ver_diff_pred{i} = 0.5*(zle_pred{i} - zre_pred{i}); % 0.5*difference between vertical eye positions (of the two eyes)
    hor_diff_pred{i} = 0.5*(yle_pred{i} - yre_pred{i}); % 0.5*difference between horizontal eye positions
    % actual eye position
    ver_mean{i} = nanmean([zle{i} , zre{i}],2); % mean vertical eye position (of the two eyes)
    hor_mean{i} = nanmean([yle{i} , yre{i}],2); % mean horizontal eye position
    ver_diff{i} = 0.5*(zle{i} - zre{i}); % 0.5*difference between vertical eye positions (of the two eyes)
    hor_diff{i} = 0.5*(yle{i} - yre{i}); % 0.5*difference between horizontal eye positions
    % fly position
    rt{i} = sqrt(xt{i}.^2 + yt{i}.^2);
    thetat{i} = atan2d(xt{i},yt{i});
end

%% regression
for i=1:ntrls
    eye_movement.flypos.r{i} = downsample(rt{i},factor_downsample);
    eye_movement.flypos.theta{i} = downsample(thetat{i},factor_downsample);
    eye_movement.eyepos.pred.ver_mean.val{i} = downsample(ver_mean_pred{i},factor_downsample);
    eye_movement.eyepos.pred.hor_mean.val{i} = downsample(hor_mean_pred{i},factor_downsample);
    eye_movement.eyepos.pred.ver_diff.val{i} = downsample(ver_diff_pred{i},factor_downsample);
    eye_movement.eyepos.pred.hor_diff.val{i} = downsample(hor_diff_pred{i},factor_downsample);
    eye_movement.eyepos.true.ver_mean.val{i} = downsample(ver_mean{i},factor_downsample);
    eye_movement.eyepos.true.hor_mean.val{i} = downsample(hor_mean{i},factor_downsample);
    eye_movement.eyepos.true.ver_diff.val{i} = downsample(ver_diff{i},factor_downsample);
    eye_movement.eyepos.true.hor_diff.val{i} = downsample(hor_diff{i},factor_downsample);
end

Nt = max(cellfun(@(x) length(x),rt)); % max number of timepoints
% temporal correlation between fly position & predicted eye position -
% aligned to target fixation
rt1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],rt,'UniformOutput',false));
thetat1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],thetat,'UniformOutput',false));

ver_mean_pred1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],ver_mean_pred,'UniformOutput',false));
hor_mean_pred1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],hor_mean_pred,'UniformOutput',false));
ver_diff_pred1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],ver_diff_pred,'UniformOutput',false));
hor_diff_pred1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],hor_diff_pred,'UniformOutput',false));
[eye_movement.eyepos.pred.ver_mean.rho.r.startaligned,eye_movement.eyepos.pred.ver_mean.pval.r.startaligned] = arrayfun(@(i) corr(rt1(i,:)',ver_mean_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.hor_mean.rho.r.startaligned,eye_movement.eyepos.pred.hor_mean.pval.r.startaligned] = arrayfun(@(i) corr(rt1(i,:)',hor_mean_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.ver_diff.rho.r.startaligned,eye_movement.eyepos.pred.ver_diff.pval.r.startaligned] = arrayfun(@(i) corr(rt1(i,:)',ver_diff_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.hor_diff.rho.r.startaligned,eye_movement.eyepos.pred.hor_diff.pval.r.startaligned] = arrayfun(@(i) corr(rt1(i,:)',hor_diff_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.ver_mean.rho.theta.startaligned,eye_movement.eyepos.pred.ver_mean.pval.theta.startaligned] = arrayfun(@(i) corr(thetat1(i,:)',ver_mean_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.hor_mean.rho.theta.startaligned,eye_movement.eyepos.pred.hor_mean.pval.theta.startaligned] = arrayfun(@(i) corr(thetat1(i,:)',hor_mean_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.ver_diff.rho.theta.startaligned,eye_movement.eyepos.pred.ver_diff.pval.theta.startaligned] = arrayfun(@(i) corr(thetat1(i,:)',ver_diff_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.hor_diff.rho.theta.startaligned,eye_movement.eyepos.pred.hor_diff.pval.theta.startaligned] = arrayfun(@(i) corr(thetat1(i,:)',hor_diff_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);

% temporal correlation between fly position & true eye position -
% aligned to target fixation
ver_mean1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],ver_mean,'UniformOutput',false));
hor_mean1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],hor_mean,'UniformOutput',false));
ver_diff1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],ver_diff,'UniformOutput',false));
hor_diff1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],hor_diff,'UniformOutput',false));
[eye_movement.eyepos.true.ver_mean.rho.r.startaligned,eye_movement.eyepos.true.ver_mean.pval.r.startaligned] = arrayfun(@(i) corr(rt1(i,:)',ver_mean1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.hor_mean.rho.r.startaligned,eye_movement.eyepos.true.hor_mean.pval.r.startaligned] = arrayfun(@(i) corr(rt1(i,:)',hor_mean1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.ver_diff.rho.r.startaligned,eye_movement.eyepos.true.ver_diff.pval.r.startaligned] = arrayfun(@(i) corr(rt1(i,:)',ver_diff1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.hor_diff.rho.r.startaligned,eye_movement.eyepos.true.hor_diff.pval.r.startaligned] = arrayfun(@(i) corr(rt1(i,:)',hor_diff1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.ver_mean.rho.theta.startaligned,eye_movement.eyepos.true.ver_mean.pval.theta.startaligned] = arrayfun(@(i) corr(thetat1(i,:)',ver_mean1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.hor_mean.rho.theta.startaligned,eye_movement.eyepos.true.hor_mean.pval.theta.startaligned] = arrayfun(@(i) corr(thetat1(i,:)',hor_mean1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.ver_diff.rho.theta.startaligned,eye_movement.eyepos.true.ver_diff.pval.theta.startaligned] = arrayfun(@(i) corr(thetat1(i,:)',ver_diff1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.hor_diff.rho.theta.startaligned,eye_movement.eyepos.true.hor_diff.pval.theta.startaligned] = arrayfun(@(i) corr(thetat1(i,:)',hor_diff1(i,:)','Type','Spearman','rows','complete'), 1:Nt);

% timecourse of cosine similarity between predicted & true eye position -
% aligned to target fixation
[eye_movement.eyepos.pred_vs_true.ver_mean.rho.startaligned,eye_movement.eyepos.pred_vs_true.ver_mean.pval.startaligned] = arrayfun(@(i) corr(ver_mean1(i,:)',ver_mean_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.hor_mean.rho.startaligned,eye_movement.eyepos.pred_vs_true.hor_mean.pval.startaligned] = arrayfun(@(i) corr(hor_mean1(i,:)',hor_mean_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.ver_diff.rho.startaligned,eye_movement.eyepos.pred_vs_true.ver_diff.pval.startaligned] = arrayfun(@(i) corr(ver_diff1(i,:)',ver_diff_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.hor_diff.rho.startaligned,eye_movement.eyepos.pred_vs_true.hor_diff.pval.startaligned] = arrayfun(@(i) corr(hor_diff1(i,:)',hor_diff_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
pred = permute(cat(3,ver_mean_pred1 , hor_mean_pred1 , hor_diff_pred1),[3 1 2]);
true = permute(cat(3,ver_mean1 , hor_mean1 , hor_diff1),[3 1 2]);
cos_similarity = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrls,ntrls,1);
    cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls)), 1:Nt);
end
eye_movement.eyepos.pred_vs_true.cos_similarity.mu.startaligned = mean(cos_similarity);
eye_movement.eyepos.pred_vs_true.cos_similarity.sem.startaligned = std(cos_similarity);

% timecourse of cosine similarity between predicted & true eye position -
% trials grouped by error magnitude
ngroups = 5;
ntrls_per_group = (ntrls - mod(ntrls,ngroups))/ngroups;
errorindx = errorindx(1:ntrls_per_group*ngroups);
cos_similarity = nan(ngroups,Nt);
for i=1:ngroups
    trlgroup = errorindx(ntrls_per_group*(i-1) + 1:ntrls_per_group*i);
    cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,trlgroup),true(:,i,trlgroup)), 1:Nt);
end
eye_movement.eyepos.pred_vs_true.cos_similarity_vs_error.mu.startaligned = cos_similarity;

% timecourse of centered cosine similarity between predicted & true eye position -
% aligned to target fixation
[eye_movement.eyepos.pred_vs_true.ver_mean.rho.startaligned,eye_movement.eyepos.pred_vs_true.ver_mean.pval.startaligned] = arrayfun(@(i) corr(ver_mean1(i,:)',ver_mean_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.hor_mean.rho.startaligned,eye_movement.eyepos.pred_vs_true.hor_mean.pval.startaligned] = arrayfun(@(i) corr(hor_mean1(i,:)',hor_mean_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.ver_diff.rho.startaligned,eye_movement.eyepos.pred_vs_true.ver_diff.pval.startaligned] = arrayfun(@(i) corr(ver_diff1(i,:)',ver_diff_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.hor_diff.rho.startaligned,eye_movement.eyepos.pred_vs_true.hor_diff.pval.startaligned] = arrayfun(@(i) corr(hor_diff1(i,:)',hor_diff_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
pred = permute(cat(3,ver_mean_pred1 , hor_mean_pred1 , hor_diff_pred1),[3 1 2]); pred = (pred - repmat(nanmean(pred,3),[1 1 ntrls]))./repmat(nanstd(pred,[],3),[1 1 ntrls]);
true = permute(cat(3,ver_mean1 , hor_mean1 , hor_diff1),[3 1 2]); true = (true - repmat(nanmean(true,3),[1 1 ntrls]))./repmat(nanstd(true,[],3),[1 1 ntrls]);
cntr_cos_similarity = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrls,ntrls,1);
    cntr_cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls)), 1:Nt);
end
eye_movement.eyepos.pred_vs_true.cntr_cos_similarity.mu.startaligned = mean(cntr_cos_similarity);
eye_movement.eyepos.pred_vs_true.cntr_cos_similarity.sem.startaligned = std(cntr_cos_similarity);

% temporal correlation between fly position & predicted eye position -
% aligned to end of movement
rt2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],rt,'UniformOutput',false));
thetat2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],thetat,'UniformOutput',false));

ver_mean_pred2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],ver_mean_pred,'UniformOutput',false));
hor_mean_pred2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],hor_mean_pred,'UniformOutput',false));
ver_diff_pred2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],ver_diff_pred,'UniformOutput',false));
hor_diff_pred2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],hor_diff_pred,'UniformOutput',false));
[eye_movement.eyepos.pred.ver_mean.rho.r.stopaligned,eye_movement.eyepos.pred.ver_mean.pval.r.stopaligned] = arrayfun(@(i) corr(rt2(i,:)',ver_mean_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.hor_mean.rho.r.stopaligned,eye_movement.eyepos.pred.hor_mean.pval.r.stopaligned] = arrayfun(@(i) corr(rt2(i,:)',hor_mean_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.ver_diff.rho.r.stopaligned,eye_movement.eyepos.pred.ver_diff.pval.r.stopaligned] = arrayfun(@(i) corr(rt2(i,:)',ver_diff_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.hor_diff.rho.r.stopaligned,eye_movement.eyepos.pred.hor_diff.pval.r.stopaligned] = arrayfun(@(i) corr(rt2(i,:)',hor_diff_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.ver_mean.rho.theta.stopaligned,eye_movement.eyepos.pred.ver_mean.pval.theta.stopaligned] = arrayfun(@(i) corr(thetat2(i,:)',ver_mean_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.hor_mean.rho.theta.stopaligned,eye_movement.eyepos.pred.hor_mean.pval.theta.stopaligned] = arrayfun(@(i) corr(thetat2(i,:)',hor_mean_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.ver_diff.rho.theta.stopaligned,eye_movement.eyepos.pred.ver_diff.pval.theta.stopaligned] = arrayfun(@(i) corr(thetat2(i,:)',ver_diff_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred.hor_diff.rho.theta.stopaligned,eye_movement.eyepos.pred.hor_diff.pval.theta.stopaligned] = arrayfun(@(i) corr(thetat2(i,:)',hor_diff_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);

% temporal correlation between fly position & true eye position -
% aligned to end of movement
ver_mean2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],ver_mean,'UniformOutput',false));
hor_mean2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],hor_mean,'UniformOutput',false));
ver_diff2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],ver_diff,'UniformOutput',false));
hor_diff2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],hor_diff,'UniformOutput',false));
[eye_movement.eyepos.true.ver_mean.rho.r.stopaligned,eye_movement.eyepos.true.ver_mean.pval.r.stopaligned] = arrayfun(@(i) corr(rt2(i,:)',ver_mean2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.hor_mean.rho.r.stopaligned,eye_movement.eyepos.true.hor_mean.pval.r.stopaligned] = arrayfun(@(i) corr(rt2(i,:)',hor_mean2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.ver_diff.rho.r.stopaligned,eye_movement.eyepos.true.ver_diff.pval.r.stopaligned] = arrayfun(@(i) corr(rt2(i,:)',ver_diff2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.hor_diff.rho.r.stopaligned,eye_movement.eyepos.true.hor_diff.pval.r.stopaligned] = arrayfun(@(i) corr(rt2(i,:)',hor_diff2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.ver_mean.rho.theta.stopaligned,eye_movement.eyepos.true.ver_mean.pval.theta.stopaligned] = arrayfun(@(i) corr(thetat2(i,:)',ver_mean2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.hor_mean.rho.theta.stopaligned,eye_movement.eyepos.true.hor_mean.pval.theta.stopaligned] = arrayfun(@(i) corr(thetat2(i,:)',hor_mean2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.ver_diff.rho.theta.stopaligned,eye_movement.eyepos.true.ver_diff.pval.theta.stopaligned] = arrayfun(@(i) corr(thetat2(i,:)',ver_diff2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.true.hor_diff.rho.theta.stopaligned,eye_movement.eyepos.true.hor_diff.pval.theta.stopaligned] = arrayfun(@(i) corr(thetat2(i,:)',hor_diff2(i,:)','Type','Spearman','rows','complete'), 1:Nt);

% timecourse of cosine similarity between predicted & true eye position -
% aligned to end of movement
[eye_movement.eyepos.pred_vs_true.ver_mean.rho.stopaligned,eye_movement.eyepos.pred_vs_true.ver_mean.pval.stopaligned] = arrayfun(@(i) corr(ver_mean2(i,:)',ver_mean_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.hor_mean.rho.stopaligned,eye_movement.eyepos.pred_vs_true.hor_mean.pval.stopaligned] = arrayfun(@(i) corr(hor_mean2(i,:)',hor_mean_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.ver_diff.rho.stopaligned,eye_movement.eyepos.pred_vs_true.ver_diff.pval.stopaligned] = arrayfun(@(i) corr(ver_diff2(i,:)',ver_diff_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.hor_diff.rho.stopaligned,eye_movement.eyepos.pred_vs_true.hor_diff.pval.stopaligned] = arrayfun(@(i) corr(hor_diff2(i,:)',hor_diff_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
pred = permute(cat(3,ver_mean_pred2 , hor_mean_pred2 , hor_diff_pred2),[3 1 2]);
true = permute(cat(3,ver_mean2 , hor_mean2 , hor_diff2),[3 1 2]);
cos_similarity = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrls,ntrls,1);
    cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls)), 1:Nt);
end
eye_movement.eyepos.pred_vs_true.cos_similarity.mu.stopaligned = mean(cos_similarity);
eye_movement.eyepos.pred_vs_true.cos_similarity.sem.stopaligned = std(cos_similarity);

% timecourse of cosine similarity between predicted & true eye position -
% trials grouped by error magnitude
ngroups = 5;
ntrls_per_group = (ntrls - mod(ntrls,ngroups))/ngroups;
errorindx = errorindx(1:ntrls_per_group*ngroups);
cos_similarity = nan(ngroups,Nt);
for i=1:ngroups
    trlgroup = errorindx(ntrls_per_group*(i-1) + 1:ntrls_per_group*i);
    cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,trlgroup),true(:,i,trlgroup)), 1:Nt);
end
eye_movement.eyepos.pred_vs_true.cos_similarity_vs_error.mu.stopaligned = cos_similarity;

% timecourse of centered cosine similarity between predicted & true eye position -
% aligned to end of movement
[eye_movement.eyepos.pred_vs_true.ver_mean.rho.stopaligned,eye_movement.eyepos.pred_vs_true.ver_mean.pval.stopaligned] = arrayfun(@(i) corr(ver_mean2(i,:)',ver_mean_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.hor_mean.rho.stopaligned,eye_movement.eyepos.pred_vs_true.hor_mean.pval.stopaligned] = arrayfun(@(i) corr(hor_mean2(i,:)',hor_mean_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.ver_diff.rho.stopaligned,eye_movement.eyepos.pred_vs_true.ver_diff.pval.stopaligned] = arrayfun(@(i) corr(ver_diff2(i,:)',ver_diff_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.hor_diff.rho.stopaligned,eye_movement.eyepos.pred_vs_true.hor_diff.pval.stopaligned] = arrayfun(@(i) corr(hor_diff2(i,:)',hor_diff_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
pred = permute(cat(3,ver_mean_pred2 , hor_mean_pred2 , hor_diff_pred2),[3 1 2]); pred = (pred - repmat(nanmean(pred,3),[1 1 ntrls]))./repmat(nanstd(pred,[],3),[1 1 ntrls]);
true = permute(cat(3,ver_mean2 , hor_mean2 , hor_diff2),[3 1 2]); true = (true - repmat(nanmean(true,3),[1 1 ntrls]))./repmat(nanstd(true,[],3),[1 1 ntrls]);
cntr_cos_similarity = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrls,ntrls,1);
    cntr_cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls)), 1:Nt);
end
eye_movement.eyepos.pred_vs_true.cntr_cos_similarity.mu.stopaligned = mean(cntr_cos_similarity);
eye_movement.eyepos.pred_vs_true.cntr_cos_similarity.sem.stopaligned = std(cntr_cos_similarity);