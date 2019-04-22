function eye_movement = AnalyseEyemovement(eye_fixation,x_fly,y_fly,x_monk,y_monk,zle,yle,zre,yre,t_sac,t_stop,ts,trlerrors,spatialerr,prs)

%% prs
delta = prs.interoculardist/2;
zt = -prs.height;
saccade_duration = prs.saccade_duration;
fly_ONduration = prs.fly_ONduration;
Nboots = prs.bootstrap_trl;
factor_downsample = 1; %prs.factor_downsample; % downsampling factor for storage
ntrls = length(x_fly);
pretrial = prs.pretrial;
posttrial = prs.posttrial;

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
        yle{i}(sacstart(j):sacend(j)) = nan; % left eye horizontal position
        yre{i}(sacstart(j):sacend(j)) = nan; % right eye horizontal position
        zle{i}(sacstart(j):sacend(j)) = nan; % left eye vertical position
        zre{i}(sacstart(j):sacend(j)) = nan; % right eye vertical position
    end
%     t_fix(i) = 0;
    pretrial = 0; posttrial = 0;
    % select data between target fixation and end of movement
    % target position
    xt{i} = x_fly{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial)); yt{i} = y_fly{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial));
    xt{i}(isnan(xt{i})) = xt{i}(find(~isnan(xt{i}),1)); yt{i}(isnan(yt{i})) = yt{i}(find(~isnan(yt{i}),1));
    % subject position
    xmt{i} = x_monk{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial)) - x_monk{i}(find(~isnan(x_monk{i}),1)); ymt{i} = y_monk{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial)) - y_monk{i}(find(~isnan(y_monk{i}),1));
    xmt{i}(isnan(xmt{i})) = xmt{i}(find(~isnan(xmt{i}),1)); ymt{i}(isnan(ymt{i})) = ymt{i}(find(~isnan(ymt{i}),1));
    % variance in subject position
    [~,x_indx] = min(abs(xmt{i}-spatialerr.x),[],2);
    [~,y_indx] = min(abs(ymt{i}-spatialerr.y),[],2);
    var_xmt{i} = (spatialerr.x_err_smooth(sub2ind(size(spatialerr.x_err_smooth), x_indx, y_indx))).^2;
    var_ymt{i} = (spatialerr.y_err_smooth(sub2ind(size(spatialerr.y_err_smooth), x_indx, y_indx))).^2;
    % eye position
    yle{i} = yle{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial)); yre{i} = yre{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial));
    zle{i} = zle{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial)); zre{i} = zre{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial));
    
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

%% correlation between behv error and eye-movement prediction error
eye_mean_err = nan(ntrls, 1);
for i=1:ntrls
    nt = length(ver_mean{i});
    eye_mean_err(i) = sqrt(nanmean((ver_mean{i}(1:nt-200) - ver_mean_pred{i}(1:nt-200)).^2 + (hor_mean{i}(1:nt-200) - hor_mean_pred{i}(1:nt-200)).^2));
end
[eye_movement.eyepos.behvcorr.r,eye_movement.eyepos.behvcorr.p] = nancorr(trlerrors(:), eye_mean_err(:));
eye_movement.eyepos.behvcorr.eye_err = eye_mean_err; eye_movement.eyepos.behvcorr.behv_err = trlerrors;

%% save true and predicted eye positions
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
%% compare predicted & eye positions from all trials aligned to target fixation
% gather predicted eye position
ver_mean_pred1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],ver_mean_pred,'UniformOutput',false));
hor_mean_pred1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],hor_mean_pred,'UniformOutput',false));
ver_diff_pred1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],ver_diff_pred,'UniformOutput',false));
hor_diff_pred1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],hor_diff_pred,'UniformOutput',false));
% compute variance of predicted eye position
ver_var_pred1 = ComputeVarianceEyeVer(xt,yt,zt,var_xmt,var_ymt,'normal');
hor_var_pred1 = ComputeVarianceEyeHor(xt,yt,zt,var_xmt,var_ymt,'normal');
% gather true eye position
ver_mean1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],ver_mean,'UniformOutput',false));
hor_mean1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],hor_mean,'UniformOutput',false));
ver_diff1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],ver_diff,'UniformOutput',false));
hor_diff1 = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],hor_diff,'UniformOutput',false));

