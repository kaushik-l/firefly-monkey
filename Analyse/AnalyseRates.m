function [trials_spks,stats] = AnalyseRates(exp_name,trials_spks,trials_behv,behv_stats,prs)

% nseries = length(tseries_behv.smr);
ntrls = length(trials_behv);

%% convolve spike trains with gaussian kernel (trials)
for i=1:ntrls
    trial_spks_temp = trials_spks(i);
    trial_behv_temp = trials_behv(i);
    ts = trial_behv_temp.ts;
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
    ts = ts - ts(end);
    [nspk2end,~]=hist(trial_spks_temp.tspk2end,ts); nspk2end = nspk2end(:);
    sig = prs.spkkrnlwidth; %filter width
    sz = prs.spkkrnlsize; %filter size
    t2 = linspace(-sz/2, sz/2, sz);
    h = exp(-t2.^2/(2*sig^2));
    h = h/sum(h);
    nspk2end = conv(nspk2end,h,'same');
    trials_spks(i).nspk2end = nspk2end; % smoothed spike train
end

%% compute spiketimes relative to perturbation
% for i=1:ntrls
%     trial_spks_temp = trials_spks(i);
%     trial_behv_temp = trials_behv(i);
%     Tp = trial_behv_temp.t_ptb;
%     trial_spks_temp.tspk2ptb = trial_spks_temp.tspk - Tp;
%     trials_spks(i).tspk2ptb = trial_spks_temp.tspk2ptb;
% end
% 
% % convolve with gaussian kernel
% for i=1:ntrls
%     trial_spks_temp = trials_spks(i);
%     trial_behv_temp = trials_behv(i);
%     ts = trial_behv_temp.ts;
%     ts = ts - ts((ts-Tp)==min(abs(ts-Tp)));
%     [nspk2end,~]=hist(trial_spks_temp.tspk2end,ts); nspk2end = nspk2end(:);
%     sig = prs.spkkrnlwidth; %filter width
%     sz = prs.spkkrnlsize; %filter size
%     t2 = linspace(-sz/2, sz/2, sz);
%     h = exp(-t2.^2/(2*sig^2));
%     h = h/sum(h);
%     nspk2end = conv(nspk2end,h,'same');
%     trials_spks(i).nspk2end = nspk2end; % smoothed spike train
% end

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

%% peak response
for i=1:ntrls
    [trials_spks(i).peak_rate,trials_spks(i).peak_time] = max(trials_spks(i).nspk/prs.binwidth_abs);
end

%% stats
stats = [];
binwidth_abs = prs.binwidth_abs;
binwidth_warp = prs.binwidth_warp;

% trial-averaged responses for different ground plane densities
temp = [];
density = unique([trials_behv.floordensity]);
for i=1:length(density)
   trial_indx = ([trials_behv.floordensity] == density(i));
   stats.density(i).val = density(i);
   
   nspk = struct2mat(trials_spks(trial_indx),'nspk','start');
   stats.density(i).nspk.mu = nanmean(nspk)/binwidth_abs;
   stats.density(i).nspk.sig = (nanstd(nspk)/binwidth_abs)/sqrt(sum(trial_indx));
   stats.density(i).nspk.t = binwidth_abs:binwidth_abs:size(nspk,2)*binwidth_abs;
   % peak within the [0.4,2] seconds of trial onset (disregard period when target was ON)
   [stats.density(i).nspk.mupeak,stats.density(i).nspk.tpeak] = ...
       max(stats.density(i).nspk.mu(stats.density(i).nspk.t>0.4 & stats.density(i).nspk.t<2));
   stats.density(i).nspk.tpeak = stats.density(i).nspk.tpeak*binwidth_abs + 0.4;
   % store vector of peak responses to calculate significance
   for j=1:size(nspk,1)
       temp(i).nspkpeak(j) = max(nspk(j,stats.density(i).nspk.t>0.4 & stats.density(i).nspk.t<2))/binwidth_abs;
   end
   
   nspk2end = struct2mat(trials_spks(trial_indx),'nspk2end','end');
   stats.density(i).nspk2end.mu = nanmean(nspk2end)/binwidth_abs;
   stats.density(i).nspk2end.sig = (nanstd(nspk2end)/binwidth_abs)/sqrt(sum(trial_indx));
   stats.density(i).nspk2end.t = -size(nspk2end,2)*binwidth_abs:binwidth_abs:-binwidth_abs;
   % peak within [-2,-0.3] seconds of trial end
   [stats.density(i).nspk2end.mupeak,stats.density(i).nspk2end.tpeak] = ...
       max(stats.density(i).nspk2end.mu(stats.density(i).nspk2end.t>-2 & stats.density(i).nspk2end.t<-0.3));
   stats.density(i).nspk2end.tpeak = stats.density(i).nspk2end.tpeak*binwidth_abs - 2;
   % store vector of peak responses to calculate significance
   for j=1:size(nspk,1)
       temp(i).nspk2endpeak(j) = max(nspk2end(j,stats.density(i).nspk2end.t>-2 & stats.density(i).nspk2end.t<-0.3))/binwidth_abs;
   end
   
   relnspk = struct2mat(trials_spks(trial_indx),'relnspk','start');
   stats.density(i).relnspk.mu = nanmean(relnspk)/binwidth_abs;
   stats.density(i).relnspk.sig = (nanstd(relnspk)/binwidth_abs)/sqrt(sum(trial_indx));
   stats.density(i).relnspk.t = linspace(0,1,size(relnspk,2));
   % peak anywhere during the trial
   [stats.density(i).relnspk.mupeak,stats.density(i).relnspk.tpeak] = max(stats.density(i).relnspk.mu);
   stats.density(i).relnspk.tpeak = stats.density(i).relnspk.tpeak*binwidth_warp;
   % store vector of peak responses to calculate significance
   for j=1:size(nspk,1)
       temp(i).relnspkpeak(j) = max(relnspk(j,:))/binwidth_warp;
   end
