function eye_fixation = AnalyseEyefixation(x_fly,y_fly,zle,yle,zre,yre,t_sac,t_stop,ts,prs)

%% prs
delta = prs.interoculardist/2;
zt = -prs.height;
saccade_duration = prs.saccade_duration;
fly_ONduration = prs.fly_ONduration;
ntrls = length(x_fly);
%% eye position immediately after the first saccade following target onset
for i=1:ntrls    
    sac_indx = t_sac{i}>0 & t_sac{i}<2*fly_ONduration;
    sacstart = []; sacend = []; sacampli = [];
    if any(sac_indx)
        t_sac2 = t_sac{i}(sac_indx);
        for j=1:length(t_sac2)
            sacstart(j) = find(ts{i}>(t_sac2(j)), 1);
            sacend(j) = find(ts{i}>(t_sac2(j) + saccade_duration), 1);
            sacampli(j) = nanmean([sum(abs(zle{i}(sacstart(j)) - zle{i}(sacend(j)))^2 + abs(yle{i}(sacstart(j)) - yle{i}(sacend(j)))^2) ...
                sum(abs(zre{i}(sacstart(j)) - zre{i}(sacend(j)))^2 + abs(yre{i}(sacstart(j)) - yre{i}(sacend(j)))^2)]);
        end
        t_sac2 = t_sac2(sacampli == max(sacampli));
        t_indx = find(ts{i}>(t_sac2 + saccade_duration), 1);
        xt(i) = x_fly{i}(t_indx); yt(i) = y_fly{i}(t_indx);
        % ground truth prediction for eye position (if the monkey really followed the target)
        yle_pred(i) = atan2d(xt(i) + delta, sqrt(yt(i)^2 + zt^2));
        yre_pred(i) = atan2d(xt(i) - delta, sqrt(yt(i)^2 + zt^2));
        zle_pred(i) = atan2d(zt , sqrt(yt(i)^2 + (xt(i) + delta)^2));
        zre_pred(i) = atan2d(zt , sqrt(yt(i)^2 + (xt(i) - delta)^2));        
        ver_mean_pred(i) = nanmean([zle_pred(i) , zre_pred(i)]); % mean vertical eye position (of the two eyes)
        hor_mean_pred(i) = nanmean([yle_pred(i) , yre_pred(i)]); % mean horizontal eye position
        ver_diff_pred(i) = 0.5*(zle_pred(i) - zre_pred(i)); % 0.5*difference between vertical eye positions (of the two eyes)
        hor_diff_pred(i) = 0.5*(yle_pred(i) - yre_pred(i)); % 0.5*difference between horizontal eye positions
        % actual eye position
        ver_mean(i) = nanmean([zle{i}(t_indx) , zre{i}(t_indx)]); % mean vertical eye position (of the two eyes)
        hor_mean(i) = nanmean([yle{i}(t_indx) , yre{i}(t_indx)]); % mean horizontal eye position
        ver_diff(i) = 0.5*(zle{i}(t_indx) - zre{i}(t_indx)); % 0.5*difference between vertical eye positions (of the two eyes)
        hor_diff(i) = 0.5*(yle{i}(t_indx) - yre{i}(t_indx)); % 0.5*difference between horizontal eye positions
    else
        xt(i) = nan; yt(i) = nan;
        ver_mean_pred(i) = nan; hor_mean_pred(i) = nan;
        ver_diff_pred(i) = nan; hor_diff_pred(i) = nan;
        ver_mean(i) = nan; hor_mean(i) = nan;
        ver_diff(i) = nan; hor_diff(i) = nan;
    end
    % 
end
rt = sqrt(xt.^2 + yt.^2);
thetat = atan2d(xt,yt);


