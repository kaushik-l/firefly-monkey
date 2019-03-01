function tuningstats = MultiRegress(x1,x2,x3,x4,ts,tspk,timewindow)

%% concatenate data from different trials
xt1 = ConcatenateTrials(x1,[],tspk,ts,timewindow); %  v
xt2 = ConcatenateTrials(x2,[],tspk,ts,timewindow); %  w
xt3 = ConcatenateTrials(x3,[],tspk,ts,timewindow); %  heyevel
[xt4,~,yt] = ConcatenateTrials(x4,[],tspk,ts,timewindow); % veyevel

% replace nans with zeros
% xt1(isnan(xt1)) = 0; xt2(isnan(xt2)) = 0; xt3(isnan(xt3)) = 0; xt4(isnan(xt4)) = 0;
% xt1(xt1<0.5) = nan; xt2(xt2<0.5) = nan; xt3(xt3<0.5) = nan; xt4(xt4<0.5) = nan;

% concatenate
xt = [xt1 xt2 xt3 xt4];

% zscore
xt = (xt - nanmean(xt))./nanstd(xt); yt = (yt - nanmean(yt))./nanstd(yt);

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