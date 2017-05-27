function PlotUnit(behv,unit)

ntrl = length(behv.trials);
correct = behv.stats.trlindx.correct;
incorrect = behv.stats.trlindx.incorrect;
crazy = behv.stats.trlindx.crazy;

% behavioural data
behv_all = behv.trials(~crazy); ntrls_all = length(behv_all);
behv_correct = behv.trials(correct); ntrls_correct = length(behv_correct);
behv_incorrect = behv.trials(incorrect); ntrls_incorrect = length(behv_incorrect);
% neural data
spks_all = unit.trials(~crazy);
spks_correct = unit.trials(correct); 
spks_incorrect = unit.trials(incorrect);

%% order trials based on trial duration
Td = [behv_all.t_end] - [behv_all.t_beg];
[~,indx] = sort(Td);
behv_all = behv_all(indx);
spks_all = spks_all(indx);

Td = [behv_correct.t_end] - [behv_correct.t_beg];
[~,indx] = sort(Td);
behv_correct = behv_correct(indx);
spks_correct = spks_correct(indx);

Td = [behv_incorrect.t_end] - [behv_incorrect.t_beg];
[~,indx] = sort(Td);
behv_incorrect = behv_incorrect(indx);
spks_incorrect = spks_incorrect(indx);

%% raster plot - aligned to start of trial
figure; hold on;
for i=1:ntrls_all
    if ~isempty(spks_all(i).tspk)
        plot(spks_all(i).tspk(1:3:end),i,'ob','markersize',0.2,'markerFacecolor','b');
    end
end
xlim([0 4]); axis off;

%% raster plot - aligned to end of trial
figure; hold on;
for i=1:ntrls_all
    if ~isempty(spks_all(i).tspk2end)
        plot(spks_all(i).tspk2end(1:4:end),i,'ob','markersize',0.2,'markerFacecolor','b');
    end
end
xlim([-4 0]); axis off;

%% raster plot - normalised by trial duration
figure; hold on;
for i=1:ntrls_all
    if ~isempty(spks_all(i).reltspk)
        plot(spks_all(i).reltspk,i,'ob','markersize',0.2,'markerFacecolor','b');
    end
end
xlim([0 1]); axis off;

%% psth - aligned to start of trial
% find longest trial
ns = zeros(1,ntrls_all);
for i=1:ntrls_all
    ns(i) = length(spks_all(i).nspk);
end
ns_max = max(ns);
% store responses in a matrix (Trial x Time)
nspk = nan(ntrls_all,ns_max);
for i=1:ntrls_all
    nspk(i,1:ns(i)) = spks_all(i).nspk;
end
trlkrnl = ones(100,1)/100;
nspk = conv2nan(nspk, trlkrnl);
% plot
figure; imagesc(nspk/0.012,[0 5]);
set(gca,'Ydir','normal');

%% psth - aligned to end of trial
% find longest trial
ns = zeros(1,ntrls_all);
for i=1:ntrls_all
    ns(i) = length(spks_all(i).nspk2end);
end
ns_max = max(ns);
% store responses in a matrix (Trial x Time)
nspk2end = nan(ntrls_all,ns_max);
for i=1:ntrls_all
    nspk2end(i,end-ns(i)+1:end) = spks_all(i).nspk2end;
end
trlkrnl = ones(100,1)/100;
nspk2end = conv2nan(nspk2end, trlkrnl);
% plot
figure; imagesc(nspk2end/0.012,[0 5]);
set(gca,'Ydir','normal');

%% psth - normalised by trial duration
ns_max = length(spks_all(1).relnspk);
relnspk = nan(ntrls_all,ns_max);
for i=1:ntrls_all
    relnspk(i,:) = spks_all(i).relnspk;
end
trlkrnl = ones(100,1)/100;
relnspk = conv2(relnspk, trlkrnl, 'valid');
% plot
figure; imagesc(relnspk/0.01,[0 5]);
set(gca,'Ydir','normal');