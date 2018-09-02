function sta = SpikeTriggeredLFP(lfp,ts,tspk,timewindow,sta_window,duration_nanpad,spectralparams)

%% concatenate
dt = median(diff(cell2mat(ts')));
[~,~,~,xt_pad,~,yt_pad] = ConcatenateTrials(lfp,[],tspk,ts,timewindow,[],duration_nanpad);
xt_pad = real(xt_pad); % if the input is an analytic signal, ignore imaginary part

%% compute sta
winlength = round(sta_window/dt);
spkindx = find(yt_pad==1); nspk = length(spkindx);
lfp_segment = nan(nspk,diff(winlength)+1);
for i=1:nspk
    lfp_segment(i,:) = xt_pad(spkindx(i)+winlength(1):spkindx(i)+winlength(2));
end
% output sta
sta.t = linspace(-1,1,diff(winlength)+1); sta.lfp = nanmean(lfp_segment);

%% repeat with small window for esimating spike-field coherence
% compute sta
coherence_window = [-0.5 0.5]; % 1Hz resolution
winlength = round(coherence_window/dt);
spkindx = find(yt_pad==1); nspk = length(spkindx);
lfp_segment = nan(nspk,diff(winlength)+1);
for i=1:nspk
    lfp_segment(i,:) = xt_pad(spkindx(i)+winlength(1):spkindx(i)+winlength(2));
end
use_spkindx = find(~any(isnan(lfp_segment),2)); % use only spikes with NO nans in the lfp segment around them
if numel(use_spkindx) > 1
    [S_lfp,f]=mtspectrumc(lfp_segment(use_spkindx,:)',spectralparams); % AVERAGE spectrum of lfp segments
    S_sta=mtspectrumc(mean(lfp_segment(use_spkindx,:)),spectralparams); % spectrum of AVERAGE lfp segments
    % compute sfc
    coh = S_sta(:)./S_lfp(:);
    coh_unbiased = (numel(use_spkindx)*coh - 1)/(numel(use_spkindx) - 1); % Grasse & Moxon (2010)
    % output sfc
    sta.f = f; sta.sfc = coh_unbiased;
else
    sta.f = []; sta.sfc = []; 
end