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
    ts = trial_behv_temp.ts; % time-vector aligned to trial beginning
    [nspk,~]=hist(trial_spks_temp.tspk,ts); nspk = nspk(:);
    sig = prs.spkkrnlwidth; %filter width
    sz = prs.spkkrnlsize; %filter size
    t2 = linspace(-sz/2, sz/2, sz);
    h = exp(-t2.^2/(2*sig^2));
    h = h/sum(h);
    nspk = conv(nspk,h,'same');
    trials_spks(i).nspk = nspk; % smoothed spike train
end

%% compute spiketimes relative to end-of-trial
for i=1:ntrls
    trial_spks_temp = trials_spks(i);
    trial_behv_temp = trials_behv(i);
    Td = trial_behv_temp.t_end - trial_behv_temp.t_beg;
    trial_spks_temp.tspk2end = trial_spks_temp.tspk - Td;
    trials_spks(i).tspk2end = trial_spks_temp.tspk2end;
end

% convolve with gaussian kernel
for i=1:ntrls
    trial_spks_temp = trials_spks(i);
    trial_behv_temp = trials_behv(i);
    ts = trial_behv_temp.ts;
    ts = ts - ts(end); % time-vector aligned to trial end
    [nspk2end,~]=hist(trial_spks_temp.tspk2end,ts); nspk2end = nspk2end(:);
    sig = prs.spkkrnlwidth; %filter width
    sz = prs.spkkrnlsize; %filter size
    t2 = linspace(-sz/2, sz/2, sz);
    h = exp(-t2.^2/(2*sig^2));
    h = h/sum(h);
    nspk2end = conv(nspk2end,h,'same');
    trials_spks(i).nspk2end = nspk2end; % smoothed spike train
end
%% Compute spikes relative to reward time
for i=1:ntrls
    trial_spks_temp = trials_spks(i);
    trial_behv_temp = trials_behv(i);
    Tr = trial_behv_temp.t_rew-trial_behv_temp.t_beg; 
    trial_spks_temp.tspk2rew = trial_spks_temp.tspk-Tr;
    trials_spks(i).tspk2rew = trial_spks_temp.tspk2rew;
end

% convolve with gaussian kernel (old stuff)
for i=1:ntrls
    trial_spks_temp = trials_spks(i);
    trial_behv_temp = trials_behv(i);
    ts = trial_behv_temp.ts;
    Tr = trial_behv_temp.t_rew-trial_behv_temp.t_beg;
    [nspk2rew,~]=hist(trial_spks_temp.tspk2rew,ts); nspk2rew = nspk2rew(:);
    sig = prs.spkkrnlwidth; %filter width
    sz = prs.spkkrnlsize; %filter size
    t2 = linspace(-sz/2, sz/2, sz);
    h = exp(-t2.^2/(2*sig^2));
    h = h/sum(h);
    nspk2rew = conv(nspk2rew,h,'same');
    trials_spks(i).nspk2rew = nspk2rew; % smoothed spike train
end

%% convert spiketimes to percentile of total trial duration
% by stretching/compressing all trials to the "same" length
for i=1:ntrls
    trial_spks_temp = trials_spks(i);
    trial_behv_temp = trials_behv(i);
    Td = trial_behv_temp.t_end - trial_behv_temp.t_beg;
    trial_spks_temp.reltspk = (trial_spks_temp.tspk)/Td;
    trials_spks(i).reltspk = trial_spks_temp.reltspk;
end

% convolve with gaussian kernel
for i=1:ntrls
    trial_spks_temp = trials_spks(i);
    trial_behv_temp = trials_behv(i);
    Td = trial_behv_temp.t_end - trial_behv_temp.t_beg;
    ts = linspace(0,1,(1/prs.binwidth_warp)+1);
    [relnspk,~]=hist(trial_spks_temp.reltspk,ts); relnspk = relnspk(:)/Td;
    sig = prs.spkkrnlwidth; %filter width
    sz = prs.spkkrnlsize; %filter size
    t2 = linspace(-sz/2, sz/2, sz);
    h = exp(-t2.^2/(2*sig^2));
    h = h/sum(h);
    relnspk = conv(relnspk,h,'same');
    trials_spks(i).relnspk = relnspk; % smoothed spike train
end

%% cross-correlations between neural response and task variables 
%% (using full time-series: includes inter-trial intervals)
corr_lag = prs.corr_lag;
binwidth = prs.binwidth;
corrgrams(nseries) = struct();
for i=1:nseries
    r = tseries_spks.smr(i).nspk; % response
    tseries_behv_temp = tseries_behv.smr(i);
    flds = fields(tseries_behv_temp);
    nflds = length(flds);
    for j=1:nflds
        if ~(strcmp(flds{j},'ts') | strcmp(flds{j},'ntrls'))
            s = tseries_behv_temp.(flds{j});
            corrgrams(i).(flds{j}) = xcorr(s,r,prs.corr_lag)./sqrt(xcorr(s,prs.corr_lag).*xcorr(r,prs.corr_lag));
        end
    end
    %% additional variables
    % distance to firefly
    dist2fly_y = (tseries_behv_temp.yfp - tseries_behv_temp.ymp);
    corrgrams(i).dist2fly_y = xcorr(dist2fly_y,r,prs.corr_lag);
    dist2fly_x = (tseries_behv_temp.xfp - tseries_behv_temp.xmp);
    corrgrams(i).dist2fly_x = xcorr(dist2fly_x,r,prs.corr_lag);
    dist2fly = sqrt(dist2fly_x.^2 + dist2fly_y.^2);
    corrgrams(i).dist2fly = xcorr(dist2fly,r,prs.corr_lag);
    %% timescale
    corrgrams(i).ts = -corr_lag*binwidth:binwidth:corr_lag*binwidth; corrgrams(i).ts = corrgrams(i).ts(:);
end