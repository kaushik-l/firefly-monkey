function [tseries_spks,trials_spks,corrgrams] = ...
    AnalyseUnit(exp_name,tseries_spks,trials_spks,tseries_behv,trials_behv,prs)

nseries = length(tseries_behv.smr);
ntrls = length(trials_behv);

%% convolve spike trains with gaussian kernel (full time-series)
for i=1:nseries
    tseries_spks_temp = tseries_spks.smr(i);
    tseries_behv_temp = tseries_behv.smr(i);
    ts = tseries_behv_temp.ts;
    [nspk,~]=hist(tseries_spks_temp.tspk,ts); nspk = nspk(:);
    %% convolve with gaussian kernel
    sig = prs.spkkrnlwidth; %filter width
    sz = prs.spkkrnlsize; %filter size
    t2 = linspace(-sz/2, sz/2, sz);
    h = exp(-t2.^2/(2*sig^2));
    h = h/sum(h);
    nspk = conv(nspk,h,'same');
    tseries_spks.smr(i).nspk = nspk; % smoothed spike train
end

%% convolve spike trains with gaussian kernel (trials)
for i=1:ntrls
    trial_spks_temp = trials_spks(i);
    trial_behv_temp = trials_behv(i);
    ts = trial_behv_temp.ts;
    [nspk,~]=hist(trial_spks_temp.tspk,ts); nspk = nspk(:);
    %% convolve with gaussian kernel
    sig = prs.spkkrnlwidth; %filter width
    sz = prs.spkkrnlsize; %filter size
    t2 = linspace(-sz/2, sz/2, sz);
    h = exp(-t2.^2/(2*sig^2));
    h = h/sum(h);
    nspk = conv(nspk,h,'same');
    trials_spks(i).nspk = nspk; % smoothed spike train
end

%% cross-correlations between neural response and task variables 
%% (using full time-series: includes inter-trial intervals)
corr_lag = prs.corr_lag;
binwidth = prs.binwidth;
for i=1:nseries
    r = tseries_spks.smr(i).nspk; % response
    tseries_behv_temp = tseries_behv.smr(i);
    flds = fields(tseries_behv_temp);
    nflds = length(flds);
    for j=1:nflds
        if ~(strcmp(flds,'ts') | strcmp(flds,'ntrls'))
            s = tseries_behv_temp.(flds{j});
            corrgrams.(flds{j}) = xcorr(s,r,prs.corr_lag)./sqrt(xcorr(s,prs.corr_lag).*xcorr(r,prs.corr_lag));
        end
    end
    %% additional variables
    % distance to firefly
    dist2fly_y = (tseries_behv_temp.yfp - tseries_behv_temp.ymp);
    corrgrams.dist2fly_y = xcorr(dist2fly_y,r,prs.corr_lag)./sqrt(xcorr(dist2fly_y,prs.corr_lag).*xcorr(r,prs.corr_lag));
    dist2fly_x = (tseries_behv_temp.xfp - tseries_behv_temp.xmp);
    corrgrams.dist2fly_x = xcorr(dist2fly_x,r,prs.corr_lag)./sqrt(xcorr(dist2fly_x,prs.corr_lag).*xcorr(r,prs.corr_lag));
    dist2fly = sqrt(dist2fly_x.^2 + dist2fly_y.^2);
    corrgrams.dist2fly = xcorr(dist2fly,r,prs.corr_lag)./sqrt(xcorr(dist2fly,prs.corr_lag).*xcorr(r,prs.corr_lag));
    dist_tot = sqrt(dist2fly_x.^2 + dist2fly_y.^2);
    %% timescale
    corrgrams.ts = -corr_lag*binwidth:binwidth:corr_lag*binwidth; corrgrams.ts = corrgrams.ts(:);
end