% timecourse of component-wise corr between predicted & true eye position
[eye_movement.eyepos.pred_vs_true.ver_mean.rho.startaligned,eye_movement.eyepos.pred_vs_true.ver_mean.pval.startaligned] = arrayfun(@(i) corr(ver_mean1(i,:)',ver_mean_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.hor_mean.rho.startaligned,eye_movement.eyepos.pred_vs_true.hor_mean.pval.startaligned] = arrayfun(@(i) corr(hor_mean1(i,:)',hor_mean_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.ver_diff.rho.startaligned,eye_movement.eyepos.pred_vs_true.ver_diff.pval.startaligned] = arrayfun(@(i) corr(ver_diff1(i,:)',ver_diff_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.hor_diff.rho.startaligned,eye_movement.eyepos.pred_vs_true.hor_diff.pval.startaligned] = arrayfun(@(i) corr(hor_diff1(i,:)',hor_diff_pred1(i,:)','Type','Spearman','rows','complete'), 1:Nt);

% timecourse of component-wise regression between predicted & true eye position
beta = cell2mat(arrayfun(@(i) regress(ver_mean1(i,:)',[ver_mean_pred1(i,:)' zeros(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.ver_mean.beta10.startaligned,eye_movement.eyepos.pred_vs_true.ver_mean.beta00.startaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(hor_mean1(i,:)',[hor_mean_pred1(i,:)' zeros(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.hor_mean.beta10.startaligned,eye_movement.eyepos.pred_vs_true.hor_mean.beta00.startaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(ver_diff1(i,:)',[ver_diff_pred1(i,:)' zeros(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.ver_diff.beta10.startaligned,eye_movement.eyepos.pred_vs_true.ver_diff.beta00.startaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(hor_diff1(i,:)',[hor_diff_pred1(i,:)' zeros(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.hor_diff.beta10.startaligned,eye_movement.eyepos.pred_vs_true.hor_diff.beta00.startaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(ver_mean1(i,:)',[ver_mean_pred1(i,:)' ones(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.ver_mean.beta1.startaligned,eye_movement.eyepos.pred_vs_true.ver_mean.beta0.startaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(hor_mean1(i,:)',[hor_mean_pred1(i,:)' ones(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.hor_mean.beta1.startaligned,eye_movement.eyepos.pred_vs_true.hor_mean.beta0.startaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(ver_diff1(i,:)',[ver_diff_pred1(i,:)' ones(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.ver_diff.beta1.startaligned,eye_movement.eyepos.pred_vs_true.ver_diff.beta0.startaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(hor_diff1(i,:)',[hor_diff_pred1(i,:)' ones(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.hor_diff.beta1.startaligned,eye_movement.eyepos.pred_vs_true.hor_diff.beta0.startaligned] = deal(beta(1,:),beta(2,:));

% timecourse of cosine similarity between predicted & true eye position
pred = permute(cat(3,ver_mean_pred1 , hor_mean_pred1),[3 1 2]);
true = permute(cat(3,ver_mean1 , hor_mean1),[3 1 2]);
cos_similarity = nan(Nboots,Nt); cos_similarity_shuffled = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrls,ntrls,1); randtrls2 = randsample(ntrls,ntrls,1);
    cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls)), 1:Nt);
    cos_similarity_shuffled(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls2)), 1:Nt);
end
eye_movement.eyepos.pred_vs_true.cos_similarity.mu.startaligned = mean(cos_similarity);
eye_movement.eyepos.pred_vs_true.cos_similarity.sem.startaligned = std(cos_similarity);
eye_movement.eyepos.pred_vs_true.cos_similarity_shuffled.mu.startaligned = mean(cos_similarity_shuffled);
eye_movement.eyepos.pred_vs_true.cos_similarity_shuffled.sem.startaligned = std(cos_similarity_shuffled);

% timecourse of cosine similarity between predicted & true eye position
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
pred = permute(cat(3,ver_mean_pred1 , hor_mean_pred1),[3 1 2]); pred = (pred - repmat(nanmean(pred,3),[1 1 ntrls]))./repmat(nanstd(pred,[],3),[1 1 ntrls]);
true = permute(cat(3,ver_mean1 , hor_mean1),[3 1 2]); true = (true - repmat(nanmean(true,3),[1 1 ntrls]))./repmat(nanstd(true,[],3),[1 1 ntrls]);
cntr_cos_similarity = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrls,ntrls,1);
    cntr_cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls)), 1:Nt);
end
eye_movement.eyepos.pred_vs_true.cntr_cos_similarity.mu.startaligned = mean(cntr_cos_similarity);
eye_movement.eyepos.pred_vs_true.cntr_cos_similarity.sem.startaligned = std(cntr_cos_similarity);

% timecourse of variance explained
pred = permute(cat(3,ver_mean_pred1 , hor_mean_pred1),[3 1 2]);
true = permute(cat(3,ver_mean1 , hor_mean1),[3 1 2]);
var_explained = nan(Nboots,Nt); var_explained_shuffled = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrls,ntrls,1); randtrls2 = randsample(ntrls,ntrls,1);
    squared_err = sum(nanmean((true(:,:,randtrls) - pred(:,:,randtrls)).^2,3)); var_pred = sum(nanvar(pred(:,:,randtrls),[],3));
    var_explained(i,:) = 1 - (squared_err(:)./var_pred(:)); % try taking sqrt or cosine of var_explained
    squared_err_shuffled = sum(nanmean((true(:,:,randtrls) - pred(:,:,randtrls2)).^2,3)); var_pred_shuffled = sum(nanvar(pred(:,:,randtrls2),[],3));
    var_explained_shuffled(i,:) =  1 - (squared_err_shuffled(:)./var_pred_shuffled(:));
end
eye_movement.eyepos.pred_vs_true.var_explained.mu.startaligned = nanmean(var_explained);
eye_movement.eyepos.pred_vs_true.var_explained.sem.startaligned = nanstd(var_explained);
eye_movement.eyepos.pred_vs_true.var_explained_shuffled.mu.startaligned = nanmean(var_explained_shuffled);
eye_movement.eyepos.pred_vs_true.var_explained_shuffled.sem.startaligned = nanstd(var_explained_shuffled);

% timecourse of upper bound on variance explained
expected_squared_err = (nanmean(ver_var_pred1,2) + nanmean(hor_var_pred1,2)); var_pred = sum(nanvar(pred,[],3)); var_true = sum(nanvar(true,[],3));
eye_movement.eyepos.pred_vs_true.var_explained_upperbound.mu.startaligned = 1 - (expected_squared_err(:)./var_pred(:)); % try taking sqrt or cosine of var_explained
eye_movement.eyepos.pred_vs_true.expected_squared_err.mu.startaligned = expected_squared_err(:);
eye_movement.eyepos.pred_vs_true.var_pred.mu.startaligned = var_pred(:);
eye_movement.eyepos.pred_vs_true.var_true.mu.startaligned = var_true(:);

% timecourse of variance explained for various accuracies
ngroups = 5;
ntrls_per_group = (ntrls - mod(ntrls,ngroups))/ngroups;
errorindx = errorindx(1:ntrls_per_group*ngroups);
var_explained = nan(ngroups,Nt);
for i=1:ngroups
    trlgroup = errorindx(ntrls_per_group*(i-1) + 1:ntrls_per_group*i);
    squared_err = sum(nanmean((true(:,:,trlgroup) - pred(:,:,trlgroup)).^2,3)); var_pred = sum(nanvar(pred(:,:,trlgroup),[],3));
    var_explained(i,:) = 1 - (squared_err(:)./var_pred(:)); % try taking sqrt or cosine of var_explained
end
eye_movement.eyepos.pred_vs_true.var_explained_vs_error.mu.startaligned = var_explained;

% timecourse of similarity measure based on Mahalanobis distance
dist_mahalanobis = nan(Nboots,Nt); dist_mahalanobis_shuffled = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrls,ntrls,1);
    [~,indx1] = min(abs(squeeze(true(1,:,randtrls)) - permute(repmat(eye_fixation.eyepos.true.ver_mean.mu(:),[1 Nt ntrls]),[2 3 1])),[],3);
    [~,indx2] = min(abs(squeeze(true(2,:,randtrls)) - permute(repmat(eye_fixation.eyepos.true.hor_mean.mu(:),[1 Nt ntrls]),[2 3 1])),[],3);
    ver_mahalanobis = nanmean(((squeeze(true(1,:,randtrls)) - squeeze(pred(1,:,randtrls))).^2)./(eye_fixation.eyepos.true.ver_mean.sig(indx1).^2),2);
    hor_mahalanobis = nanmean(((squeeze(true(2,:,randtrls)) - squeeze(pred(2,:,randtrls))).^2)./(eye_fixation.eyepos.true.hor_mean.sig(indx2).^2),2);
    randtrls2 = randsample(ntrls,ntrls,1);
    ver_mahalanobis_shuffled = nanmean(((squeeze(true(1,:,randtrls)) - squeeze(pred(1,:,randtrls2))).^2)./(eye_fixation.eyepos.true.ver_mean.sig(indx1).^2),2);
    hor_mahalanobis_shuffled = nanmean(((squeeze(true(2,:,randtrls)) - squeeze(pred(2,:,randtrls2))).^2)./(eye_fixation.eyepos.true.hor_mean.sig(indx2).^2),2);
    dist_mahalanobis(i,:) = sqrt(ver_mahalanobis + hor_mahalanobis);
    dist_mahalanobis_shuffled(i,:) = sqrt(ver_mahalanobis_shuffled + hor_mahalanobis_shuffled);
end
dist_mahalanobis = nanmean(dist_mahalanobis); d0 = min(dist_mahalanobis(1:50)); % reused for stopaligned analysis
eye_movement.eyepos.pred_vs_true.mahalanobis_distance.mu.startaligned = dist_mahalanobis;
eye_movement.eyepos.pred_vs_true.mahalanobis_similarity.mu.startaligned = 2./(1 + dist_mahalanobis/d0);
dist_mahalanobis_shuffled = nanmean(dist_mahalanobis_shuffled);
eye_movement.eyepos.pred_vs_true.mahalanobis_distance_shuffled.mu.startaligned = dist_mahalanobis_shuffled;
eye_movement.eyepos.pred_vs_true.mahalanobis_similarity_shuffled.mu.startaligned = 2./(1 + dist_mahalanobis_shuffled/d0);

% timecourse of upper bound on similarity measure based on Mahalanobis distance
[~,indx1] = min(abs(squeeze(true(1,:,:)) - permute(repmat(eye_fixation.eyepos.true.ver_mean.mu(:),[1 Nt ntrls]),[2 3 1])),[],3);
ver_mahalanobis_expected = nanmean(ver_var_pred1./(eye_fixation.eyepos.true.hor_mean.sig(indx1).^2),2);
[~,indx2] = min(abs(squeeze(true(2,:,:)) - permute(repmat(eye_fixation.eyepos.true.hor_mean.mu(:),[1 Nt ntrls]),[2 3 1])),[],3);
hor_mahalanobis_expected = nanmean(hor_var_pred1./(eye_fixation.eyepos.true.ver_mean.sig(indx2).^2),2);
dist_mahalanobis_expected = sqrt(ver_mahalanobis_expected + hor_mahalanobis_expected);
eye_movement.eyepos.pred_vs_true.mahalanobis_upperbound.mu.startaligned = 2./(1 + dist_mahalanobis_expected/d0);

%% compare predicted & eye positions from all trials aligned to end of movement
% predicted eye position
ver_mean_pred2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],ver_mean_pred,'UniformOutput',false));
hor_mean_pred2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],hor_mean_pred,'UniformOutput',false));
ver_diff_pred2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],ver_diff_pred,'UniformOutput',false));
hor_diff_pred2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],hor_diff_pred,'UniformOutput',false));
% compute variance of predicted eye position
ver_var_pred2 = ComputeVarianceEyeVer(xt,yt,zt,var_xmt,var_ymt,'reverse');
hor_var_pred2 = ComputeVarianceEyeHor(xt,yt,zt,var_xmt,var_ymt,'reverse');
% true eye position
ver_mean2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],ver_mean,'UniformOutput',false));
hor_mean2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],hor_mean,'UniformOutput',false));
ver_diff2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],ver_diff,'UniformOutput',false));
hor_diff2 = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],hor_diff,'UniformOutput',false));

