function tuningstats = MultiRegress(x1,x2,x3,x4,ts,tspk,timewindow,tuning_prs,tuning_method)

%% concatenate data from different trials
xt1 = ConcatenateTrials(x1,[],tspk,ts,timewindow); % v
xt2 = ConcatenateTrials(x2,[],tspk,ts,timewindow); % w
xt3 = ConcatenateTrials(x3,[],tspk,ts,timewindow); % heyevel
[xt4,~,yt] = ConcatenateTrials(x4,[],tspk,ts,timewindow); % veyevel
xt = [ones(length(xt1),1) xt1 xt2 xt3 xt4];

% concatenate
xt = [xt1 xt2 xt3 xt4];

%% 
% center all variables so they all have zero mean. 
% xt1_ctr = xt1-nanmean(xt1);
% xt2_ctr = xt2-nanmean(xt2);
% xt3_ctr = xt3-nanmean(xt3);
% xt4_ctr = xt4-nanmean(xt4);
% 
% xt_ctr = [ones(length(xt1_ctr),1) xt1_ctr xt2_ctr xt3_ctr xt4_ctr];

%% compute multiple linear regression
[tuningstats.regr_coeff,tuningstats.regr_CI] = regress(yt,xt);