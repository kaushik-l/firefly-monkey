function tuningstats = ComputeTuning(x,ts,tspk,timewindow,duration_zeropad,corr_lag,nbootstraps,tuning_prs,tuning_method,tuning_binrange)

ntrls = length(x);
if ntrls < nbootstraps % not enough trials
    tuningstats = [];
    return;
end
if nargin<10, tuning_binrange = []; end

%% concatenate data from different trials
[xt,~,yt,xt_pad,~,yt_pad] = ConcatenateTrials(x,[],tspk,ts,timewindow,duration_zeropad);

%% estimate cross-correlation
if ~(length(tspk{1}) == length(ts{1})) % data as spike times
    temporal_binwidth = median(diff(ts{1}));
else % any other data
    temporal_binwidth = 1;
end
lags = round(corr_lag/temporal_binwidth);
[c,lags]=xcorr(zscore(xt_pad),zscore(yt_pad),lags,'coeff'); % normalise E[z(x)*z(y)] by sqrt(R_xx(0)*R_yy(0))
tuningstats.xcorr.val = c;
tuningstats.xcorr.lag = lags*temporal_binwidth;

%% compute tuning curves
if strcmp(tuning_method,'binning')
    nbins = tuning_prs.nbins1d_binning; % load predefined number of bins
    [tuningstats.tuning.stim,tuningstats.tuning.rate,tuningstats.tuning.pval] = NPregress_binning(xt,yt,temporal_binwidth,nbins,nbootstraps,tuning_binrange);
elseif strcmp(tuning_method,'k-nearest')
    k = arrayfun(tuning_prs.k_knn,numel(xt)); % compute k from predefined anonymous function
    nbins = tuning_prs.nbins1d_binning; % load predefined number of bins
    [tuningstats.tuning.stim,tuningstats.tuning.rate] = NPregress_knn(xt,yt,temporal_binwidth,k,nbins,nbootstraps);
elseif strcmp(tuning_method,'nadaraya-watson')
    kernel = tuning_prs.kernel_nw; % load kernel for smoothing
    bandwidth = tuning_prs.bandwidth_nw; % load kernel for smoothing
    [tuningstats.tuning.stim,tuningstats.tuning.rate] = NPregress_nw(xt,yt,temporal_binwidth,kernel,bandwidth,[],nbootstraps);
elseif strcmp(tuning_method,'local-linear')
    kernel = tuning_prs.kernel_locallinear; % load kernel for smoothing
    bandwidth = tuning_prs.bandwidth_locallinear; % load kernel for smoothing
    [tuningstats.tuning.stim,tuningstats.tuning.rate] = NPregress_locallinear(xt,yt,temporal_binwidth,kernel,bandwidth,[],nbootstraps);
end