%% saccade timecourse
% start aligned
nx = -0.5:0.1:2.1;
[ny,nx] =  hist(cell2mat(t_sac'),nx);
ny = ny/0.1/ntrls;
eye_fixation.saccade.startaligned.rate = ny(2:end-1);
eye_fixation.saccade.startaligned.t = nx(2:end-1);

%stop aligned
t_sac_stop = cellfun(@(x,y) x - y, t_sac, num2cell(t_stop),'UniformOutput',false);
nx = -1.1:0.1:0.5;
[ny,nx] =  hist(cell2mat(t_sac_stop'),nx);
ny = ny/0.1/ntrls;
eye_fixation.saccade.stopaligned.rate = ny(2:end-1);
eye_fixation.saccade.stopaligned.t = nx(2:end-1);

%% save true and predicted eye positions
eye_fixation.flypos.r = rt;
eye_fixation.flypos.theta = thetat;
eye_fixation.eyepos.pred.ver_mean.val = ver_mean_pred;
eye_fixation.eyepos.pred.hor_mean.val = hor_mean_pred;
eye_fixation.eyepos.pred.ver_diff.val = ver_diff_pred;
eye_fixation.eyepos.pred.hor_diff.val = hor_diff_pred;
eye_fixation.eyepos.true.ver_mean.val = ver_mean;
eye_fixation.eyepos.true.hor_mean.val = hor_mean;
eye_fixation.eyepos.true.ver_diff.val = ver_diff;
eye_fixation.eyepos.true.hor_diff.val = hor_diff;

%% component-wise correlation between predicted and true eye positions
[eye_fixation.eyepos.pred_vs_true.ver_mean.rho,eye_fixation.eyepos.pred_vs_true.ver_mean.pval] = corr(ver_mean_pred(:),ver_mean(:),'rows','complete');
[eye_fixation.eyepos.pred_vs_true.hor_mean.rho,eye_fixation.eyepos.pred_vs_true.hor_mean.pval] = corr(hor_mean_pred(:),hor_mean(:),'rows','complete');
[eye_fixation.eyepos.pred_vs_true.ver_diff.rho,eye_fixation.eyepos.pred_vs_true.ver_diff.pval] = corr(ver_diff_pred(:),ver_diff(:),'rows','complete');
[eye_fixation.eyepos.pred_vs_true.hor_diff.rho,eye_fixation.eyepos.pred_vs_true.hor_diff.pval] = corr(hor_diff_pred(:),hor_diff(:),'rows','complete');

%%  heteroscedastic variance of eye positions
[eye_fixation.eyepos.true.hor_mean.mu,eye_fixation.eyepos.true.hor_mean.sig] = ComputeBinnedVariance(hor_mean_pred,hor_mean,linspace(-40,40,11),1);
[eye_fixation.eyepos.true.ver_mean.mu,eye_fixation.eyepos.true.ver_mean.sig] = ComputeBinnedVariance(ver_mean_pred,ver_mean,flip(-logspace(log10(2),log10(15),11)),0);

%% cosine similarity
cos_similarity = nan(1,prs.bootstrap_trl);
pred = [ver_mean_pred ; hor_mean_pred];
true = [ver_mean ; hor_mean];
for i=1:prs.nbootstraps
    randtrls = randsample(ntrls,ntrls,1);
    cos_similarity(i) = CosSimilarity(pred(:,randtrls),true(:,randtrls));
end
eye_fixation.eyepos.pred_vs_true.cos_similarity.mu = mean(cos_similarity);
eye_fixation.eyepos.pred_vs_true.cos_similarity.sem = std(cos_similarity);

%% centered cosine similarity
cntr_cos_similarity = nan(1,prs.bootstrap_trl);
pred = [ver_mean_pred ; hor_mean_pred]; pred = (pred - repmat(nanmean(pred,2),[1 ntrls]))./repmat(nanstd(pred,[],2),[1 ntrls]);
true = [ver_mean ; hor_mean]; true = (true - repmat(nanmean(true,2),[1 ntrls]))./repmat(nanstd(true,[],2),[1 ntrls]);
for i=1:prs.nbootstraps
    randtrls = randsample(ntrls,ntrls,1);
    cntr_cos_similarity(i) = CosSimilarity(pred(:,randtrls),true(:,randtrls));
end
eye_fixation.eyepos.pred_vs_true.cntr_cos_similarity.mu = mean(cntr_cos_similarity);
eye_fixation.eyepos.pred_vs_true.cntr_cos_similarity.sem = std(cntr_cos_similarity);