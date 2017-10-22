function tuningstats = ComputeTuning(x,ts,tspk,timewindow,duration_zeropad,corr_lag,nbootstraps,tuning_prs,tuning_method)

ntrls = length(x);
if ntrls < nbootstraps % not enough trials
    tuningstats = [];
    return;
end

temporal_binwidth = median(diff(ts{1}));
padding = zeros(round(duration_zeropad/temporal_binwidth),1);
%% concatenate data from different trials
y = cellfun(@(x,y) hist(x,y),tspk,ts,'UniformOutput',false);
t2 = cellfun(@(x) x(2:end-1),ts,'UniformOutput',false);
x2 = cellfun(@(x) x(2:end-1),x,'UniformOutput',false);
y2 = cellfun(@(x) x(2:end-1)',y,'UniformOutput',false); % transpose is to reshape to column vector

twin = mat2cell(timewindow,ones(1,ntrls));
xt = cellfun(@(x,y,z) x(y>z(1) & y<z(2)),x2(:),t2(:),twin(:),'UniformOutput',false);
yt = cellfun(@(x,y,z) x(y>z(1) & y<z(2)),y2(:),t2(:),twin(:),'UniformOutput',false);
xt_pad = cell2mat(cellfun(@(x) [padding(:) ; x(:)],x2(:),'UniformOutput',false)); % zero-pad for cross-correlations
yt_pad = cell2mat(cellfun(@(x) [padding(:) ; x(:)],y2(:),'UniformOutput',false));
xt = cell2mat(xt);
yt = cell2mat(yt);

%% estimate cross-correlation
lags = round(corr_lag/temporal_binwidth);
[c,lags]=xcorr(zscore(xt_pad),zscore(yt_pad),lags,'coeff'); % normalise E[z(x)*z(y)] by sqrt(R_xx(0)*R_yy(0))
tuningstats.xcorr.val = c;
tuningstats.xcorr.lag = lags*temporal_binwidth;

%% compute tuning curves
if strcmp(tuning_method,'binning')
    binedges = tuning_prs.tuning_binedges;
    [tuningstats.tuning.stim,tuningstats.tuning.rate,tuningstats.tuning.pval] = NPregress_binning(xt,yt,binedges,nbootstraps,temporal_binwidth);
end