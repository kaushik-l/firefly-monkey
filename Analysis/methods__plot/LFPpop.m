%function exp = LFPpop


%% load relevant variables to plot LFP spectrum
% path = '/Volumes/Eric500'; %'/Users/eavilao/Documents/Temp_data/lfp analysis';
% cd(path)
%
% fnames = dir('*.mat');
%
% for i = 1:length(fnames)
%     load(fnames(i).name); cnt = 1;
%     for sess = 1:length(experiments.sessions)
%         if ~isempty(experiments.sessions(sess).lfps(1).stats)
%             if experiments.sessions(sess).monk_id == 53, ch=1:48;
%                 [channel_id,electrode_id] = MapChannel2Electrode('utah2x48');
%                 [~,indx] = sort(electrode_id); reorderindx = channel_id(indx); ch=reorderindx(1:48);
%             else ch=1:96;end
%             exp(i).monk_id(cnt) = experiments.sessions(sess).monk_id;
%             for j = 1:length(ch)
%                 exp(i).session(cnt).lfps(j).stats = experiments.sessions(sess).lfps(ch(j)).stats;
%             end
%             cnt = cnt+1;
%         end
%     end
%     disp('Clearing experiments... . . .')
%     clear experiments
% end
%
% save('exp','exp');

%% nanmean across 96 ch per session and normalize by max
cnt1=1; cnt2=1; cnt3=1;
% load exp
for i = 1:length(exp)
    for sess = 1:length(exp(i).session)
        clear psd
        if ~isempty(exp(i).session(sess).lfps(1).stats) & exp(i).monk_id == 53;  %Schro
            for ch = 1:length(exp(i).session(1).lfps)
                clear psd_all psd_mobile psd_stationary psd_eyesfree psd_eyesfixed psd_err psd_corr psd_den1 psd_den2 regr_coeff_theta regr_coeff_beta
                psd_all(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.spectrum.psd;
                psd_mobile(ch,:) = exp(i).session(sess).lfps(ch).stats.epoch.mobile.spectrum.psd;
                psd_stationary(ch,:) = exp(i).session(sess).lfps(ch).stats.epoch.stationary.spectrum.psd;
                psd_eyesfree(ch,:) = exp(i).session(sess).lfps(ch).stats.epoch.eyesfree.spectrum.psd;
                if ~isempty(exp(i).session(sess).lfps(ch).stats.epoch.eyesfixed.spectrum.psd)
                    psd_eyesfixed(ch,:) = exp(i).session(sess).lfps(ch).stats.epoch.eyesfixed.spectrum.psd;
                else
                    psd_eyesfixed(ch,:) = NaN(1,size(psd_eyesfree,2));
                end
                psd_err(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.reward(1).spectrum.psd;
                psd_corr(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.reward(2).spectrum.psd;
                psd_den1(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.density(1).spectrum.psd;
                psd_den2(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.density(2).spectrum.psd;
                regr_coeff_theta(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.vwhv.thetafreq.regr_coeff;
                regr_coeff_beta(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.vwhv.betafreq.regr_coeff;
            end
            maxPSDval = max([max(nanmean(psd_mobile)) max(nanmean(psd_stationary)) max(nanmean(psd_eyesfree)) max(nanmean(psd_eyesfixed))]);
            monk(1).psd_sess.all.psd_mu_norm(cnt1,:) = nanmean(psd_all)/max(nanmean(psd_all));
            monk(1).psd_sess.mobile.psd_mu_norm(cnt1,:) = (nanmean(psd_mobile))/maxPSDval;
            monk(1).psd_sess.stationary.psd_mu_norm(cnt1,:) = (nanmean(psd_stationary))/maxPSDval;
            monk(1).psd_sess.motion_ratio(cnt1,:) = monk(1).psd_sess.stationary.psd_mu_norm(cnt1,:)./monk(1).psd_sess.mobile.psd_mu_norm(cnt1,:);
            monk(1).psd_sess.eyesfree.psd_mu_norm(cnt1,:) = (nanmean(psd_eyesfree))/maxPSDval;
            monk(1).psd_sess.eyesfixed.psd_mu_norm(cnt1,:) = (nanmean(psd_eyesfixed))/maxPSDval;
            monk(1).psd_sess.eyes_ratio(cnt1,:) = monk(1).psd_sess.eyesfixed.psd_mu_norm(cnt1,:)./monk(1).psd_sess.eyesfree.psd_mu_norm(cnt1,:);
            monk(1).psd_sess.err.psd_mu_norm(cnt1,:) = nanmean(psd_err)/max(nanmean(psd_err));
            monk(1).psd_sess.corr.psd_mu_norm(cnt1,:) = nanmean(psd_corr)/max(nanmean(psd_err));
            monk(1).psd_sess.acc_ratio(cnt1,:) = monk(1).psd_sess.err.psd_mu_norm(cnt1,:)./monk(1).psd_sess.corr.psd_mu_norm(cnt1,:);
            monk(1).psd_sess.den1.psd_mu_norm(cnt1,:) = nanmean(psd_den1)/max(nanmean(psd_den1));
            monk(1).psd_sess.den2.psd_mu_norm(cnt1,:) = nanmean(psd_den2)/max(nanmean(psd_den1));
            monk(1).psd_sess.den_ratio(cnt1,:) = monk(1).psd_sess.den2.psd_mu_norm(cnt1,:)./monk(1).psd_sess.den1.psd_mu_norm(cnt1,:);
            monk(1).psd_sess.regr_coeff_theta(cnt1,:) = nanmean(regr_coeff_theta);
            monk(1).psd_sess.regr_coeff_beta(cnt1,:) = nanmean(regr_coeff_beta);
            cnt1=cnt1+1;
        elseif ~isempty(exp(i).session(sess).lfps(1).stats) & exp(i).monk_id == 51; % Bruno
            clear psd_all psd_mobile psd_stationary psd_eyesfree psd_eyesfixed psd_err psd_corr psd_den1 psd_den2 regr_coeff_theta regr_coeff_beta
            for ch = 1:length(exp(i).session(1).lfps)
                psd_all(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.spectrum.psd;
                psd_mobile(ch,:) = exp(i).session(sess).lfps(ch).stats.epoch.mobile.spectrum.psd;
                psd_stationary(ch,:) = exp(i).session(sess).lfps(ch).stats.epoch.stationary.spectrum.psd;
                psd_eyesfree(ch,:) = exp(i).session(sess).lfps(ch).stats.epoch.eyesfree.spectrum.psd;
                if ~isempty(exp(i).session(sess).lfps(ch).stats.epoch.eyesfixed.spectrum.psd)
                    psd_eyesfixed(ch,:) = exp(i).session(sess).lfps(ch).stats.epoch.eyesfixed.spectrum.psd;
                else
                    psd_eyesfixed(ch,:) = NaN(1,size(psd_eyesfree,2));
                end
                psd_err(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.reward(1).spectrum.psd;
                psd_corr(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.reward(2).spectrum.psd;
                psd_den1(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.density(1).spectrum.psd;
                psd_den2(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.density(2).spectrum.psd;
                regr_coeff_theta(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.vwhv.thetafreq.regr_coeff;
                regr_coeff_beta(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.vwhv.betafreq.regr_coeff;
            end
            maxPSDval = max([max(nanmean(psd_mobile)) max(nanmean(psd_stationary)) max(nanmean(psd_eyesfree)) max(nanmean(psd_eyesfixed))]);
            monk(2).psd_sess.all.psd_mu_norm(cnt2,:) = nanmean(psd_all)/max(nanmean(psd_all));
            monk(2).psd_sess.mobile.psd_mu_norm(cnt2,:) = (nanmean(psd_mobile))/maxPSDval;
            monk(2).psd_sess.stationary.psd_mu_norm(cnt2,:) = (nanmean(psd_stationary))/maxPSDval;
            monk(2).psd_sess.motion_ratio(cnt2,:) = monk(2).psd_sess.stationary.psd_mu_norm(cnt2,:)./monk(2).psd_sess.mobile.psd_mu_norm(cnt2,:);
            monk(2).psd_sess.eyesfree.psd_mu_norm(cnt2,:) = (nanmean(psd_eyesfree))/maxPSDval;
            monk(2).psd_sess.eyesfixed.psd_mu_norm(cnt2,:) = (nanmean(psd_eyesfixed))/maxPSDval;
            monk(2).psd_sess.eyes_ratio(cnt2,:) = monk(2).psd_sess.eyesfixed.psd_mu_norm(cnt2,:)./monk(2).psd_sess.eyesfree.psd_mu_norm(cnt2,:);
            monk(2).psd_sess.err.psd_mu_norm(cnt2,:) = nanmean(psd_err)/max(nanmean(psd_err));
            monk(2).psd_sess.corr.psd_mu_norm(cnt2,:) = nanmean(psd_corr)/max(nanmean(psd_err));
            monk(2).psd_sess.acc_ratio(cnt2,:) = monk(2).psd_sess.err.psd_mu_norm(cnt2,:)./monk(2).psd_sess.corr.psd_mu_norm(cnt2,:);
            monk(2).psd_sess.den1.psd_mu_norm(cnt2,:) = nanmean(psd_den1)/max(nanmean(psd_den1));
            monk(2).psd_sess.den2.psd_mu_norm(cnt2,:) = nanmean(psd_den2)/max(nanmean(psd_den1));
            monk(2).psd_sess.den_ratio(cnt2,:) = monk(2).psd_sess.den2.psd_mu_norm(cnt2,:)./monk(2).psd_sess.den1.psd_mu_norm(cnt2,:);
            monk(2).psd_sess.regr_coeff_theta(cnt2,:) = nanmean(regr_coeff_theta);
            monk(2).psd_sess.regr_coeff_beta(cnt2,:) = nanmean(regr_coeff_beta);
            cnt2=cnt2+1;
        else ~isempty(exp(i).session(sess).lfps(1).stats) & exp(i).monk_id == 44; % Quigley
            clear psd_all psd_mobile psd_stationary psd_eyesfree psd_eyesfixed psd_err psd_corr psd_den1 psd_den2 regr_coeff_theta regr_coeff_beta
            for ch = 1:length(exp(i).session(1).lfps) % Quigley
                psd_all(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.spectrum.psd;
                psd_mobile(ch,:) = exp(i).session(sess).lfps(ch).stats.epoch.mobile.spectrum.psd;
                psd_stationary(ch,:) = exp(i).session(sess).lfps(ch).stats.epoch.stationary.spectrum.psd;
                psd_eyesfree(ch,:) = exp(i).session(sess).lfps(ch).stats.epoch.eyesfree.spectrum.psd;
                if ~isempty(exp(i).session(sess).lfps(ch).stats.epoch.eyesfixed.spectrum.psd)
                    psd_eyesfixed(ch,:) = exp(i).session(sess).lfps(ch).stats.epoch.eyesfixed.spectrum.psd;
                else
                    psd_eyesfixed(ch,:) = NaN(1,size(psd_eyesfree,2));
                end
                psd_err(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.reward(1).spectrum.psd;
                psd_corr(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.reward(2).spectrum.psd;
                psd_den1(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.density(1).spectrum.psd;
                psd_den2(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.density(2).spectrum.psd;
                regr_coeff_theta(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.vwhv.thetafreq.regr_coeff;
                regr_coeff_beta(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.vwhv.betafreq.regr_coeff;
            end
            maxPSDval = max([max(nanmean(psd_mobile)) max(nanmean(psd_stationary)) max(nanmean(psd_eyesfree)) max(nanmean(psd_eyesfixed))]);
            monk(3).psd_sess.all.psd_mu_norm(cnt3,:) = nanmean(psd_all)/max(nanmean(psd_all));
            monk(3).psd_sess.mobile.psd_mu_norm(cnt3,:) = (nanmean(psd_mobile))/maxPSDval;
            monk(3).psd_sess.stationary.psd_mu_norm(cnt3,:) = (nanmean(psd_stationary))/maxPSDval;
            monk(3).psd_sess.motion_ratio(cnt3,:) = monk(3).psd_sess.stationary.psd_mu_norm(cnt3,:)./monk(3).psd_sess.mobile.psd_mu_norm(cnt3,:);
            monk(3).psd_sess.eyesfree.psd_mu_norm(cnt3,:) = (nanmean(psd_eyesfree))/maxPSDval;
            monk(3).psd_sess.eyesfixed.psd_mu_norm(cnt3,:) = (nanmean(psd_eyesfixed))/maxPSDval;
            monk(3).psd_sess.eyes_ratio(cnt3,:) = monk(3).psd_sess.eyesfixed.psd_mu_norm(cnt3,:)./monk(3).psd_sess.eyesfree.psd_mu_norm(cnt3,:);
            monk(3).psd_sess.err.psd_mu_norm(cnt3,:) = nanmean(psd_err)/max(nanmean(psd_err));
            monk(3).psd_sess.corr.psd_mu_norm(cnt3,:) = nanmean(psd_corr)/max(nanmean(psd_err));
            monk(3).psd_sess.acc_ratio(cnt3,:) = monk(3).psd_sess.err.psd_mu_norm(cnt3,:)./monk(3).psd_sess.corr.psd_mu_norm(cnt3,:);
            monk(3).psd_sess.den1.psd_mu_norm(cnt3,:) = nanmean(psd_den1)/max(nanmean(psd_den1));
            monk(3).psd_sess.den2.psd_mu_norm(cnt3,:) = nanmean(psd_den2)/max(nanmean(psd_den1));
            monk(3).psd_sess.den_ratio(cnt3,:) = monk(3).psd_sess.den2.psd_mu_norm(cnt3,:)./monk(3).psd_sess.den1.psd_mu_norm(cnt3,:);
            monk(3).psd_sess.regr_coeff_theta(cnt3,:) = nanmean(regr_coeff_theta);
            monk(3).psd_sess.regr_coeff_beta(cnt3,:) = nanmean(regr_coeff_beta);
            cnt3=cnt3+1;
        end
    end
end

%% Avg across datasets (within monkey)
for i = 1:length(monk)
    if size(monk(i).psd_sess.all.psd_mu_norm,1) == 1
        monk(i).freq = exp(i).session(1).lfps(1).stats.trialtype.all.spectrum.freq;
        monk(i).freq_eye = exp(i).session(1).lfps(1).stats.trialtype.eyesfree.spectrum.freq;
        monk(i).psd.all = monk(i).psd_sess.all.psd_mu_norm;
        monk(i).psd.mobile = monk(i).psd_sess.mobile.psd_mu_norm;
        monk(i).psd.stationary = monk(i).psd_sess.stationary.psd_mu_norm;
        monk(i).psd.eyesfree = monk(i).psd_sess.eyesfree.psd_mu_norm;
        monk(i).psd.eyesfixed = monk(i).psd_sess.eyesfixed.psd_mu_norm;
        monk(i).psd.err = monk(i).psd_sess.err.psd_mu_norm;
        monk(i).psd.corr = monk(i).psd_sess.corr.psd_mu_norm;
        monk(i).psd.den1 = monk(i).psd_sess.den1.psd_mu_norm;
        monk(i).psd.den2 = monk(i).psd_sess.den2.psd_mu_norm;
        monk(i).psd.regr_coeff_theta = monk(i).psd_sess.regr_coeff_theta;
        monk(i).psd.regr_coeff_beta = monk(i).psd_sess.regr_coeff_beta;
    else
        monk(i).freq = exp(i).session(1).lfps(1).stats.trialtype.all.spectrum.freq;
        monk(i).freq_eye = exp(2).session(1).lfps(1).stats.epoch.eyesfree.spectrum.freq;
        monk(i).psd.all = nanmean(monk(i).psd_sess.all.psd_mu_norm); monk(i).psd.all_sem = std(monk(i).psd.all)/sqrt(size(monk(i).psd_sess.all.psd_mu_norm,1));
        monk(i).psd.mobile = nanmean(monk(i).psd_sess.mobile.psd_mu_norm); monk(i).psd.mobile_sem = std(monk(i).psd.mobile)/sqrt(length(monk(i).psd.mobile));
        monk(i).psd.stationary = nanmean(monk(i).psd_sess.stationary.psd_mu_norm); monk(i).psd.stationary_sem = std(monk(i).psd.stationary)/sqrt(length(monk(i).psd.stationary));
        monk(i).psd.eyesfree = nanmean(monk(i).psd_sess.eyesfree.psd_mu_norm); monk(i).psd.eyesfree_sem = std(monk(i).psd.eyesfree)/sqrt(length(monk(i).psd.eyesfree));
        monk(i).psd.eyesfixed = nanmean(monk(i).psd_sess.eyesfixed.psd_mu_norm);
        monk(i).psd.err = nanmean(monk(i).psd_sess.err.psd_mu_norm);
        monk(i).psd.corr = nanmean(monk(i).psd_sess.corr.psd_mu_norm);
        monk(i).psd.den1 = nanmean(monk(i).psd_sess.den1.psd_mu_norm);
        monk(i).psd.den2 = nanmean(monk(i).psd_sess.den2.psd_mu_norm);
        monk(i).psd.regr_coeff_theta = nanmean(monk(i).psd_sess.regr_coeff_theta);
        monk(i).psd.regr_coeff_beta = nanmean(monk(i).psd_sess.regr_coeff_beta);
    end
end

%% Avg across monkeys
for i = 1:length(monk)
    all(i,:) = monk(i).psd.all;
    mobile(i,:) = monk(i).psd.mobile;
    stationary(i,:) = monk(i).psd.stationary;
    eyesfree(i,:) = monk(i).psd.eyesfree;
    eyesfixed(i,:) = monk(i).psd.eyesfixed;
    err(i,:) = monk(i).psd.err;
    corr(i,:) = monk(i).psd.corr;
    den1(i,:) = monk(i).psd.den1;
    den2(i,:) = monk(i).psd.den2;
    regr_theta(i,:) = monk(i).psd.regr_coeff_theta;
    regr_beta(i,:) = monk(i).psd.regr_coeff_beta;
end

pop.freq = monk(1).freq; pop.freq_eye = monk(1).freq_eye;
pop.psd.all_mu = nanmean(all); pop.psd.all_sem = std(all)/sqrt(length(all));
pop.psd.mobile_mu = nanmean(mobile); pop.psd.mobile_sem = std(mobile)/sqrt(length(mobile));
pop.psd.stationary_mu = nanmean(stationary); pop.psd.stationary_sem = std(stationary)/sqrt(length(stationary));
pop.psd.eyesfree_mu = nanmean(eyesfree); pop.psd.eyesfree_sem = std(eyesfree)/sqrt(length(eyesfree));
pop.psd.eyesfixed_mu = nanmean(eyesfixed); pop.psd.eyesfixed_sem = std(eyesfixed)/sqrt(length(eyesfixed));
pop.psd.err_mu = nanmean(err); pop.psd.err_sem = std(err)/sqrt(length(err));
pop.psd.corr_mu = nanmean(corr); pop.psd.corr_sem = std(corr)/sqrt(length(corr));
pop.psd.den1_mu = nanmean(err); pop.psd.den1_sem = std(den1)/sqrt(length(den1));
pop.psd.den2_mu = nanmean(corr); pop.psd.den2_sem = std(den1)/sqrt(length(den2));
pop.psd.regr_coeff_theta_mu = nanmean(regr_theta); pop.psd.regr_coeff_theta_sem = std(regr_theta)/sqrt(length(regr_theta));
pop.psd.regr_coeff_beta_mu = nanmean(regr_beta); pop.psd.regr_coeff_beta_sem = std(regr_beta)/sqrt(length(regr_beta));

%save('psd_monk','pop', 'monk','exp')

%% ratios
mobile_ratio = []; eyes_ratio = []; acc_ratio = []; den_ratio = [];
for i = 1:length(monk)
    mobile_ratio = [mobile_ratio ; monk(i).psd_sess.motion_ratio];
    eyes_ratio = [eyes_ratio ; monk(i).psd_sess.eyes_ratio];
    acc_ratio = [acc_ratio ; monk(i).psd_sess.acc_ratio];
    den_ratio = [den_ratio ; monk(i).psd_sess.den_ratio];
end

%% plot

%% all
f = pop.freq;
psd = pop.psd.all_mu; psd_sem = pop.psd.all_sem;

%figure; plot(f,psd,'LineWidth',2,'Color','k');
shadedErrorBar(f,psd,psd_sem, 'lineprops','k');
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); %ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22, 'YScale', 'log'); box off; title('all');

% per monkey
f1 = monk(1).freq;
psd1 = monk(1).psd.all; psd2 = monk(2).psd.all; psd3 = monk(3).psd.all;
%psd1_sem = repmat(monk(1).psd.all_sem,[1 size(psd1,2)]); psd2_sem = repmat(monk(2).psd.all_sem,[1 size(psd2,2)]); psd3_sem = repmat(monk(3).psd.all_sem,[1 size(psd3,2)]);

figure; hold on;
plot(f1,psd1, 'Color', 'g', 'Linewidth',2); plot(f1,psd2, 'Color', 'b', 'Linewidth',2); plot(f1,psd3, 'Color', 'c', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); % ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off


%% mobile vs stationary
f = pop.freq;
psd1 = pop.psd.mobile_mu; psd1_sem = pop.psd.mobile_sem;
psd2 = pop.psd.stationary_mu; psd2_sem = pop.psd.stationary_sem;


figure; subplot(1,2,1); hold on; %plot(f,psd1,'Color', 'k', 'LineWidth',2); plot(f,psd2,'Color', 'r','LineWidth',2);
shadedErrorBar(f,psd1, psd1_sem,'lineprops','k');
shadedErrorBar(f,psd2, psd2_sem,'lineprops','r');
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); %ylabel('Power spectral density (\muV^2/Hz)');
box off; set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); ylim([0.0035 1]);
subplot(1,2,2); hold on; plot(mobile_ratio', 'k'); plot(nanmean(mobile_ratio), 'LineWidth',2, 'Color','k');
axis([1 50 0 6]); hline(1,'k'); xlabel('Frequency (Hz)'); ylabel('Power spectral density ratio');
box off; set(gca,'TickDir', 'out', 'FontSize', 22); title('motion');

l_lim = 12 ; h_lim = 19; % beta band
psd1_band = psd1(f>l_lim & f<h_lim); psd2_band = psd2(f>l_lim & f<h_lim);
figure; hold on;
errorbar(1,nanmean(psd1_band),std(psd1_band),'ok', 'MarkerFaceColor', 'k', 'LineWidth',1,'CapSize',0);
errorbar(2,nanmean(psd2_band),std(psd2_band),'or','MarkerFaceColor', 'r','LineWidth',1,'CapSize',0);
set(gca,'xlim', [0 3], 'TickDir', 'out', 'FontSize',18);
ylabel('\beta - Power spectral density'); ylim([0.05 0.2]);

% per monkey
f1 = monk(1).freq;
psd1_mob = monk(1).psd.mobile; psd2_mob = monk(2).psd.mobile; psd3_mob = monk(3).psd.mobile; psd1_st = monk(1).psd.stationary; psd2_st = monk(2).psd.stationary; psd3_st = monk(3).psd.stationary;

figure; hold on;
plot(f1,psd1_mob, 'Color', 'k', 'Linewidth',2); plot(f1,psd1_st, 'Color', 'r', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); %ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off; title('S');
psd1_mob_mu = nanmean(monk(1).psd.mobile(f>l_lim & f<h_lim)); psd1_mob_std = std(monk(1).psd.mobile(f>l_lim & f<h_lim));

figure; hold on;
plot(f1,psd2_mob, 'Color', 'k', 'Linewidth',2); plot(f1,psd2_st, 'Color', 'r', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)');%  ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off; title('B');

figure; hold on;
plot(f1,psd3_mob, 'Color', 'k', 'Linewidth',2); plot(f1,psd3_st, 'Color', 'r', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); % ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off; title('Q');

%% eyes free vs eyes fixed
f = pop.freq_eye;
psd1 = pop.psd.eyesfree_mu; psd1_sem = pop.psd.eyesfree_sem;
psd2 = pop.psd.eyesfixed_mu; psd2_sem = pop.psd.eyesfixed_sem;

figure; subplot(1,2,1); hold on; %plot(f,psd1,'Color', 'k', 'LineWidth',2); plot(f,psd2,'Color', 'r','LineWidth',2);
shadedErrorBar(f,psd1, psd1_sem,'lineprops','c');
shadedErrorBar(f,psd2, psd2_sem,'lineprops','m');
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); % ylabel('Power spectral density (\muV^2/Hz)');
box off; set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); ylim([0.0035 1]);
subplot(1,2,2); hold on; plot(eyes_ratio', 'k'); plot(nanmean(eyes_ratio), 'LineWidth',2, 'Color','k');
axis([1 50 0 6]); hline(1,'k'); xlabel('Frequency (Hz)'); ylabel('Power spectral density ratio');
box off; set(gca,'TickDir', 'out', 'FontSize', 22); title('motion');

l_lim = 12 ; h_lim = 19; % beta band
psd1_band = psd1(f>l_lim & f<h_lim); psd2_band = psd2(f>l_lim & f<h_lim);
errorbar(3,nanmean(psd1_band),std(psd1_band),'oc','MarkerFaceColor', 'c','LineWidth',1,'CapSize',0);
errorbar(4,nanmean(psd2_band),std(psd2_band),'om','MarkerFaceColor', 'm','LineWidth',1,'CapSize',0);
set(gca,'xlim', [0 5], 'TickDir', 'out', 'FontSize',22, 'xTick', []);

% per monkey
f1 = monk(1).freq_eye;
psd1_free = monk(1).psd.eyesfree; psd2_free = monk(2).psd.eyesfree; psd3_free = monk(3).psd.eyesfree; psd1_fixed = monk(1).psd.eyesfixed; psd2_fixed = monk(2).psd.eyesfixed; psd3_fixed = monk(3).psd.eyesfixed;

figure; hold on;
plot(f1,psd1_free, 'Color', 'c', 'Linewidth',2); plot(f1,psd1_fixed, 'Color', 'm', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); %ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off; title('S');

figure; hold on;
plot(f1,psd2_free, 'Color', 'c', 'Linewidth',2); plot(f1,psd2_fixed, 'Color', 'm', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); % ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off; title('B');

figure; hold on;
plot(f1,psd3_free, 'Color', 'c', 'Linewidth',2); plot(f1,psd3_fixed, 'Color', 'm', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); % ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off; title('Q');

%% Accuracy (all monks)

f = pop.freq;
psd1 = pop.psd.err_mu; psd1_sem = pop.psd.err_sem;
psd2 = pop.psd.corr_mu; psd2_sem = pop.psd.corr_sem;


figure; subplot(1,2,1); hold on; %plot(f,psd1,'Color', 'k', 'LineWidth',2); plot(f,psd2,'Color', 'r','LineWidth',2);
shadedErrorBar(f,psd1, psd1_sem,'lineprops','m');
shadedErrorBar(f,psd2, psd2_sem,'lineprops','b');
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); % ylabel('Power spectral density (\muV^2/Hz)');
box off; set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log');
subplot(1,2,2); hold on; plot(acc_ratio', 'k'); plot(nanmean(acc_ratio), 'LineWidth',2, 'Color','k');
axis([1 50 0 6]); hline(1,'k'); xlabel('Frequency (Hz)'); ylabel('Power spectral density ratio');
box off; set(gca,'TickDir', 'out', 'FontSize', 22); title('motion');

% per monkey
f1 = monk(1).freq;
psd1_err = monk(1).psd.err; psd2_err = monk(2).psd.err; psd3_err = monk(3).psd.err; psd1_corr = monk(1).psd.corr; psd2_corr = monk(2).psd.corr; psd3_corr = monk(3).psd.corr;

figure; hold on;
plot(f1,psd1_err, 'Color', 'm', 'Linewidth',2); plot(f1,psd1_corr, 'Color', 'b', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); %ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off; title('S');

figure; hold on;
plot(f1,psd2_err, 'Color', 'm', 'Linewidth',2); plot(f1,psd2_corr, 'Color', 'b', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)');% ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off; title('B');

figure; hold on;
plot(f1,psd3_err, 'Color', 'm', 'Linewidth',2); plot(f1,psd3_corr, 'Color', 'b', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); % ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off; title('Q');


%% Densities (all monks)

f = pop.freq;
psd1 = pop.psd.den1_mu; psd1_sem = pop.psd.den1_sem;
psd2 = pop.psd.den2_mu; psd2_sem = pop.psd.den2_sem;


figure; subplot(1,2,1); hold on; %plot(f,psd1,'Color', 'k', 'LineWidth',2); plot(f,psd2,'Color', 'r','LineWidth',2);
shadedErrorBar(f,psd1, psd1_sem,'lineprops','m');
shadedErrorBar(f,psd2, psd2_sem,'lineprops','b');
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); %ylabel('Power spectral density (\muV^2/Hz)');
box off; set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log');
subplot(1,2,2); hold on; plot(den_ratio', 'k'); plot(nanmean(den_ratio), 'LineWidth',2, 'Color','k');
axis([1 50 0 6]); hline(1,'k'); xlabel('Frequency (Hz)'); ylabel('Power spectral density ratio');
box off; set(gca,'TickDir', 'out', 'FontSize', 22); title('motion');

% per monkey
f1 = monk(1).freq;
psd1_den1 = monk(1).psd.den1; psd2_den1 = monk(2).psd.den1; psd3_den1 = monk(3).psd.den1; psd1_den2 = monk(1).psd.den2; psd2_den2 = monk(2).psd.den2; psd3_den2 = monk(3).psd.den2;

figure; hold on;
plot(f1,psd1_den1, 'Color', 'm', 'Linewidth',2); plot(f1,psd1_den2, 'Color', 'b', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); %ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off; title('S');

figure; hold on;
plot(f1,psd2_den1, 'Color', 'm', 'Linewidth',2); plot(f1,psd2_den2, 'Color', 'b', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); %ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off; title('B');

figure; hold on;
plot(f1,psd3_den1, 'Color', 'm', 'Linewidth',2); plot(f1,psd3_den2, 'Color', 'b', 'Linewidth',2);
xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (dB)'); %ylabel('Power spectral density (\muV^2/Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22,'YScale', 'log'); box off; title('Q');


%% Fixed ground (all monks)


%% Passive vs Active (all monks)


%%
%% Speed dependent LFP activity
% freq speed v and w
v = exp(1).session(1).lfps(1).stats.trialtype.all.continuous.v.thetafreq.tuning.stim.mu;
w = exp(1).session(1).lfps(1).stats.trialtype.all.continuous.w.thetafreq.tuning.stim.mu;
cnt1=1; cnt2=1; cnt3=1;
for i = 1:length(exp)
    for sess = 1:length(exp(i).session)
        clear psd
        if ~isempty(exp(i).session(sess).lfps(1).stats) & exp(i).monk_id == 53;  %Schro
            for ch = 1:length(exp(i).session(1).lfps)
                monk(1).sess(cnt1).theta_v(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.v.thetafreq.tuning.rate.mu;
                monk(1).sess(cnt1).theta_w(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.w.thetafreq.tuning.rate.mu;
                monk(1).sess(cnt1).beta_v(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.v.betafreq.tuning.rate.mu;
                monk(1).sess(cnt1).beta_w(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.w.betafreq.tuning.rate.mu;
            end
            cnt1=cnt1+1;
        elseif ~isempty(exp(i).session(sess).lfps(1).stats) & exp(i).monk_id == 51; % Bruno
            for ch = 1:length(exp(i).session(1).lfps)
                monk(2).sess(cnt2).theta_v(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.v.thetafreq.tuning.rate.mu;
                monk(2).sess(cnt2).theta_w(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.w.thetafreq.tuning.rate.mu;
                monk(2).sess(cnt2).beta_v(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.v.betafreq.tuning.rate.mu;
                monk(2).sess(cnt2).beta_w(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.w.betafreq.tuning.rate.mu;
            end
            cnt2=cnt2+1;
        elseif  ~isempty(exp(i).session(sess).lfps(1).stats) & exp(i).monk_id == 44; % Quigley
            for ch = 1:length(exp(i).session(1).lfps)  % Quigley
                monk(3).sess(cnt3).theta_v(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.v.thetafreq.tuning.rate.mu;
                monk(3).sess(cnt3).theta_w(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.w.thetafreq.tuning.rate.mu;
                monk(3).sess(cnt3).beta_v(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.v.betafreq.tuning.rate.mu;
                monk(3).sess(cnt3).beta_w(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.continuous.w.betafreq.tuning.rate.mu;
            end
            cnt3=cnt3+1;
        end
    end
end

% plot
% figure; hold on;
% subplot(1,2,1); hold on; plot(w,monk(2).sess(1).beta_w,'.k'); plot(w, nannanmean(monk(2).sess(1).beta_w),'ob','MarkerFaceColor','b');
% plot(w,monk(2).sess(2).beta_w,'.k'); plot(w,monk(2).sess(3).beta_w,'.k'); plot(w,monk(2).sess(4).beta_w,'.k');
% xlabel('Angular velocity (deg/s)'); ylabel('\beta - frequency (Hz)');


% Avg across channels
for i = 1:length(monk)
    for j = 1:length(monk(i).sess)
        monk(i).sess(j).theta_v_mu = nanmean(monk(i).sess(j).theta_v);
        monk(i).sess(j).theta_w_mu = nanmean(monk(i).sess(j).theta_w);
        monk(i).sess(j).beta_v_mu = nanmean(monk(i).sess(j).beta_v);
        monk(i).sess(j).beta_w_mu = nanmean(monk(i).sess(j).beta_w);
    end
end

% Avg across datasets
for i = 1:length(monk)
    clear th_v th_w bet_v bet_w
    for j = 1:length(monk(i).sess)
        th_v(j,:) = monk(i).sess(j).theta_v_mu;
        th_w(j,:) = monk(i).sess(j).theta_w_mu;
        bet_v(j,:) = monk(i).sess(j).beta_v_mu;
        bet_w(j,:) = monk(i).sess(j).beta_w_mu;
    end
    %
    monk(i).speed.theta_v = nanmean(th_v);
    monk(i).speed.theta_w = nanmean(th_w);
    monk(i).speed.beta_v = nanmean(bet_v);
    monk(i).speed.beta_w = nanmean(bet_w);
end


% Avg across monkeys
for i = 1:length(monk)
    t_v(i,:) = monk(i).speed.theta_v;
    t_w(i,:) = monk(i).speed.theta_w;
    bet_v(i,:) = monk(i).speed.beta_v;
    bet_w(i,:) = monk(i).speed.beta_v;
end

pop.speed.theta_v = nanmean(t_v);
pop.speed.theta_w = nanmean(t_w);
pop.speed.beta_v = nanmean(bet_v);
pop.speed.beta_w = nanmean(bet_w);

% plot
% theta monk separate
figure; hold on;
for i = 1:length(monk)
    subplot(1,2,1); hold on; plot(w,monk(i).speed.theta_w,'.','color',[1 2 3]==i);
end
xlabel('Angular velocity (deg/s)'); ylabel('\theta - frequency (Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22);
for i = 1:length(monk)
    subplot(1,2,2); hold on; plot(v,monk(i).speed.theta_v,'.','color',[1 2 3]==i);
end
xlabel('Linear velocit(cm/s)'); ylabel('\theta - frequency (Hz)');
set(gca, 'xlim', [0 200], 'TickDir', 'out', 'FontSize', 22);
% nanmean theta monkeys together
figure; hold on;
subplot(1,2,1); hold on; plot(w, pop.speed.theta_w,'.','color',[1 2 3]==i);
xlabel('Angular velocity (deg/s)'); ylabel('\theta - frequency (Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22);
subplot(1,2,2); hold on; plot(v,pop.speed.theta_v,'.','color',[1 2 3]==i);
xlabel('Linear velocity (cm/s)'); ylabel('\theta - frequency (Hz)');
set(gca, 'xlim', [0 200], 'TickDir', 'out', 'FontSize', 22);

% beta
figure; hold on;
for i = 1:length(monk)
    subplot(1,2,1); hold on; plot(w,monk(i).speed.beta_w,'.','color',[1 2 3]==i);
    set(gca,'TickDir', 'out', 'FontSize', 22);
end
xlabel('Angular velocity (deg/s)'); ylabel('\beta - frequency (Hz)');
for i = 1:length(monk)
    subplot(1,2,2); hold on; plot(v,monk(i).speed.beta_v,'.','color',[1 2 3]==i);
end
xlabel('Linear velocity (cm/s)'); ylabel('\beta - frequency (Hz)');
set(gca, 'xlim', [0 200], 'TickDir', 'out', 'FontSize', 22);

% nanmean beta monkeys together
figure; hold on;
subplot(1,2,1); hold on; plot(w, pop.speed.beta_w,'.b');
xlabel('Angular velocity (deg/s)'); ylabel('\beta - frequency (Hz)');
set(gca,'TickDir', 'out', 'FontSize', 22);
subplot(1,2,2); hold on; plot(v,pop.speed.beta_v,'.b');
xlabel('Linear velocity (cm/s)'); ylabel('\beta - frequency (Hz)');
set(gca, 'xlim', [0 200], 'TickDir', 'out', 'FontSize', 22);

%% MLR
% plot all monks theta
figure; hold on; str = {'v' 'w' 'h eye' 'v eye'};
errorbar(1, pop.psd.regr_coeff_theta_mu(1),pop.psd.regr_coeff_theta_sem(1), 'MarkerSize',10,'Marker','.');
errorbar(2, pop.psd.regr_coeff_theta_mu(2),pop.psd.regr_coeff_theta_sem(2), 'MarkerSize',10,'Marker','.');
errorbar(3, pop.psd.regr_coeff_theta_mu(3),pop.psd.regr_coeff_theta_sem(3), 'MarkerSize',10,'Marker','.');
errorbar(4, pop.psd.regr_coeff_theta_mu(4),pop.psd.regr_coeff_theta_sem(4), 'MarkerSize',10,'Marker','.');
set(gca, 'xlim', [0.5 4.5],'xTickLabel',str,'TickDir', 'out', 'FontSize',22); hline(0,'--k');
ylabel('regression coefficient'); title('theta');

% plot all monks beta
figure; hold on;
errorbar(1, pop.psd.regr_coeff_beta_mu(1),pop.psd.regr_coeff_beta_sem(1), 'MarkerSize',10,'Marker','.');
errorbar(2, pop.psd.regr_coeff_beta_mu(2),pop.psd.regr_coeff_beta_sem(2), 'MarkerSize',10,'Marker','.');
errorbar(3, pop.psd.regr_coeff_beta_mu(3),pop.psd.regr_coeff_beta_sem(3), 'MarkerSize',10,'Marker','.');
errorbar(4, pop.psd.regr_coeff_beta_mu(4),pop.psd.regr_coeff_beta_sem(4), 'MarkerSize',10,'Marker','.');
set(gca, 'xlim', [0.5 4.5],'xTickLabel',str,'TickDir', 'out', 'FontSize',22); hline(0,'--k');
ylabel('regression coefficient'); title('beta')


%% Event-related potentials
%% move and eye move
cnt1 = 1; cnt2 = 1; cnt3= 1;
for i = 1:length(exp)
    for sess = 1:length(exp(i).session)
        if ~isempty(exp(i).session(sess).lfps(1).stats) & exp(i).monk_id == 53  %Schro
            clear raw_mu raw_sem raw_fix_mu raw_sacc_mu theta_mu theta_sem theta_fix theta_fix_t theta_sacc theta_sacc_t beta_mu beta_sem beta_fix beta_fix_t beta_sacc beta_sacc_t
            for ch = 1:length(exp(i).session(1).lfps)
                raw_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.raw.potential_mu;
                raw_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.raw.potential_mu;
                raw_fix_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.raw.potential_mu;
                raw_sacc_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.raw.potential_mu;
                %
                theta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.theta.potential_mu;
                theta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.theta.potential_sem;
                theta_fix(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.potential_mu;
                theta_fix_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.time;
                theta_sacc(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.potential_mu;
                theta_sacc_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.time;
                %
                beta_mu(ch,:) = real(exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.beta.potential_mu);
                beta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.beta.potential_sem;
                beta_fix(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.potential_mu;
                beta_fix_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.time;
                beta_sacc(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.potential_mu;
            end
            monk(1).events(cnt1,:).move.t_raw = exp(i).session(sess).lfps(1).stats.trialtype.all.events.move.raw.time;
            monk(1).events(cnt1,:).move.raw_mu = nanmean(raw_mu);
            monk(1).events(cnt1,:).move.raw_sem = std(raw_mu)/sqrt(length(raw_mu));
            monk(1).events(cnt1,:).move.raw_t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.raw.time;
            monk(1).events(cnt1,:).move.theta.mu = nanmean(real(theta_mu));
            monk(1).events(cnt1,:).move.theta.sem = std(real(theta_mu))/sqrt(length(real(theta_mu)));
            monk(1).events(cnt1,:).move.theta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.theta.time;
            monk(1).events(cnt1,:).move.beta.mu = nanmean(real(beta_mu));
            monk(1).events(cnt1,:).move.beta.sem = std(real(beta_mu))/sqrt(length(real(beta_mu)));
            monk(1).events(cnt1,:).move.beta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.beta.time;
            % eye
            monk(1).events(cnt1,:).fix.raw_mu = nanmean(raw_fix_mu);
            monk(1).events(cnt1,:).fix.t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.raw.time;
            monk(1).events(cnt1,:).fix.theta = nanmean(theta_fix);
            monk(1).events(cnt1,:).fix.theta_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.time;
            monk(1).events(cnt1,:).fix.beta = nanmean(beta_fix);
            monk(1).events(cnt1,:).fix.beta_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.time;
            monk(1).events(cnt1,:).sacc.raw_mu = nanmean(raw_sacc_mu);
            monk(1).events(cnt1,:).sacc.t = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.raw.time;
            monk(1).events(cnt1,:).sacc.theta = nanmean(theta_sacc);
            monk(1).events(cnt1,:).sacc.theta_t = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.theta.time;
            monk(1).events(cnt1,:).sacc.beta = nanmean(beta_sacc);
            monk(1).events(cnt1,:).sacc.beta_t = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.beta.time;
            cnt1=cnt1+1;
            
            % plot single sessions 96 ch -- move
            %                         figure; hold on; plot(monk(1).t_raw, raw_mu);
            %                         set(gca,'TickDir', 'out', 'FontSize', 18); box off;
            %                         title('Schro')
            %                         figure; hold on
            %                         shadedErrorBar(monk(1).t_raw, nanmean(raw_mu), std(raw_mu))
            %                         set(gca,'TickDir', 'out', 'FontSize', 18); box off;
            %                         title('Schro')
            %                         keyboard;
            
        elseif ~isempty(exp(i).session(sess).lfps(1).stats.trialtype) & exp(i).monk_id == 51; % Bruno
            clear raw_mu raw_sem raw_fix_mu raw_sacc_mu theta_mu theta_sem theta_fix theta_fix_t theta_sacc theta_sacc_t beta_mu beta_sem beta_fix beta_fix_t beta_sacc beta_sacc_t
            for ch = 1:length(exp(i).session(1).lfps)
                raw_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.raw.potential_mu;
                raw_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.raw.potential_mu;
                raw_fix_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.raw.potential_mu;
                raw_sacc_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.raw.potential_mu;
                %
                theta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.theta.potential_mu;
                theta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.theta.potential_sem;
                theta_fix(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.potential_mu;
                theta_fix_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.time;
                theta_sacc(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.potential_mu;
                theta_sacc_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.time;
                %
                beta_mu(ch,:) = real(exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.beta.potential_mu);
                beta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.beta.potential_sem;
                beta_fix(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.potential_mu;
                beta_fix_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.time;
                beta_sacc(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.potential_mu;
                beta_sacc_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.time;
            end
            monk(2).events(cnt2,:).move.t_raw = exp(i).session(sess).lfps(1).stats.trialtype.all.events.move.raw.time;
            monk(2).events(cnt2,:).move.raw_mu = nanmean(raw_mu);
            monk(2).events(cnt2,:).move.raw_sem = std(raw_mu)/sqrt(length(raw_mu));
            monk(2).events(cnt2,:).move.raw_t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.raw.time;
            monk(2).events(cnt2,:).move.theta.mu = nanmean(real(theta_mu));
            monk(2).events(cnt2,:).move.theta.sem = std(real(theta_mu))/sqrt(length(real(theta_mu)));
            monk(2).events(cnt2,:).move.theta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.theta.time;
            monk(2).events(cnt2,:).move.beta.mu = nanmean(real(beta_mu));
            monk(2).events(cnt2,:).move.beta.sem = std(real(beta_mu))/sqrt(length(real(beta_mu)));;
            monk(2).events(cnt2,:).move.beta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.beta.time;
            % eye
            monk(2).events(cnt2,:).fix.raw_mu = nanmean(raw_fix_mu);
            monk(2).events(cnt2,:).fix.t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.raw.time;
            monk(2).events(cnt2,:).fix.theta = nanmean(theta_fix);
            monk(2).events(cnt2,:).fix.theta_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.time;
            monk(2).events(cnt2,:).fix.beta = nanmean(beta_fix);
            monk(2).events(cnt2,:).fix.beta_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.time;
            monk(2).events(cnt2,:).sacc.raw_mu = nanmean(raw_sacc_mu);
            monk(2).events(cnt2,:).sacc.t = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.raw.time;
            monk(2).events(cnt2,:).sacc.theta = nanmean(theta_sacc);
            monk(2).events(cnt2,:).sacc.theta_t = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.theta.time;
            monk(2).events(cnt2,:).sacc.beta = nanmean(beta_sacc);
            monk(2).events(cnt2,:).sacc.beta_t = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.beta.time;
            cnt2=cnt2+1;
            % plot 96 ch
            %             figure; hold on; plot(monk(2).t_raw, raw_mu);
            %             set(gca,'TickDir', 'out', 'FontSize', 18); box off;
            %             title('Bruno')
            %             figure; hold on
            %             shadedErrorBar(monk(2).t_raw, nanmean(raw_mu), std(raw_mu))
            %             set(gca,'TickDir', 'out', 'FontSize', 18); box off;
            %             title('Bruno')
            %             keyboard;
        elseif ~isempty(exp(i).session(sess).lfps(1).stats.trialtype) & exp(i).monk_id == 44; % Quigley
            clear raw_mu raw_sem raw_fix_mu raw_sacc_mu theta_mu theta_sem theta_fix theta_fix_t theta_sacc theta_sacc_t beta_mu beta_sem beta_fix beta_fix_t beta_sacc beta_sacc_t
            for ch = 1:length(exp(i).session(1).lfps)
                raw_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.raw.potential_mu;
                raw_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.raw.potential_mu;
                raw_fix_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.raw.potential_mu;
                raw_sacc_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.raw.potential_mu;
                %
                theta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.theta.potential_mu;
                theta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.theta.potential_sem;
                theta_fix(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.potential_mu;
                theta_fix_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.time;
                theta_sacc(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.potential_mu;
                theta_sacc_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.time;
                %
                beta_mu(ch,:) = real(exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.beta.potential_mu);
                beta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.beta.potential_sem;
                beta_fix(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.potential_mu;
                beta_fix_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.time;
                beta_sacc(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.potential_mu;
            end
            monk(3).events(cnt3,:).move.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.raw.time;
            monk(3).events(cnt3,:).move.raw_mu = nanmean(raw_mu);
            monk(3).events(cnt3,:).move.raw_sem = std(raw_mu)/sqrt(length(raw_mu));
            monk(3).events(cnt3,:).move.raw_t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.raw.time;
            monk(3).events(cnt3,:).move.theta.mu = nanmean(real(theta_mu));
            monk(3).events(cnt3,:).move.theta.sem = std(real(theta_mu))/sqrt(length(real(theta_mu)));
            monk(3).events(cnt3,:).move.theta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.theta.time;
            monk(3).events(cnt3,:).move.beta.mu = nanmean(real(beta_mu));
            monk(3).events(cnt3,:).move.beta.sem = std(real(beta_mu))/sqrt(length(real(beta_mu)));;
            monk(3).events(cnt3,:).move.beta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.move.beta.time;
            % eye
            monk(3).events(cnt3,:).fix.raw_mu = nanmean(raw_fix_mu);
            monk(3).events(cnt3,:).fix.t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.raw.time;
            monk(3).events(cnt3,:).fix.theta = nanmean(theta_fix);
            monk(3).events(cnt3,:).fix.theta_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.theta.time;
            monk(3).events(cnt3,:).fix.beta = nanmean(beta_fix);
            monk(3).events(cnt3,:).fix.beta_t = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.beta.time;
            monk(3).events(cnt3,:).sacc.raw_mu = nanmean(raw_sacc_mu);
            monk(3).events(cnt3,:).sacc.t = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.raw.time;
            monk(3).events(cnt3,:).sacc.theta = nanmean(theta_sacc);
            monk(3).events(cnt3,:).sacc.theta_t = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.theta.time;
            monk(3).events(cnt3,:).sacc.beta = nanmean(beta_sacc);
            monk(3).events(cnt3,:).sacc.beta_t = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.beta.time;
            cnt3=cnt3+1;
            % plot
            %             figure; hold on; plot(monk(3).t_raw, raw_mu);
            %             set(gca,'TickDir', 'out', 'FontSize', 18); box off;
            %             title('Quigley')
            %             figure; hold on
            %             shadedErrorBar(monk(3).t_raw, nanmean(raw_mu), std(raw_mu))
            %             set(gca,'TickDir', 'out', 'FontSize', 18); box off;
            %             title('Quigley')
            %             keyboard;
            
        end
    end
end

% average across datasets
for i = 1:length(monk)
    clear raw_ev theta_ev beta_ev raw_fix raw_sacc theta_fix theta_sacc beta_fix beta_sacc
    for ev = 1:length(monk(i).events)
        raw_ev(ev,:) = monk(i).events(ev).move.raw_mu;
        theta_ev(ev,:) = monk(i).events(ev).move.theta.mu;
        beta_ev(ev,:) = monk(i).events(ev).move.beta.mu;
        
        raw_fix(ev,:) = monk(i).events(ev).fix.raw_mu;
        raw_sacc(ev,:) = monk(i).events(ev).sacc.raw_mu;
        theta_fix(ev,:) = monk(i).events(ev).fix.theta;
        theta_sacc(ev,:) = monk(i).events(ev).sacc.theta;
        beta_fix(ev,:) = monk(i).events(ev).fix.beta;
        beta_sacc(ev,:) = monk(i).events(ev).sacc.beta;
    end
    t_raw = monk(1).events(1).move.raw_t;
    % get change in amp between time of interest -0.5 to 0.5 per monkey per session
    for ev = 1:length(monk(i).events)
        % move
        monk(i).diff_amp_move(ev) = abs(max(raw_ev(ev, t_raw>-0.5 & t_raw < 0.5)) - min(raw_ev(ev,t_raw>-0.5 & t_raw < 0.5)));
        [monk(i).max_move(ev),monk(i).indx_max_move(ev)] = max(abs(raw_ev(ev, t_raw>-0.5 & t_raw < 0.5)));
        monk(i).diff_amp_move_t(ev) = monk(1).events(1).move.raw_t(monk(i).indx_max_move(ev));
        
        %sacc
        monk(i).diff_amp_sacc(ev) = abs(max(raw_sacc(ev, t_raw>-0.5 & t_raw < 0.5)) - min(raw_sacc(ev,t_raw>-0.5 & t_raw < 0.5)));
        [monk(i).max_sacc(ev),monk(i).indx_max_sacc(ev)] = max(abs(raw_sacc(ev, t_raw>-0.5 & t_raw < 0.5)));
        monk(i).diff_amp_sacc_t(ev) = monk(1).events(1).move.raw_t(monk(i).indx_max_sacc(ev));
        
        % fix
        monk(i).diff_amp_fix(ev) = abs(max(raw_fix(ev, t_raw>-0.5 & t_raw < 0.5)) - min(raw_fix(ev,t_raw>-0.5 & t_raw < 0.5)));
        [monk(i).max_fix(ev),monk(i).indx_max_fix(ev)] = max(abs(raw_fix(ev, t_raw>-0.5 & t_raw < 0.5)));
        monk(i).diff_amp_fix_t(ev) = monk(1).events(1).move.raw_t(monk(i).indx_max_fix(ev));
    end
    
    monk(i).erp.move_raw = nanmean(raw_ev);
    monk(i).erp.move_theta = nanmean(theta_ev);
    monk(i).erp.move_beta = nanmean(beta_ev);
    % eye
    monk(i).erp.fix_raw = nanmean(raw_fix);
    monk(i).erp.fix_theta = nanmean(theta_fix);
    monk(i).erp.fix_beta = nanmean(beta_fix);
    monk(i).erp.sacc_raw = nanmean(raw_sacc);
    monk(i).erp.sacc_theta = nanmean(theta_sacc);
    monk(i).erp.sacc_beta = nanmean(beta_sacc);
end

% average across monkeys
for i = 1:length(monk)
    move_raw(i,:) = monk(i).erp.move_raw;
    move_theta(i,:) = monk(i).erp.move_theta;
    move_beta(i,:) = monk(i).erp.move_beta;
    fix_raw(i,:) = monk(i).erp.fix_raw;
    fix_theta(i,:) = monk(i).erp.fix_theta;
    fix_beta(i,:) = monk(i).erp.fix_beta;
    sacc_raw(i,:) = monk(i).erp.sacc_raw;
    sacc_theta(i,:) = monk(i).erp.sacc_theta;
    sacc_beta(i,:) = monk(i).erp.sacc_beta;
end

pop.events.move_raw = nanmean(move_raw);
pop.events.move_theta = nanmean(move_theta);
pop.events.move_beta = nanmean(move_beta);

pop.events.fix_raw = nanmean(fix_raw);
pop.events.fix_theta = nanmean(fix_theta);
pop.events.fix_beta = nanmean(fix_beta);

pop.events.sacc_raw = nanmean(sacc_raw);
pop.events.sacc_theta = nanmean(sacc_theta);
pop.events.sacc_beta = nanmean(sacc_beta);

theta_t = exp(1).session(1).lfps(1).stats.trialtype.all.events.move.theta.time;
beta_t = exp(1).session(1).lfps(1).stats.trialtype.all.events.move.beta.time;

% plot
% raw
figure; hold on;
t_raw = monk(1).events(1).move.raw_t;
raw_pop = pop.events.move_raw;
plot(t_raw,raw_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('move')
% theta
figure; hold on;
theta_pop = pop.events.move_theta;
plot(theta_t,theta_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('move theta')
% beta
figure; hold on;
beta_pop = pop.events.move_beta;
plot(beta_t,beta_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('move beta')


% per monkey raw
for i= 1:length(monk)
    figure; hold on;
    plot(t_raw, monk(i).erp.move_raw, 'Color', [1 2 3]==i)
    set(gca,'xlim',[-0.5 1.5],'TickDir', 'out', 'FontSize', 18); box off;
    title('move')
end


%per monkey theta
figure; hold on;
for i= 1:length(monk)
    plot(theta_t, monk(i).erp.move_theta, 'Color', [1 2 3]==i)
    set(gca,'xlim',[-0.5 0.5],'TickDir', 'out', 'FontSize', 18); box off;
    title('theta move')
end
%per monkey beta
figure; hold on;
for i= 1:length(monk)
    plot(beta_t, monk(i).erp.move_beta, 'Color', [1 2 3]==i)
    set(gca,'xlim',[-0.5 0.5],'TickDir', 'out', 'FontSize', 18); box off;
    title('theta move')
end



% plot eye fix
figure; hold on;
t_raw_fix = monk(1).events(1).fix.t;
raw_pop = pop.events.fix_raw;
plot(t_raw_fix,raw_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 1], 'TickDir', 'out', 'FontSize', 18); box off;
title('fix')

% per monkey raw fix
for i= 1:length(monk)
    figure; hold on;
    plot(t_raw_fix, monk(i).erp.fix_raw, 'Color', [1 2 3]==i)
    set(gca,'xlim',[-0.5 1.5],'TickDir', 'out', 'FontSize', 18); box off;
    title('fix')
end

% theta
figure; hold on;
theta_t = monk(1).events(1).fix.theta_t;
theta_pop = pop.events.fix_theta;
plot(theta_t,theta_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('fix theta')
% beta
figure; hold on;
beta_t = monk(1).events(1).fix.beta_t;
beta_pop = pop.events.fix_beta;
plot(beta_t,beta_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('fix beta')

% plot eye sacc
figure; hold on;
t_raw_sacc = monk(1).events(1).sacc.t;
raw_pop = pop.events.sacc_raw;
plot(t_raw_sacc,raw_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 1], 'TickDir', 'out', 'FontSize', 18); box off;
title('sacc')

% per monkey raw sacc

for i= 1:length(monk)
    figure; hold on;
    plot(t_raw_sacc, monk(i).erp.sacc_raw, 'Color', [1 2 3]==i)
    set(gca,'xlim',[-0.5 1.5],'TickDir', 'out', 'FontSize', 18); box off;
    title('sacc')
end


% theta
figure; hold on;
theta_t = monk(1).events(1).sacc.theta_t;
theta_pop = pop.events.sacc_theta;
plot(theta_t,theta_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('sacc theta')
% beta
figure; hold on;
beta_t = monk(1).events(1).sacc.beta_t;
beta_pop = pop.events.sacc_beta;
plot(beta_t,beta_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('sacc beta')


%% target
cnt1 = 1; cnt2 = 1; cnt3= 1; clear raw_mu raw_sem theta_mu theta_sem theta_t beta_mu beta_sem beta_t
for i = 1:length(exp)
    for sess = 1:length(exp(i).session)
        if ~isempty(exp(i).session(sess).lfps(1).stats) & exp(i).monk_id == 53;  %Schro
            clear raw_mu raw_sem raw_fix_mu raw_sacc_mu theta_mu theta_sem theta_fix theta_fix_t theta_sacc theta_sacc_t beta_mu beta_sem
            for ch = 1:length(exp(i).session(1).lfps)
                raw_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.raw.potential_mu;
                raw_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.raw.potential_mu;
                %
                theta_mu(ch,:) = real(exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.theta.potential_mu);
                theta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.theta.potential_sem;
                theta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.theta.time;
                %
                beta_mu(ch,:) = real(exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.beta.potential_mu);
                beta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.beta.potential_sem;
                beta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.beta.time;
            end
            monk(1).events(cnt1,:).target.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.raw.time;
            monk(1).events(cnt1,:).target.raw_mu = nanmean(raw_mu);
            monk(1).events(cnt1,:).target.raw_sem = std(raw_mu)/sqrt(length(raw_mu));
            monk(1).events(cnt1,:).target.raw_t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.raw.time;
            monk(1).events(cnt1,:).target.theta.mu = nanmean(real(theta_mu));
            monk(1).events(cnt1,:).target.theta.sem = std(theta_mu)/sqrt(length(theta_mu));
            monk(1).events(cnt1,:).target.theta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.theta.time;
            monk(1).events(cnt1,:).target.beta.mu = nanmean(real(beta_mu));
            monk(1).events(cnt1,:).target.beta.sem = std(beta_mu)/sqrt(length(beta_mu));
            monk(1).events(cnt1,:).target.beta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.beta.time;
            cnt1=cnt1+1;
        elseif ~isempty(exp(i).session(sess).lfps(1).stats.trialtype) & exp(i).monk_id == 51; % Bruno
            clear raw_mu raw_sem raw_fix_mu raw_sacc_mu theta_mu theta_sem theta_fix theta_fix_t theta_sacc theta_sacc_t beta_mu beta_sem
            for ch = 1:length(exp(i).session(1).lfps)
                raw_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.raw.potential_mu;
                raw_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.raw.potential_mu;
                %
                theta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.theta.potential_mu;
                theta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.theta.potential_sem;
                theta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.theta.time;
                %
                beta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.beta.potential_mu;
                beta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.beta.potential_sem;
                beta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.beta.time;
            end
            monk(2).events(cnt2,:).target.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.raw.time;
            monk(2).events(cnt2,:).target.raw_mu = nanmean(raw_mu);
            monk(2).events(cnt2,:).target.raw_sem = std(raw_mu)/sqrt(length(raw_mu));
            monk(2).events(cnt2,:).target.raw_t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.raw.time;
            monk(2).events(cnt2,:).target.theta.mu = nanmean(real(theta_mu));
            monk(2).events(cnt2,:).target.theta.sem = std(theta_mu)/sqrt(length(theta_mu));
            monk(2).events(cnt2,:).target.theta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.theta.time;
            monk(2).events(cnt2,:).target.beta.mu = nanmean(real(beta_mu));
            monk(2).events(cnt2,:).target.beta.sem = std(beta_mu)/sqrt(length(beta_mu));
            monk(2).events(cnt2,:).target.beta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.beta.time;
            cnt2=cnt2+1;
        elseif ~isempty(exp(i).session(sess).lfps(1).stats.trialtype) & exp(i).monk_id == 44; % Quigley
            clear raw_mu raw_sem raw_fix_mu raw_sacc_mu theta_mu theta_sem theta_fix theta_fix_t theta_sacc theta_sacc_t beta_mu beta_sem
            for ch = 1:length(exp(i).session(1).lfps)
                raw_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.raw.potential_mu;
                raw_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.raw.potential_mu;
                %
                theta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.theta.potential_mu;
                theta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.theta.potential_sem;
                theta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.theta.time;
                %
                beta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.beta.potential_mu;
                beta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.beta.potential_sem;
                beta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.beta.time;
            end
            monk(3).events(cnt3,:).target.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.raw.time;
            monk(3).events(cnt3,:).target.raw_mu = nanmean(raw_mu);
            monk(3).events(cnt3,:).target.raw_sem = std(raw_mu)/sqrt(length(raw_mu));
            monk(3).events(cnt3,:).target.raw_t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.raw.time;
            monk(3).events(cnt3,:).target.theta.mu = nanmean(real(theta_mu));
            monk(3).events(cnt3,:).target.theta.sem = std(theta_mu)/sqrt(length(theta_mu));
            monk(3).events(cnt3,:).target.theta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.theta.time;
            monk(3).events(cnt3,:).target.beta.mu = nanmean(real(beta_mu));
            monk(3).events(cnt3,:).target.beta.sem = std(beta_mu)/sqrt(length(beta_mu));
            monk(3).events(cnt3,:).target.beta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.target.beta.time;
            cnt3=cnt3+1;
        end
    end
end

% average across datasets
for i = 1:length(monk)
    clear raw_ev theta_ev beta_ev
    for ev = 1:length(monk(i).events)
        raw_ev(ev,:) = monk(i).events(ev).target.raw_mu;
        theta_ev(ev,:) = monk(i).events(ev).target.theta.mu;
        beta_ev(ev,:) = monk(i).events(ev).target.beta.mu;
    end
    monk(i).erp.target_raw = nanmean(raw_ev);
    monk(i).erp.target_theta = nanmean(theta_ev);
    monk(i).erp.target_beta = nanmean(beta_ev);
    
    % get erp diff
    for ev = 1:length(monk(i).events)
        monk(i).diff_amp_targ(ev) = abs(max(raw_ev(ev, t_raw>-0.5 & t_raw < 0.5)) - min(raw_ev(ev,t_raw>-0.5 & t_raw < 0.5)));
        [monk(i).max_targ(ev),monk(i).indx_max_targ(ev)] = max(abs(raw_ev(ev, t_raw>-0.5 & t_raw < 0.5)));
        monk(i).diff_amp_targ_t(ev) = monk(1).events(1).move.raw_t(monk(i).indx_max_targ(ev));
    end
end

% average across monkeys
for i = 1:length(monk)
    target_raw(i,:) = monk(i).erp.target_raw;
    target_theta(i,:) = monk(i).erp.target_theta;
    target_beta(i,:) = monk(i).erp.target_beta;
end

pop.events.target_raw = nanmean(target_raw);
pop.events.target_theta = nanmean(target_theta);
pop.events.target_beta = nanmean(target_beta);


% plot
% raw
figure; hold on;
t_raw = monk(1).events(1).target.raw_t;
raw_pop = pop.events.target_raw;
plot(t_raw,raw_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('target'); vline(-0.3, '-k');
% theta
figure; hold on;
theta_pop = pop.events.target_theta;
plot(theta_t,theta_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('target theta'); vline(-0.3, '-k');
% beta
figure; hold on;
beta_pop = pop.events.target_beta;
plot(beta_t,beta_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('target beta'); vline(-0.3, '-k');

% per monkey raw

for i= 1:length(monk)
    figure; hold on;
    plot(t_raw, monk(i).erp.target_raw, 'Color', [1 2 3]==i)
    set(gca,'xlim',[-0.5 1.5],'TickDir', 'out', 'FontSize', 18); box off;
    title('target'); vline(-0.3, '-k');
end


%% stop
cnt1 = 1; cnt2 = 1; cnt3= 1;
for i = 1:length(exp)
    for sess = 1:length(exp(i).session)
        if ~isempty(exp(i).session(sess).lfps(1).stats) & exp(i).monk_id == 53  %Schro
            clear raw_mu raw_sem raw_fix_mu raw_sacc_mu theta_mu theta_sem theta_fix theta_fix_t theta_sacc theta_sacc_t beta_mu beta_sem
            for ch = 1:length(exp(i).session(1).lfps)
                raw_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.raw.potential_mu;
                raw_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.raw.potential_mu;
                %
                theta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.theta.potential_mu;
                theta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.theta.potential_sem;
                theta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.theta.time;
                %
                beta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.beta.potential_mu;
                beta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.beta.potential_sem;
                beta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.beta.time;
            end
            monk(1).events(cnt1,:).stop.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.raw.time;
            monk(1).events(cnt1,:).stop.raw_mu = nanmean(raw_mu);
            monk(1).events(cnt1,:).stop.raw_sem = std(raw_mu)/sqrt(length(raw_mu));
            monk(1).events(cnt1,:).stop.raw_t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.raw.time;
            monk(1).events(cnt1,:).stop.theta.mu = nanmean(real(theta_mu));
            monk(1).events(cnt1,:).stop.theta.sem = std(theta_mu)/sqrt(length(theta_mu));
            monk(1).events(cnt1,:).stop.theta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.theta.time;
            monk(1).events(cnt1,:).stop.beta.mu = nanmean(real(beta_mu));
            monk(1).events(cnt1,:).stop.beta.sem = std(beta_mu)/sqrt(length(beta_mu));
            monk(1).events(cnt1,:).stop.beta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.beta.time;
            cnt1=cnt1+1;
        elseif ~isempty(exp(i).session(sess).lfps(1).stats.trialtype) & exp(i).monk_id == 51 % Bruno
            clear raw_mu raw_sem raw_fix_mu raw_sacc_mu theta_mu theta_sem theta_fix theta_fix_t theta_sacc theta_sacc_t beta_mu beta_sem
            for ch = 1:length(exp(i).session(1).lfps)
                raw_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.raw.potential_mu;
                raw_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.raw.potential_mu;
                %
                theta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.theta.potential_mu;
                theta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.theta.potential_sem;
                theta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.theta.time;
                %
                beta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.beta.potential_mu;
                beta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.beta.potential_sem;
                beta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.beta.time;
            end
            monk(2).events(cnt2,:).stop.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.raw.time;
            monk(2).events(cnt2,:).stop.raw_mu = nanmean(raw_mu);
            monk(2).events(cnt2,:).stop.raw_sem = std(raw_mu)/sqrt(length(raw_mu));
            monk(2).events(cnt2,:).stop.raw_t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.raw.time;
            monk(2).events(cnt2,:).stop.theta.mu = nanmean(real(theta_mu));
            monk(2).events(cnt2,:).stop.theta.sem = std(theta_mu)/sqrt(length(theta_mu));
            monk(2).events(cnt2,:).stop.theta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.theta.time;
            monk(2).events(cnt2,:).stop.beta.mu = nanmean(real(beta_mu));
            monk(2).events(cnt2,:).stop.beta.sem = std(beta_mu)/sqrt(length(beta_mu));
            monk(2).events(cnt2,:).stop.beta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.beta.time;
            cnt2=cnt2+1;
        else ~isempty(exp(i).session(sess).lfps(1).stats.trialtype) & exp(i).monk_id == 44 % Quigley
            clear raw_mu raw_sem raw_fix_mu raw_sacc_mu theta_mu theta_sem theta_fix theta_fix_t theta_sacc theta_sacc_t beta_mu beta_sem
            for ch = 1:length(exp(i).session(1).lfps)
                raw_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.raw.potential_mu;
                raw_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.raw.potential_mu;
                %
                theta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.theta.potential_mu;
                theta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.theta.potential_sem;
                theta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.theta.time;
                %
                beta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.beta.potential_mu;
                beta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.beta.potential_sem;
                beta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.beta.time;
            end
            monk(3).events(cnt3,:).stop.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.raw.time;
            monk(3).events(cnt3,:).stop.raw_mu = nanmean(raw_mu);
            monk(3).events(cnt3,:).stop.raw_sem = std(raw_mu)/sqrt(length(raw_mu));
            monk(3).events(cnt3,:).stop.raw_t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.raw.time;
            monk(3).events(cnt3,:).stop.theta.mu = nanmean(real(theta_mu));
            monk(3).events(cnt3,:).stop.theta.sem = std(theta_mu)/sqrt(length(theta_mu));
            monk(3).events(cnt3,:).stop.theta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.theta.time;
            monk(3).events(cnt3,:).stop.beta.mu = nanmean(real(beta_mu));
            monk(3).events(cnt3,:).stop.beta.sem = std(beta_mu)/sqrt(length(beta_mu));
            monk(3).events(cnt3,:).stop.beta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.stop.beta.time;
            cnt3=cnt3+1;
        end
    end
end

% average across datasets
for i = 1:length(monk)
    clear raw_ev theta_ev beta_ev
    for ev = 1:length(monk(i).events)
        raw_ev(ev,:) = monk(i).events(ev).stop.raw_mu;
        theta_ev(ev,:) = monk(i).events(ev).stop.theta.mu;
        beta_ev(ev,:) = monk(i).events(ev).stop.beta.mu;
    end
    monk(i).erp.stop_raw = nanmean(raw_ev);
    monk(i).erp.stop_theta = nanmean(theta_ev);
    monk(i).erp.stop_beta = nanmean(beta_ev);
    
    % get erp diff
    for ev = 1:length(monk(i).events)
        monk(i).diff_amp_stop(ev) = abs(max(raw_ev(ev, t_raw>-0.5 & t_raw < 0.5)) - min(raw_ev(ev,t_raw>-0.5 & t_raw < 0.5)));
        [monk(i).max_stop(ev),monk(i).indx_max_stop(ev)] = max(abs(raw_ev(ev, t_raw>-0.5 & t_raw < 0.5)));
        monk(i).diff_amp_stop_t(ev) = monk(1).events(1).move.raw_t(monk(i).indx_max_stop(ev));
    end
    
end

% average across monkeys
for i = 1:length(monk)
    stop_raw(i,:) = monk(i).erp.stop_raw;
    stop_theta(i,:) = monk(i).erp.stop_theta;
    stop_beta(i,:) = monk(i).erp.stop_beta;
end

pop.events.stop_raw = nanmean(stop_raw);
pop.events.stop_theta = nanmean(stop_theta);
pop.events.stop_beta = nanmean(stop_beta);

% plot
figure; hold on;
t_raw = monk(1).events(1).stop.raw_t;
raw_pop = pop.events.stop_raw;
plot(t_raw,raw_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('stop')
% theta
figure; hold on;
theta_pop = pop.events.stop_theta;
plot(theta_t,theta_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('stop theta')
% beta
figure; hold on;
beta_pop = pop.events.stop_beta;
plot(beta_t,beta_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('stop beta')

% per monkey raw
for i= 1:length(monk)
    figure; hold on;
    plot(t_raw, monk(i).erp.stop_raw, 'Color', [1 2 3]==i)
    set(gca,'xlim',[-0.5 0.5],'TickDir', 'out', 'FontSize', 18); box off;
    title('stop')
end


%% reward
cnt1 = 1; cnt2 = 1; cnt3= 1;
for i = 1:length(exp)
    for sess = 1:length(exp(i).session)
        if ~isempty(exp(i).session(sess).lfps(1).stats) & exp(i).monk_id == 53  %Schro
            clear raw_mu raw_sem raw_fix_mu raw_sacc_mu theta_mu theta_sem theta_fix theta_fix_t theta_sacc theta_sacc_t beta_mu beta_sem
            for ch = 1:length(exp(i).session(1).lfps)
                raw_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.raw.potential_mu;
                raw_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.raw.potential_mu;
                %
                theta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.theta.potential_mu;
                theta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.theta.potential_sem;
                theta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.theta.time;
                %
                beta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.beta.potential_mu;
                beta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.beta.potential_sem;
                beta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.beta.time;
            end
            monk(1).events(cnt1,:).reward.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.raw.time;
            monk(1).events(cnt1,:).reward.raw_mu = nanmean(raw_mu);
            monk(1).events(cnt1,:).reward.raw_sem = std(raw_mu)/sqrt(length(raw_mu));
            monk(1).events(cnt1,:).reward.raw_t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.raw.time;
            monk(1).events(cnt1,:).reward.theta.mu = nanmean(real(theta_mu));
            monk(1).events(cnt1,:).reward.theta.sem = std(theta_mu)/sqrt(length(theta_mu));
            monk(1).events(cnt1,:).reward.theta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.theta.time;
            monk(1).events(cnt1,:).reward.beta.mu = nanmean(real(beta_mu));
            monk(1).events(cnt1,:).reward.beta.sem = std(beta_mu)/sqrt(length(beta_mu));
            monk(1).events(cnt1,:).reward.beta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.beta.time;
            cnt1=cnt1+1;
            
            % plot single sessions 96 ch
            %                         figure; hold on; plot(monk(1).events(cnt1,:).reward.t, raw_mu);
            %                         set(gca,'TickDir', 'out', 'FontSize', 18, 'xlim',[-1.5 0.5]); box off;
            %                         title('Schro')
            %                         figure; hold on
            %                         shadedErrorBar(monk(1).events(cnt1,:).reward.t, nanmean(raw_mu), std(raw_mu))
            %                         set(gca,'TickDir', 'out', 'FontSize', 18,'xlim',[-1.5 0.5]); box off;
            %                         title('Schro')
            %                         keyboard;
            
        elseif ~isempty(exp(i).session(sess).lfps(1).stats.trialtype) & exp(i).monk_id == 51 % Bruno
            clear raw_mu raw_sem raw_fix_mu raw_sacc_mu theta_mu theta_sem theta_fix theta_fix_t theta_sacc theta_sacc_t beta_mu beta_sem
            for ch = 1:length(exp(i).session(1).lfps)
                raw_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.raw.potential_mu;
                raw_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.raw.potential_mu;
                %
                theta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.theta.potential_mu;
                theta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.theta.potential_sem;
                theta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.theta.time;
                %
                beta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.beta.potential_mu;
                beta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.beta.potential_sem;
                beta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.beta.time;
            end
            monk(2).events(cnt2,:).reward.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.raw.time;
            monk(2).events(cnt2,:).reward.raw_mu = nanmean(raw_mu);
            monk(2).events(cnt2,:).reward.raw_sem = std(raw_mu)/sqrt(length(raw_mu));
            monk(2).events(cnt2,:).reward.raw_t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.raw.time;
            monk(2).events(cnt2,:).reward.theta.mu = nanmean(theta_mu);
            monk(2).events(cnt2,:).reward.theta.sem = std(theta_mu)/sqrt(length(theta_mu));
            monk(2).events(cnt2,:).reward.theta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.theta.time;
            monk(2).events(cnt2,:).reward.beta.mu = nanmean(real(beta_mu));
            monk(2).events(cnt2,:).reward.beta.sem = std(beta_mu)/sqrt(length(beta_mu));
            monk(2).events(cnt2,:).reward.beta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.beta.time;
            cnt2=cnt2+1;
            
            % plot single sessions 96 ch
            %                         figure; hold on; plot(monk(2).events(cnt1,:).reward.t, raw_mu);
            %                         set(gca,'TickDir', 'out', 'FontSize', 18, 'xlim',[-1.5 0.5]); box off;
            %                         title('Bruno')
            %                         figure; hold on
            %                         shadedErrorBar(monk(2).events(cnt1,:).reward.t, nanmean(raw_mu), std(raw_mu))
            %                         set(gca,'TickDir', 'out', 'FontSize', 18,'xlim',[-1.5 0.5]); box off;
            %                         title('Bruno')
            %                         keyboard;
            
        elseif ~isempty(exp(i).session(sess).lfps(1).stats.trialtype) & exp(i).monk_id == 44 % Quigley
            clear raw_mu raw_sem raw_fix_mu raw_sacc_mu theta_mu theta_sem theta_fix theta_fix_t theta_sacc theta_sacc_t beta_mu beta_sem
            for ch = 1:length(exp(i).session(1).lfps)
                raw_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.raw.potential_mu;
                raw_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.raw.potential_mu;
                %
                theta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.theta.potential_mu;
                theta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.theta.potential_sem;
                theta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.theta.time;
                %
                beta_mu(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.beta.potential_mu;
                beta_sem(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.beta.potential_sem;
                beta_t(ch,:) = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.beta.time;
            end
            monk(3).events(cnt3,:).reward.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.raw.time;
            monk(3).events(cnt3,:).reward.raw_mu = nanmean(raw_mu);
            monk(3).events(cnt3,:).reward.raw_sem = std(raw_mu)/sqrt(length(raw_mu));
            monk(3).events(cnt3,:).reward.raw_t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.raw.time;
            monk(3).events(cnt3,:).reward.theta.mu = nanmean(theta_mu);
            monk(3).events(cnt3,:).reward.theta.sem = std(theta_mu)/sqrt(length(theta_mu));
            monk(3).events(cnt3,:).reward.theta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.theta.time;
            monk(3).events(cnt3,:).reward.beta.mu = nanmean(real(beta_mu));
            monk(3).events(cnt3,:).reward.beta.sem = std(beta_mu)/sqrt(length(beta_mu));
            monk(3).events(cnt3,:).reward.beta.t = exp(i).session(sess).lfps(ch).stats.trialtype.all.events.reward.beta.time;
            cnt3=cnt3+1;
            
            % plot single sessions 96 ch
            %                         figure; hold on; plot(monk(3).events(cnt1,:).reward.t, raw_mu);
            %                         set(gca,'TickDir', 'out', 'FontSize', 18, 'xlim',[-1.5 0.5]); box off;
            %                         title('Quigley')
            %                         figure; hold on
            %                         shadedErrorBar(monk(3).events(cnt1,:).reward.t, nanmean(raw_mu), std(raw_mu))
            %                         set(gca,'TickDir', 'out', 'FontSize', 18,'xlim',[-1.5 0.5]); box off;
            %                         title('Quigley')
            %                         keyboard;
            
        end
    end
end

% average across datasets
for i = 1:length(monk)
    clear raw_ev theta_ev beta_ev
    for ev = 1:length(monk(i).events)
        raw_ev(ev,:) = monk(i).events(ev).reward.raw_mu;
        theta_ev(ev,:) = monk(i).events(ev).reward.theta.mu;
        beta_ev(ev,:) = monk(i).events(ev).reward.beta.mu;
    end
    monk(i).erp.reward_raw = nanmean(raw_ev);
    monk(i).erp.reward_theta = nanmean(theta_ev);
    monk(i).erp.reward_beta = nanmean(beta_ev);
    
    % get erp diff
    for ev = 1:length(monk(i).events)
        monk(i).diff_amp_reward(ev) = abs(max(raw_ev(ev, t_raw>-0.5 & t_raw < 0.5)) - min(raw_ev(ev,t_raw>-0.5 & t_raw < 0.5)));
        [monk(i).max_reward(ev),monk(i).indx_max_reward(ev)] = max(abs(raw_ev(ev, t_raw>-0.5 & t_raw < 0.5)));
        monk(i).diff_amp_reward_t(ev) = monk(1).events(1).move.raw_t(monk(i).indx_max_reward(ev));
    end
    
end

% average across monkeys
for i = 1:length(monk)
    reward_raw(i,:) = monk(i).erp.reward_raw;
    reward_theta(i,:) = monk(i).erp.reward_theta;
    reward_beta(i,:) = monk(i).erp.reward_beta;
end

pop.events.reward_raw = nanmean(reward_raw);
pop.events.reward_theta = nanmean(reward_theta);
pop.events.reward_beta = nanmean(reward_beta);

% plot
figure; hold on;
t_raw = monk(1).events(1).reward.t;
raw_pop = pop.events.reward_raw;
plot(t_raw,raw_pop, 'LineWidth', 2);
set(gca,'xlim',[-1.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('reward')
% theta
figure; hold on;
theta_pop = pop.events.reward_theta;
plot(theta_t,theta_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('reward theta')
% beta
figure; hold on;
beta_pop = pop.events.reward_beta;
plot(beta_t,beta_pop, 'LineWidth', 2);
set(gca,'xlim',[-0.5 0.5], 'TickDir', 'out', 'FontSize', 18); box off;
title('reward beta')

% per monkey raw
for i= 1:length(monk)
    figure; hold on;
    plot(t_raw, monk(i).erp.reward_raw, 'Color', [1 2 3]==i)
    set(gca,'xlim',[-1.5 0.5],'TickDir', 'out', 'FontSize', 18); box off;
    title('reward')
end


%% plot ERP mean µV for all conditions
% plot amplitude diff move
figure; hold on;
for i = 1:length(monk)
    errorbar(i, mean(monk(i).diff_amp_move),std(monk(i).diff_amp_move), '.','MarkerSize',22, 'CapSize', 0, 'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end
% stop
cnt = 3;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).diff_amp_stop),std(monk(i).diff_amp_stop), '.','MarkerSize',22, 'CapSize', 0, 'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end

% plot amplitude diff sacc
cnt = 6;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).diff_amp_sacc),std(monk(i).diff_amp_sacc), '.','MarkerSize',22, 'CapSize', 0,'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end

% plot amplitude diff fix
cnt=9;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).diff_amp_fix),std(monk(i).diff_amp_fix), '.','MarkerSize',22, 'CapSize', 0,'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end

% plot amplitude diff targ
cnt=12;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).diff_amp_targ),std(monk(i).diff_amp_targ), '.','MarkerSize',22, 'CapSize', 0,'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end

% plot amplitude diff reward
cnt = 15;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).diff_amp_reward),std(monk(i).diff_amp_reward), '.','MarkerSize',22, 'CapSize', 0,'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18, 'xTick', [], 'xTickLabel', []); box off;
end
ylabel('ERP amplitude difference (µV)')

%% plot time of max ERP for all conditions

figure; hold on;
for i = 1:length(monk)
    errorbar(i, mean(monk(i).diff_amp_move_t),std(monk(i).diff_amp_move_t), '.','MarkerSize',22, 'CapSize', 0, 'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end
cnt = 3; 
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).diff_amp_stop_t),std(monk(i).diff_amp_stop_t), '.','MarkerSize',22, 'CapSize', 0, 'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end
% plot amplitude diff sacc
cnt = 6;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).diff_amp_sacc_t),std(monk(i).diff_amp_sacc_t), '.','MarkerSize',22, 'CapSize', 0,'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end

% plot amplitude diff fix
cnt=9;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).diff_amp_fix_t),std(monk(i).diff_amp_fix_t), '.','MarkerSize',22, 'CapSize', 0,'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end

% plot amplitude diff targ
cnt=12;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).diff_amp_targ_t),std(monk(i).diff_amp_targ_t), '.','MarkerSize',22, 'CapSize', 0,'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end

% plot amplitude diff reward
cnt = 15;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).diff_amp_reward_t),std(monk(i).diff_amp_reward_t), '.','MarkerSize',22, 'CapSize', 0,'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18, 'xTick', [], 'xTickLabel', []); box off;
end
hline(0, '--k');
ylabel('Time from movement onset (s)');

%% plot max ERP for all conditions

figure; hold on;
for i = 1:length(monk)
    errorbar(i, mean(monk(i).max_move),std(monk(i).max_move), '.','MarkerSize',22, 'CapSize', 0, 'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end
cnt=3; 
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).max_stop),std(monk(i).max_stop), '.','MarkerSize',22, 'CapSize', 0, 'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end

% plot amplitude diff sacc
cnt = 6;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).max_sacc),std(monk(i).max_sacc), '.','MarkerSize',22, 'CapSize', 0,'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end

% plot amplitude diff fix
cnt=9;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).max_fix),std(monk(i).max_fix), '.','MarkerSize',22, 'CapSize', 0,'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end

% plot amplitude diff targ
cnt=12;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).max_targ),std(monk(i).max_targ), '.','MarkerSize',22, 'CapSize', 0,'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18); box off;
end

% plot amplitude diff reward
cnt = 15;
for i = 1:length(monk)
    errorbar(i+cnt, mean(monk(i).max_reward),std(monk(i).max_reward), '.','MarkerSize',22, 'CapSize', 0,'Color', ([1 2 3]==i));
    set(gca,'TickDir', 'out', 'FontSize', 18, 'xTick', [], 'xTickLabel', []); box off;
end
ylabel('Max ERP (µV)');

%% spectrograms
cnt1 = 1; cnt2 = 1; cnt3= 1;
for i = 1:length(exp)
    for sess = 1:length(exp(i).session)
        if ~isempty(exp(i).session(sess).lfps(1).stats) & exp(i).monk_id == 53  %Schro
            clear move_sp move_t stop_sp stop_t reward_sp reward_t target_sp target_t fix_sp fix_t sacc_sp sacc_t
            for ch = 1:length(exp(i).session(1).lfps)
                move_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.move.tfspectrum.psd;
                move_t(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.move.tfspectrum.time;
                move_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.move.tfspectrum.freq;
                %
                stop_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.stop.tfspectrum.psd;
                stop_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.stop.tfspectrum.time;
                stop_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.stop.tfspectrum.freq;
                %
                reward_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.reward.tfspectrum.psd;
                reward_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.reward.tfspectrum.time;
                reward_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.reward.tfspectrum.freq;
                %
                target_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.target.tfspectrum.psd;
                target_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.target.tfspectrum.time;
                target_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.target.tfspectrum.freq;
                %
                fix_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.tfspectrum.psd;
                fix_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.tfspectrum.time;
                fix_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.tfspectrum.freq;
                %
                sacc_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.tfspectrum.psd;
                sacc_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.tfspectrum.time;
                sacc_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.tfspectrum.freq;
            end
            monk(1).spectro(cnt1,:).move.time = exp(i).session(sess).lfps(ch).stats.eventtype.move.tfspectrum.time;
            monk(1).spectro(cnt1,:).move.psd = nanmean(move_sp);
            monk(1).spectro(cnt1,:).move.freq = nanmean(move_f);
            
            monk(1).spectro(cnt1,:).stop.time = exp(i).session(sess).lfps(ch).stats.eventtype.stop.tfspectrum.time;
            monk(1).spectro(cnt1,:).stop.psd = nanmean(stop_sp);
            monk(1).spectro(cnt1,:).stop.freq = nanmean(stop_f);
            
            monk(1).spectro(cnt1,:).reward.time = exp(i).session(sess).lfps(ch).stats.eventtype.reward.tfspectrum.time;
            monk(1).spectro(cnt1,:).reward.psd = nanmean(reward_sp);
            monk(1).spectro(cnt1,:).reward.freq = nanmean(reward_f);
            
            monk(1).spectro(cnt1,:).target.time = exp(i).session(sess).lfps(ch).stats.eventtype.target.tfspectrum.time;
            monk(1).spectro(cnt1,:).target.psd = nanmean(target_sp);
            monk(1).spectro(cnt1,:).target.freq = nanmean(target_f);
            
            monk(1).spectro(cnt1,:).fix.time = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.tfspectrum.time;
            monk(1).spectro(cnt1,:).fix.psd = nanmean(fix_sp);
            monk(1).spectro(cnt1,:).fix.freq = nanmean(fix_f);
            
            monk(1).spectro(cnt1,:).sacc.time = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.tfspectrum.time;
            monk(1).spectro(cnt1,:).sacc.psd = nanmean(sacc_sp);
            monk(1).spectro(cnt1,:).sacc.freq = nanmean(sacc_f);
            
            cnt1=cnt1+1;
        elseif ~isempty(exp(i).session(sess).lfps(1).stats.trialtype) & exp(i).monk_id == 51 % Bruno
            clear move_sp move_t stop_sp stop_t reward_sp reward_t target_sp target_t fix_sp fix_t sacc_sp sacc_t
            for ch = 1:length(exp(i).session(1).lfps)
                move_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.move.tfspectrum.psd;
                move_t(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.move.tfspectrum.time;
                move_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.move.tfspectrum.freq;
                %
                stop_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.stop.tfspectrum.psd;
                stop_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.stop.tfspectrum.time;
                stop_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.stop.tfspectrum.freq;
                %
                reward_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.reward.tfspectrum.psd;
                reward_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.reward.tfspectrum.time;
                reward_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.reward.tfspectrum.freq;
                %
                target_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.target.tfspectrum.psd;
                target_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.target.tfspectrum.time;
                target_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.target.tfspectrum.freq;
                %
                fix_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.tfspectrum.psd;
                fix_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.tfspectrum.time;
                fix_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.tfspectrum.freq;
                %
                sacc_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.tfspectrum.psd;
                sacc_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.tfspectrum.time;
                sacc_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.tfspectrum.freq;
            end
            monk(2).spectro(cnt2,:).move.time = exp(i).session(sess).lfps(ch).stats.eventtype.move.tfspectrum.time;
            monk(2).spectro(cnt2,:).move.psd = nanmean(move_sp);
            monk(2).spectro(cnt2,:).move.freq = nanmean(move_f);
            
            monk(2).spectro(cnt2,:).stop.time = exp(i).session(sess).lfps(ch).stats.eventtype.stop.tfspectrum.time;
            monk(2).spectro(cnt2,:).stop.psd = nanmean(stop_sp);
            monk(2).spectro(cnt2,:).stop.freq = nanmean(stop_f);
            
            monk(2).spectro(cnt2,:).reward.time = exp(i).session(sess).lfps(ch).stats.eventtype.reward.tfspectrum.time;
            monk(2).spectro(cnt2,:).reward.psd = nanmean(reward_sp);
            monk(2).spectro(cnt2,:).reward.freq = nanmean(reward_f);
            
            monk(2).spectro(cnt2,:).target.time = exp(i).session(sess).lfps(ch).stats.eventtype.target.tfspectrum.time;
            monk(2).spectro(cnt2,:).target.psd = nanmean(target_sp);
            monk(2).spectro(cnt2,:).target.freq = nanmean(target_f);
            
            monk(2).spectro(cnt2,:).fix.time = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.tfspectrum.time;
            monk(2).spectro(cnt2,:).fix.psd = nanmean(fix_sp);
            monk(2).spectro(cnt2,:).fix.freq = nanmean(fix_f);
            
            monk(2).spectro(cnt2,:).sacc.time = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.tfspectrum.time;
            monk(2).spectro(cnt2,:).sacc.psd = nanmean(sacc_sp);
            monk(2).spectro(cnt2,:).sacc.freq = nanmean(sacc_f);
            
            cnt2=cnt2+1;
        else ~isempty(exp(i).session(sess).lfps(1).stats) & exp(i).monk_id == 44
            clear move_sp move_t stop_sp stop_t reward_sp reward_t target_sp target_t fix_sp fix_t sacc_sp sacc_t
            for ch = 1:length(exp(i).session(1).lfps)
                move_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.move.tfspectrum.psd;
                move_t(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.move.tfspectrum.time;
                move_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.move.tfspectrum.freq;
                %
                stop_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.stop.tfspectrum.psd;
                stop_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.stop.tfspectrum.time;
                stop_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.stop.tfspectrum.freq;
                %
                reward_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.reward.tfspectrum.psd;
                reward_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.reward.tfspectrum.time;
                reward_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.reward.tfspectrum.freq;
                %
                target_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.target.tfspectrum.psd;
                target_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.target.tfspectrum.time;
                target_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.target.tfspectrum.freq;
                %
                fix_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.tfspectrum.psd;
                fix_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.tfspectrum.time;
                fix_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.tfspectrum.freq;
                %
                sacc_sp(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.tfspectrum.psd;
                sacc_t(ch,:,:) = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.tfspectrum.time;
                sacc_f(ch,:) = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.tfspectrum.freq;
            end
            monk(3).spectro(cnt3,:).move.time = exp(i).session(sess).lfps(ch).stats.eventtype.move.tfspectrum.time;
            monk(3).spectro(cnt3,:).move.psd = nanmean(move_sp);
            monk(3).spectro(cnt3,:).move.freq = nanmean(move_f);
            
            monk(3).spectro(cnt3,:).stop.time = exp(i).session(sess).lfps(ch).stats.eventtype.stop.tfspectrum.time;
            monk(3).spectro(cnt3,:).stop.psd = nanmean(stop_sp);
            monk(3).spectro(cnt3,:).stop.freq = nanmean(stop_f);
            
            monk(3).spectro(cnt3,:).reward.time = exp(i).session(sess).lfps(ch).stats.eventtype.reward.tfspectrum.time;
            monk(3).spectro(cnt3,:).reward.psd = nanmean(reward_sp);
            monk(3).spectro(cnt3,:).reward.freq = nanmean(reward_f);
            
            monk(3).spectro(cnt3,:).target.time = exp(i).session(sess).lfps(ch).stats.eventtype.target.tfspectrum.time;
            monk(3).spectro(cnt3,:).target.psd = nanmean(target_sp);
            monk(3).spectro(cnt3,:).target.freq = nanmean(target_f);
            
            monk(3).spectro(cnt3,:).fix.time = exp(i).session(sess).lfps(ch).stats.eventtype.fixate.tfspectrum.time;
            monk(3).spectro(cnt3,:).fix.psd = nanmean(fix_sp);
            monk(3).spectro(cnt3,:).fix.freq = nanmean(fix_f);
            
            monk(3).spectro(cnt3,:).sacc.time = exp(i).session(sess).lfps(ch).stats.eventtype.saccade.tfspectrum.time;
            monk(3).spectro(cnt3,:).sacc.psd = nanmean(sacc_sp);
            monk(3).spectro(cnt3,:).sacc.freq = nanmean(sacc_f);
            
            cnt3=cnt3+1;
        end
    end
end

% average across datasets
for i = 1:length(monk)
    clear move_sp stop_sp reward_sp target_sp fix_sp sacc_sp
    for ev = 1:length(monk(i).spectro)
        move_sp(ev,:,:) = monk(i).spectro(ev).move.psd;
        stop_sp(ev,:,:) = monk(i).spectro(ev).stop.psd;
        reward_sp(ev,:,:) = monk(i).spectro(ev).reward.psd;
        target_sp(ev,:,:) = monk(i).spectro(ev).target.psd;
        fix_sp(ev,:,:) = monk(i).spectro(ev).fix.psd;
        sacc_sp(ev,:,:) = monk(i).spectro(ev).sacc.psd;
    end
    monk(i).spectro_move_mu = nanmean(move_sp);
    monk(i).spectro_stop_mu = nanmean(stop_sp);
    monk(i).spectro_reward_mu = nanmean(reward_sp);
    monk(i).spectro_target_mu = nanmean(target_sp);
    monk(i).spectro_fix_mu = nanmean(fix_sp);
    monk(i).spectro_sacc_mu = nanmean(sacc_sp);
end

% average across monkeys
clear move_sp stop_sp reward_sp target_sp fix_sp sacc_sp
for i = 1:length(monk)
    move_sp(i,:,:) = monk(i).spectro_move_mu;
    stop_sp(i,:,:) =  monk(i).spectro_stop_mu;
    reward_sp(i,:,:) = monk(i).spectro_reward_mu;
    target_sp(i,:,:) = monk(i).spectro_target_mu;
    fix_sp(i,:,:) = monk(i).spectro_fix_mu;
    sacc_sp(i,:,:) = monk(i).spectro_sacc_mu;
end

pop.spectro.move = squeeze(nanmean(move_sp));
pop.spectro.stop = squeeze(nanmean(stop_sp));
pop.spectro.reward = squeeze(nanmean(reward_sp));
pop.spectro.target = squeeze(nanmean(target_sp));
pop.spectro.fix = squeeze(nanmean(fix_sp));
pop.spectro.sacc = squeeze(nanmean(sacc_sp));

% plot
% move
figure; hold on;
t_spectro = monk(1).spectro(1).move.time; freq = monk(1).spectro(1).move.freq; indx_freq = freq > 5 & freq < 30;
imagesc(freq(indx_freq),t_spectro,pop.spectro.move(indx_freq));
set(gca,'YDir','normal', 'ylim', [-1 3],'FontSize', 18,'xlim',[5 30]);
title('move')

% stop
figure; hold on;
t_spectro = monk(1).spectro(1).stop.time; freq = monk(1).spectro(1).stop.freq;
imagesc(freq(indx_freq), t_spectro, pop.spectro.stop(indx_freq));
set(gca,'YDir','normal', 'ylim', [-1 3],'FontSize', 18,'xlim',[5 30]);
title('stop')

% reward
figure; hold on;
t_spectro = monk(1).spectro(1).reward.time; freq = monk(1).spectro(1).reward.freq;
imagesc(freq(indx_freq), t_spectro, pop.spectro.reward(indx_freq));
set(gca,'YDir','normal', 'ylim', [-1 3],'FontSize', 18, 'xlim',[5 30]);
title('reward')

% target
figure; hold on;
t_spectro = monk(1).spectro(1).target.time; freq = monk(1).spectro(1).target.freq;
imagesc(freq(indx_freq), t_spectro, pop.spectro.target(indx_freq));
set(gca,'YDir','normal', 'ylim', [-1 3],'FontSize', 18, 'xlim',[5 30]);
title('target')

% fix
figure; hold on;
t_spectro = monk(1).spectro(1).fix.time; freq = monk(1).spectro(1).fix.freq;
imagesc(freq(indx_freq), t_spectro, pop.spectro.fix(indx_freq));
set(gca,'YDir','normal', 'ylim', [-1 3],'FontSize', 18, 'xlim',[5 30]);
title('fix')

% sacc
figure; hold on;
t_spectro = monk(1).spectro(1).sacc.time; freq = monk(1).spectro(1).sacc.freq;
imagesc(freq(indx_freq), t_spectro, pop.spectro.sacc(indx_freq));
set(gca,'YDir','normal', 'ylim', [-1 3],'FontSize', 18, 'xlim',[5 30]);
title('sacc')