% timecourse of component-wise corr between predicted & true eye position
[eye_movement.eyepos.pred_vs_true.ver_mean.rho.stopaligned,eye_movement.eyepos.pred_vs_true.ver_mean.pval.stopaligned] = arrayfun(@(i) corr(ver_mean2(i,:)',ver_mean_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.hor_mean.rho.stopaligned,eye_movement.eyepos.pred_vs_true.hor_mean.pval.stopaligned] = arrayfun(@(i) corr(hor_mean2(i,:)',hor_mean_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.ver_diff.rho.stopaligned,eye_movement.eyepos.pred_vs_true.ver_diff.pval.stopaligned] = arrayfun(@(i) corr(ver_diff2(i,:)',ver_diff_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);
[eye_movement.eyepos.pred_vs_true.hor_diff.rho.stopaligned,eye_movement.eyepos.pred_vs_true.hor_diff.pval.stopaligned] = arrayfun(@(i) corr(hor_diff2(i,:)',hor_diff_pred2(i,:)','Type','Spearman','rows','complete'), 1:Nt);

% component-wise regression between predicted & true eye position
beta = cell2mat(arrayfun(@(i) regress(ver_mean2(i,:)',[ver_mean_pred2(i,:)' zeros(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.ver_mean.beta10.stopaligned,eye_movement.eyepos.pred_vs_true.ver_mean.beta00.stopaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(hor_mean2(i,:)',[hor_mean_pred2(i,:)' zeros(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.hor_mean.beta10.stopaligned,eye_movement.eyepos.pred_vs_true.hor_mean.beta00.stopaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(ver_diff2(i,:)',[ver_diff_pred2(i,:)' zeros(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.ver_diff.beta10.stopaligned,eye_movement.eyepos.pred_vs_true.ver_diff.beta00.stopaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(hor_diff2(i,:)',[hor_diff_pred2(i,:)' zeros(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.hor_diff.beta10.stopaligned,eye_movement.eyepos.pred_vs_true.hor_diff.beta00.stopaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(ver_mean2(i,:)',[ver_mean_pred2(i,:)' ones(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.ver_mean.beta1.stopaligned,eye_movement.eyepos.pred_vs_true.ver_mean.beta0.stopaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(hor_mean2(i,:)',[hor_mean_pred2(i,:)' ones(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.hor_mean.beta1.stopaligned,eye_movement.eyepos.pred_vs_true.hor_mean.beta0.stopaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(ver_diff2(i,:)',[ver_diff_pred2(i,:)' ones(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.ver_diff.beta1.stopaligned,eye_movement.eyepos.pred_vs_true.ver_diff.beta0.stopaligned] = deal(beta(1,:),beta(2,:));
beta = cell2mat(arrayfun(@(i) regress(hor_diff2(i,:)',[hor_diff_pred2(i,:)' ones(ntrls,1)]), 1:Nt, 'UniformOutput', false)); [eye_movement.eyepos.pred_vs_true.hor_diff.beta1.stopaligned,eye_movement.eyepos.pred_vs_true.hor_diff.beta0.stopaligned] = deal(beta(1,:),beta(2,:));

% timecourse of cosine similarity between predicted & true eye position
pred = permute(cat(3,ver_mean_pred2 , hor_mean_pred2),[3 1 2]);
true = permute(cat(3,ver_mean2 , hor_mean2),[3 1 2]);
cos_similarity = nan(Nboots,Nt); cos_similarity_shuffled = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrls,ntrls,1); randtrls2 = randsample(ntrls,ntrls,1);
    cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls)), 1:Nt);
    cos_similarity_shuffled(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls2)), 1:Nt);
end
eye_movement.eyepos.pred_vs_true.cos_similarity.mu.stopaligned = mean(cos_similarity);
eye_movement.eyepos.pred_vs_true.cos_similarity.sem.stopaligned = std(cos_similarity);
eye_movement.eyepos.pred_vs_true.cos_similarity_shuffled.mu.stopaligned = mean(cos_similarity_shuffled);
eye_movement.eyepos.pred_vs_true.cos_similarity_shuffled.sem.stopaligned = std(cos_similarity_shuffled);

% timecourse of cosine similarity between predicted & true eye position -
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
pred = permute(cat(3,ver_mean_pred2 , hor_mean_pred2),[3 1 2]); pred = (pred - repmat(nanmean(pred,3),[1 1 ntrls]))./repmat(nanstd(pred,[],3),[1 1 ntrls]);
true = permute(cat(3,ver_mean2 , hor_mean2),[3 1 2]); true = (true - repmat(nanmean(true,3),[1 1 ntrls]))./repmat(nanstd(true,[],3),[1 1 ntrls]);
cntr_cos_similarity = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrls,ntrls,1);
    cntr_cos_similarity(i,:) = arrayfun(@(i) CosSimilarity(pred(:,i,randtrls),true(:,i,randtrls)), 1:Nt);
end
eye_movement.eyepos.pred_vs_true.cntr_cos_similarity.mu.stopaligned = mean(cntr_cos_similarity);
eye_movement.eyepos.pred_vs_true.cntr_cos_similarity.sem.stopaligned = std(cntr_cos_similarity);

% timecourse of variance explained
pred = permute(cat(3,ver_mean_pred2 , hor_mean_pred2),[3 1 2]);
true = permute(cat(3,ver_mean2 , hor_mean2),[3 1 2]);
var_explained = nan(Nboots,Nt); var_explained_shuffled = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrls,ntrls,1); randtrls2 = randsample(ntrls,ntrls,1);
    squared_err = sum(nanmean((true(:,:,randtrls) - pred(:,:,randtrls)).^2,3)); var_pred = sum(nanvar(pred(:,:,randtrls),[],3));
    var_explained(i,:) = 1 - (squared_err(:)./var_pred(:)); % try taking sqrt or cosine of var_explained
    squared_err_shuffled = sum(nanmean((true(:,:,randtrls) - pred(:,:,randtrls2)).^2,3)); var_pred_shuffled = sum(nanvar(pred(:,:,randtrls2),[],3));
    var_explained_shuffled(i,:) =  1 - (squared_err_shuffled(:)./var_pred_shuffled(:));
end
eye_movement.eyepos.pred_vs_true.var_explained.mu.stopaligned = nanmean(var_explained);
eye_movement.eyepos.pred_vs_true.var_explained.sem.stopaligned = nanstd(var_explained);
eye_movement.eyepos.pred_vs_true.var_explained_shuffled.mu.stopaligned = nanmean(var_explained_shuffled);
eye_movement.eyepos.pred_vs_true.var_explained_shuffled.sem.stopaligned = nanstd(var_explained_shuffled);

% timecourse of upper bound on variance explained
expected_squared_err = (nanmean(ver_var_pred2,2) + nanmean(hor_var_pred2,2)); var_pred = sum(nanvar(pred,[],3)); var_true = sum(nanvar(true,[],3));
eye_movement.eyepos.pred_vs_true.var_explained_upperbound.mu.stopaligned = 1 - (expected_squared_err(:)./var_pred(:)); % try taking sqrt or cosine of var_explained
eye_movement.eyepos.pred_vs_true.expected_squared_err.mu.stopaligned = expected_squared_err(:);
eye_movement.eyepos.pred_vs_true.var_pred.mu.stopaligned = var_pred(:);
eye_movement.eyepos.pred_vs_true.var_true.mu.stopaligned = var_true(:);

% timecourse of variance explained for various accuracies
ngroups = 5;
ntrls_per_group = (ntrls - mod(ntrls,ngroups))/ngroups;
errorindx = errorindx(1:ntrls_per_group*ngroups);
var_explained = nan(ngroups,Nt);
for i=1:ngroups
    trlgroup = errorindx(ntrls_per_group*(i-1) + 1:ntrls_per_group*i);
    squared_err = sum(nanmean((true(:,:,trlgroup) - pred(:,:,trlgroup)).^2,3)); var_pred = sum(nanvar(pred(:,:,trlgroup),[],3));
    var_explained(i,:) = 1 - (squared_err(:)./var_pred(:)); % try taking sqrt or cosine of var_explained
end
eye_movement.eyepos.pred_vs_true.var_explained_vs_error.mu.stopaligned = var_explained;

% timecourse of similarity measure based on Mahalanobis distance
dist_mahalanobis = nan(Nboots,Nt); dist_mahalanobis_shuffled = nan(Nboots,Nt);
for i=1:Nboots
    randtrls = randsample(ntrls,ntrls,1);
    [~,indx1] = min(abs(squeeze(true(1,:,randtrls)) - permute(repmat(eye_fixation.eyepos.true.ver_mean.mu(:),[1 Nt ntrls]),[2 3 1])),[],3);
    [~,indx2] = min(abs(squeeze(true(2,:,randtrls)) - permute(repmat(eye_fixation.eyepos.true.hor_mean.mu(:),[1 Nt ntrls]),[2 3 1])),[],3);
    ver_mahalanobis = nanmean(((squeeze(true(1,:,randtrls)) - squeeze(pred(1,:,randtrls))).^2)./(eye_fixation.eyepos.true.ver_mean.sig(indx1).^2),2);
    hor_mahalanobis = nanmean(((squeeze(true(2,:,randtrls)) - squeeze(pred(2,:,randtrls))).^2)./(eye_fixation.eyepos.true.hor_mean.sig(indx2).^2),2);
    randtrls2 = randsample(ntrls,ntrls,1);
    ver_mahalanobis_shuffled = nanmean(((squeeze(true(1,:,randtrls)) - squeeze(pred(1,:,randtrls2))).^2)./(eye_fixation.eyepos.true.ver_mean.sig(indx1).^2),2);
    hor_mahalanobis_shuffled = nanmean(((squeeze(true(2,:,randtrls)) - squeeze(pred(2,:,randtrls2))).^2)./(eye_fixation.eyepos.true.hor_mean.sig(indx2).^2),2);
    dist_mahalanobis(i,:) = sqrt(ver_mahalanobis + hor_mahalanobis);
    dist_mahalanobis_shuffled(i,:) = sqrt(ver_mahalanobis_shuffled + hor_mahalanobis_shuffled);
end
dist_mahalanobis = nanmean(dist_mahalanobis);
eye_movement.eyepos.pred_vs_true.mahalanobis_distance.mu.stopaligned = dist_mahalanobis;
eye_movement.eyepos.pred_vs_true.mahalanobis_similarity.mu.stopaligned = 2./(1 + dist_mahalanobis/d0);
dist_mahalanobis_shuffled = nanmean(dist_mahalanobis_shuffled);
eye_movement.eyepos.pred_vs_true.mahalanobis_distance_shuffled.mu.stopaligned = dist_mahalanobis_shuffled;
eye_movement.eyepos.pred_vs_true.mahalanobis_similarity_shuffled.mu.stopaligned = 2./(1 + dist_mahalanobis_shuffled/d0);

% timecourse of upper bound on similarity measure based on Mahalanobis distance
[~,indx1] = min(abs(squeeze(true(1,:,:)) - permute(repmat(eye_fixation.eyepos.true.ver_mean.mu(:),[1 Nt ntrls]),[2 3 1])),[],3);
ver_mahalanobis_expected = nanmean(ver_var_pred2./(eye_fixation.eyepos.true.hor_mean.sig(indx1).^2),2);
[~,indx2] = min(abs(squeeze(true(2,:,:)) - permute(repmat(eye_fixation.eyepos.true.hor_mean.mu(:),[1 Nt ntrls]),[2 3 1])),[],3);
hor_mahalanobis_expected = nanmean(hor_var_pred2./(eye_fixation.eyepos.true.ver_mean.sig(indx2).^2),2);
dist_mahalanobis_expected = sqrt(ver_mahalanobis_expected + hor_mahalanobis_expected);
eye_movement.eyepos.pred_vs_true.mahalanobis_upperbound.mu.stopaligned = 2./(1 + dist_mahalanobis_expected/d0);