end
for i=1:length(density)
    for j=1:length(density)
        [~,stats.nspkpeak.density.p(i,j)] = ttest2(temp(i).nspkpeak,temp(j).nspkpeak);
        [~,stats.nspk2endpeak.density.p(i,j)] = ttest2(temp(i).nspk2endpeak,temp(j).nspk2endpeak);
        [~,stats.relnspkpeak.density.p(i,j)] = ttest2(temp(i).relnspkpeak,temp(j).relnspkpeak);
    end
end

% trial-averaged responses for rewarded and unrewarded trials
temp = [];
reward = {'correct','incorrect'};
for i=1:length(reward)
    trial_indx = behv_stats.trlindx.(reward{i});
    stats.reward(i).val = reward{i};
    
    nspk = struct2mat(trials_spks(trial_indx),'nspk','start');
    stats.reward(i).nspk.mu = nanmean(nspk)/binwidth_abs;
    stats.reward(i).nspk.sig = (nanstd(nspk)/binwidth_abs)/sqrt(sum(trial_indx));
    stats.reward(i).nspk.t = binwidth_abs:binwidth_abs:size(nspk,2)*binwidth_abs;
   % peak within the [0.4,2] seconds of trial onset (disregard period when target was ON)
    [stats.reward(i).nspk.mupeak,stats.reward(i).nspk.tpeak] = ...
        max(stats.reward(i).nspk.mu(stats.reward(i).nspk.t>0.4 & stats.reward(i).nspk.t<2));
    stats.reward(i).nspk.tpeak = stats.reward(i).nspk.tpeak*binwidth_abs + 0.4;
    % store vector of peak responses to calculate significance
    for j=1:size(nspk,1)
        temp(i).nspkpeak(j) = max(nspk(j,stats.reward(i).nspk.t>0.4 & stats.reward(i).nspk.t<2))/binwidth_abs;
    end
    
    nspk2end = struct2mat(trials_spks(trial_indx),'nspk2end','end');
    stats.reward(i).nspk2end.mu = nanmean(nspk2end)/binwidth_abs;
    stats.reward(i).nspk2end.sig = (nanstd(nspk2end)/binwidth_abs)/sqrt(sum(trial_indx));
    stats.reward(i).nspk2end.t = -size(nspk2end,2)*binwidth_abs:binwidth_abs:-binwidth_abs;
   % peak within [-2,-0.3] seconds of trial end
    [stats.reward(i).nspk2end.mupeak,stats.reward(i).nspk2end.tpeak] = ...
        max(stats.reward(i).nspk2end.mu(stats.reward(i).nspk2end.t>-2 & stats.reward(i).nspk2end.t<-0.3));
    stats.reward(i).nspk2end.tpeak = stats.reward(i).nspk2end.tpeak*binwidth_abs - 2;
    % store vector of peak responses to calculate significance
    for j=1:size(nspk,1)
        temp(i).nspk2endpeak(j) = max(nspk2end(j,stats.reward(i).nspk2end.t>-2 & stats.reward(i).nspk2end.t<-0.3))/binwidth_abs;
    end
    
    relnspk = struct2mat(trials_spks(trial_indx),'relnspk','start');
    stats.reward(i).relnspk.mu = nanmean(relnspk)/binwidth_abs;
    stats.reward(i).relnspk.sig = (nanstd(relnspk)/binwidth_abs)/sqrt(sum(trial_indx));
    stats.reward(i).relnspk.t = linspace(0,1,size(relnspk,2));
    % peak anywhere during the trial
    [stats.reward(i).relnspk.mupeak,stats.reward(i).relnspk.tpeak] = max(stats.reward(i).relnspk.mu);
    stats.reward(i).relnspk.tpeak = stats.reward(i).relnspk.tpeak*binwidth_warp;
    % store vector of peak responses to calculate significance
    for j=1:size(nspk,1)
        temp(i).relnspkpeak(j) = max(relnspk(j,:))/binwidth_warp;
    end
