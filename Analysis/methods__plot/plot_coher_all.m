% plot avg lfp coherence


% load data from all sessions
freq = experiments.sessions(i).populations.lfps.stats.trialtype.all.crosslfp.freq; 

for i = 1:length(experiments.sessions)
coher12(i,:,:) = experiments.sessions(i).populations.lfps.stats.trialtype.all.crossarea.coher12; % MST--><PPC>
coher21(i,:,:) = experiments.sessions(i).populations.lfps.stats.trialtype.all.crossarea.coher21; % PPC--><MST>
end

% take mean of all sessions
coherence_MSTtoPPC = squeeze(nanmean(coher12)); 
coherence_PPCtoMST = squeeze(nanmean(coher21)); 

% plot
%% MST to PPC
figure; hold on; 
for k=1:24, plot(freq,coherence_MSTtoPPC(:,k)); end
plot(freq, mean(coherence_PPCtoMST,2),'Color', 'k', 'LineWidth',3)
set(gca,'xlim',[2 50], 'ylim', [0.75 0.8], 'yTick', [0.75 0.8], 'TickDir', 'out', 'FontSize', 20); box off
title('MST --> <PPC>'); xlabel('frequency');  ylabel('coherence');

%% PPC to MST
figure; hold on; 
for k=1:96, plot(freq,coherence_PPCtoMST(:,k), 'Color', 'c'); end
plot(freq, mean(coherence_PPCtoMST,2),'Color', 'k', 'LineWidth',3)
set(gca,'xlim',[2 50], 'ylim', [0.75 0.8], 'yTick', [0.75 0.8], 'TickDir', 'out', 'FontSize', 20); box off
title('PPC --> <MST>'); xlabel('frequency');  ylabel('coherence');