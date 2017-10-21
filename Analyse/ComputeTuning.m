function tuningstats = ComputeTuning(x,ts,tspk,timewindow,duration_zeropad,corr_lag,binedges,bootstrap_samp)

ntrls = length(x);
if ntrls < bootstrap_samp % not enough trials
    tuningstats = [];
    return;
end

temporal_binwidth = median(diff(ts{1}));
padding = zeros(round(duration_zeropad/temporal_binwidth),1);
%% concatenate data from different trials
xt = []; yt = [];
xt_pad = []; yt_pad = [];
for i=1:ntrls
    t_i = ts{i};
    x_i = x{i};
    y_i = hist(tspk{i},t_i); % rasterise spike times into bins --- 1001101000111
    % throw away histogram edges
    t_i = t_i(2:end-1);
    x_i = x_i(2:end-1);
    y_i = y_i(2:end-1);
    % select data within the analysis timewindow
    indx = t_i>timewindow(i,1) & t_i<timewindow(i,2);
    x_i = x_i(indx);
    y_i = y_i(indx);
    xt = [xt(:); x_i(:)];
    yt = [yt(:); y_i(:)];
    xt_pad = [xt_pad(:); x_i(:); padding(:)];
    yt_pad = [yt_pad(:); y_i(:); padding(:)];
end

%% estimate cross-correlation
lags = round(corr_lag/temporal_binwidth);
[c,lags]=xcorr(zscore(xt_pad),zscore(yt_pad),lags,'coeff'); % normalise E[z(x)*z(y)] by sqrt(R_xx(0)*R_yy(0))
tuningstats.xcorr.val = c;
tuningstats.xcorr.lag = lags*temporal_binwidth;

%% compute tuning curves
nbins = length(binedges);
if ~isempty(bootstrap_samp)
    compute_sem = 1;
    nbootstraps = 2*bootstrap_samp; % set number of bootstraps == 2*number of samples/bootstrap
end
if ~compute_sem % just get the mean response
    rate = cell(nbins-1,1);
    stim = cell(nbins-1,1);
    stimgroup = cell(nbins-1,1);
    for i=1:nbins-1
        indx = xt>binedges(i) & xt<binedges(i+1);
        rate{i} = yt(indx)/temporal_binwidth;
        stim{i} = xt(indx);
        stimgroup{i} = cell(length(rate{i}),1); stimgroup{i}(:) = {num2str(i)};
    end
    tuningstats.tuning.rate.mu = cellfun(@mean,rate);
    tuningstats.tuning.stim.mu = cellfun(@mean,stim);
    tuningstats.tuning.pval = anova1(cell2mat(rate),vertcat(stimgroup{:}),'off'); % one-way unbalanced anova
else % get both mean and std of response by bootstrapping (slow)
    rate_mu = zeros(nbootstraps,nbins-1);
    stim_mu = zeros(nbootstraps,nbins-1);
    for i=1:nbins-1
        indx = find(xt>binedges(i) & xt<binedges(i+1));
        if length(indx)>bootstrap_samp % are there enough observations to bootstrap?
            for j=1:nbootstraps
                randindx = randperm(length(indx)); randindx = randindx(1:bootstrap_samp); indx2 = indx(randindx);
                rate_mu(j,i) = mean(yt(indx2)/temporal_binwidth);
                stim_mu(j,i) = mean(xt(indx2));
            end
        else % in case there aren't enough observations to bootstrap
            rate_mu(:,i) = mean(yt(indx)/temporal_binwidth);
            stim_mu(:,i) = mean(xt(indx));
        end
    end
end
tuningstats.tuning.rate.mu = mean(rate_mu);
tuningstats.tuning.rate.sem = std(rate_mu)/sqrt(nbootstraps);
tuningstats.tuning.stim.mu = mean(stim_mu);
tuningstats.tuning.stim.sem = std(stim_mu)/sqrt(nbootstraps);
tuningstats.tuning.pval = anova1(rate_mu,[],'off');  % one-way balanced anova
end