end
for i=1:length(reward)
    for j=1:length(reward)
        [~,stats.nspkpeak.reward.p(i,j)] = ttest2(temp(i).nspkpeak,temp(j).nspkpeak);
        [~,stats.nspk2endpeak.reward.p(i,j)] = ttest2(temp(i).nspk2endpeak,temp(j).nspk2endpeak);
        [~,stats.relnspkpeak.reward.p(i,j)] = ttest2(temp(i).relnspkpeak,temp(j).relnspkpeak);
    end
end

% trial-averaged responses for different accuracies
temp = [];
dist2fly = zeros(1,ntrls);
for i=1:ntrls
    dist2fly(i) = behv_stats.pos_rel.r_fly{i}(end);
end
accuracy = [0 25; 25 50; 50 75; 75 100];
for i=1:length(accuracy)
   trial_indx = (dist2fly>=prctile(dist2fly,accuracy(i,1)) & dist2fly<prctile(dist2fly,accuracy(i,2)));
   stats.accuracy(i).val = accuracy(i,:);
   
   nspk = struct2mat(trials_spks(trial_indx),'nspk','start');
   stats.accuracy(i).nspk.mu = nanmean(nspk)/binwidth_abs;
   stats.accuracy(i).nspk.sig = (nanstd(nspk)/binwidth_abs)/sqrt(sum(trial_indx));
   stats.accuracy(i).nspk.t = binwidth_abs:binwidth_abs:size(nspk,2)*binwidth_abs;
   % peak within the [0.4,2] seconds of trial onset (disregard period when target was ON)
   [stats.accuracy(i).nspk.mupeak,stats.accuracy(i).nspk.tpeak] = ...
       max(stats.accuracy(i).nspk.mu(stats.accuracy(i).nspk.t>0.4 & stats.accuracy(i).nspk.t<2));
   stats.accuracy(i).nspk.tpeak = stats.accuracy(i).nspk.tpeak*binwidth_abs + 0.4;
   % store vector of peak responses to calculate significance
   for j=1:size(nspk,1)
       temp(i).nspkpeak(j) = max(nspk(j,stats.accuracy(i).nspk.t>0.4 & stats.accuracy(i).nspk.t<2))/binwidth_abs;
   end
   
   nspk2end = struct2mat(trials_spks(trial_indx),'nspk2end','end');
   stats.accuracy(i).nspk2end.mu = nanmean(nspk2end)/binwidth_abs;
   stats.accuracy(i).nspk2end.sig = (nanstd(nspk2end)/binwidth_abs)/sqrt(sum(trial_indx));
   stats.accuracy(i).nspk2end.t = -size(nspk2end,2)*binwidth_abs:binwidth_abs:-binwidth_abs;
   % peak within [-2,-0.3] seconds of trial end
   [stats.accuracy(i).nspk2end.mupeak,stats.accuracy(i).nspk2end.tpeak] = ...
       max(stats.accuracy(i).nspk2end.mu(stats.accuracy(i).nspk2end.t>-2 & stats.accuracy(i).nspk2end.t<-0.3));
   stats.accuracy(i).nspk2end.tpeak = stats.accuracy(i).nspk2end.tpeak*binwidth_abs - 2;
   % store vector of peak responses to calculate significance
   for j=1:size(nspk,1)
       temp(i).nspk2endpeak(j) = max(nspk2end(j,stats.accuracy(i).nspk2end.t>-2 & stats.accuracy(i).nspk2end.t<-0.3))/binwidth_abs;
   end
   
   relnspk = struct2mat(trials_spks(trial_indx),'relnspk','start');
   stats.accuracy(i).relnspk.mu = nanmean(relnspk)/binwidth_abs;
   stats.accuracy(i).relnspk.sig = (nanstd(relnspk)/binwidth_abs)/sqrt(sum(trial_indx));
   stats.accuracy(i).relnspk.t = linspace(0,1,size(relnspk,2));
   % peak anywhere during the trial
   [stats.accuracy(i).relnspk.mupeak,stats.accuracy(i).relnspk.tpeak] = max(stats.accuracy(i).relnspk.mu);
   stats.accuracy(i).relnspk.tpeak = stats.accuracy(i).relnspk.tpeak*binwidth_warp;
   % store vector of peak responses to calculate significance
   for j=1:size(nspk,1)
       temp(i).relnspkpeak(j) = max(relnspk(j,:))/binwidth_warp;
   end
end
for i=1:length(accuracy)
    for j=1:length(accuracy)
        [~,stats.nspkpeak.accuracy.p(i,j)] = ttest2(temp(i).nspkpeak,temp(j).nspkpeak);
        [~,stats.nspk2endpeak.accuracy.p(i,j)] = ttest2(temp(i).nspk2endpeak,temp(j).nspk2endpeak);
        [~,stats.relnspkpeak.accuracy.p(i,j)] = ttest2(temp(i).relnspkpeak,temp(j).relnspkpeak);
    end
end
