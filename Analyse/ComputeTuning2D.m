function tuningstats = ComputeTuning2D(x1,x2,ts,tspk,timewindow,tuning_prs,tuning_method)

%% concatenate data from different trials
xt1 = ConcatenateTrials(x1,[],tspk,ts,timewindow);
[xt2,~,yt] = ConcatenateTrials(x2,[],tspk,ts,timewindow);
xt = [xt1 xt2];

%% compute tuning curves
temporal_binwidth = median(diff(ts{1}));
if strcmp(tuning_method,'binning')
    nbins = tuning_prs.nbins2d_binning; % load predefined number of bins
    [tuningstats.tuning.stim,tuningstats.tuning.rate] = NPregress_binning2d(xt,yt,temporal_binwidth,nbins);
elseif strcmp(tuning_method,'k-nearest')
    k = arrayfun(tuning_prs.k_knn,numel(xt1)); % compute k from predefined anonymous function
    nbins = tuning_prs.nbins2d_binning; % load predefined number of bins
    [tuningstats.tuning.stim,tuningstats.tuning.rate] = NPregress_knn2d(xt,yt,temporal_binwidth,k,nbins);
elseif strcmp(tuning_method,'nadaraya-watson')
    kernel = tuning_prs.kernel_nw; % load kernel for smoothing
    bandwidth = tuning_prs.bandwidth2d_nw; % load kernel for smoothing
    nbins = tuning_prs.nbins2d_nw; % load predefined number of bins
    [tuningstats.tuning.stim,tuningstats.tuning.rate] = NPregress_nw2d(xt,yt,temporal_binwidth,kernel,bandwidth,nbins);
elseif strcmp(tuning_method,'local-linear')
    kernel = tuning_prs.kernel_locallinear; % load kernel for smoothing
    bandwidth = tuning_prs.bandwidth_locallinear; % load kernel for smoothing
    [tuningstats.tuning.stim,tuningstats.tuning.rate] = NPregress_locallinear2d(xt,yt,temporal_binwidth,kernel,bandwidth,[]);
end