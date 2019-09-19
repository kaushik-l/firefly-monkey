function PlotLFP(lfps,pop_lfps,electrode_id,plot_type,prs)

theta_peak = prs.lfp_theta_peak;
beta_peak = prs.lfp_beta_peak;
electrode = prs.electrode_type;

if electrode_id ~= 0
    lfp = lfps([lfps.electrode_id]==electrode_id);
    switch plot_type
        case 'PSD'
            f = lfp.stats.trialtype.all.spectrum.freq;
            psd = lfp.stats.trialtype.all.spectrum.psd;
            figure; plot(f,psd);
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
        case 'PSD_all'
            f = lfp.stats.trialtype.all.spectrum.freq;
            for i = 1:length(lfps) % for Schro
                psd(i,:) = lfps(i).stats.trialtype.all.spectrum.psd;
            end
            figure; plot(f,nanmean(psd), 'LineWidth',2);
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
        case 'PSDarray'
            nlfps = 48;
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx);
            figure; hold on;
            f = lfps(1).stats.trialtype.all.spectrum.freq;
            for i=1:nlfps
                psd = lfps(i).stats.trialtype.all.spectrum.psd;
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                plot(f,psd, 'c'); axis([2 50 0 75]); axis off; box off;
                %vline(15, '--k');
            end
        case 'PSDarray_norm'
            nlfps = 96;
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx);
            for i=1:nlfps
                psd_norm(i,:) = lfps(i).stats.trialtype.all.spectrum.psd;
            end
            max_psd = max(max(psd_norm,[],2));
            f = lfps(1).stats.trialtype.all.spectrum.freq;
            for i=1:nlfps
                psd = lfps(i).stats.trialtype.all.spectrum.psd/max_psd;
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                plot(f,psd); axis([2 50 0 0.6]); axis off; box off;
            end
        case 'PSD_movement'
            figure; hold on;
            f1 = lfp.stats.trialtype.stationary.spectrum.freq;
            psd1 = lfp.stats.trialtype.stationary.spectrum.psd;
            f2 = lfp.stats.trialtype.mobile.spectrum.freq;
            psd2 = lfp.stats.trialtype.mobile.spectrum.psd;
            subplot(1,2,1); plot(f1,psd1); plot(f2,psd2);
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
            subplot(1,2,2); plot(f1,psd2./psd1);
            axis([1 50 0 1.5]); hline(1,'k'); xlabel('Frequency (Hz)'); ylabel('Power spectral density ratio');
        case 'ERP_targ'
            t = lfp.stats.trialtype.all.events.target.time;
            v_mu = lfp.stats.trialtype.all.events.target.potential_mu;
            v_sem = lfp.stats.trialtype.all.events.target.potential_sem;
            figure; shadedErrorBar(t,v_mu,v_sem);
            xlim([-1 1]); hline(0,'k'); vline(0,'k'); xlabel('Time rel. to target onset (s)'); ylabel('Event-related potential (\muV)');
        case 'ERP_move'
            t = lfp.stats.trialtype.all.events.move.time;
            v_mu = lfp.stats.trialtype.all.events.move.potential_mu;
            v_sem = lfp.stats.trialtype.all.events.move.potential_sem;
            figure; shadedErrorBar(t,v_mu,v_sem);
            xlim([-1 1]); hline(0,'k'); vline(0,'k'); xlabel('Time rel. to movement onset (s)'); ylabel('Event-related potential (\muV)');
        case 'ERP_stop'
            t = lfp.stats.trialtype.all.events.stop.time;
            v_mu = lfp.stats.trialtype.all.events.stop.potential_mu;
            v_sem = lfp.stats.trialtype.all.events.stop.potential_sem;
            figure; shadedErrorBar(t,v_mu,v_sem);
            xlim([-1 1]); hline(0,'k'); vline(0,'k'); xlabel('Time rel. to end of movement (s)'); ylabel('Event-related potential (\muV)');
        case 'ERP_rew'
            t = lfp.stats.trialtype.all.events.reward.time;
            v_mu = lfp.stats.trialtype.all.events.reward.potential_mu;
            v_sem = lfp.stats.trialtype.all.events.reward.potential_sem;
            figure; shadedErrorBar(t,v_mu,v_sem);
            xlim([-1 1]); hline(0,'k'); vline(0,'k'); xlabel('Time rel. to reward delivery (s)'); ylabel('Event-related potential (\muV)');
        case 'rawLFP_movement'
            ntrls = numel(lfp.stationary);
            trlindx = floor(rand*(ntrls-1))
            lfp_temp1 = lfp.stationary(trlindx).lfp; lfp_temp2 = lfp.mobile(trlindx).lfp;
            lfp_temp3 = lfp.stationary(trlindx+1).lfp; lfp_temp4 = lfp.mobile(trlindx+1).lfp;
            dt = prs.dt;
            ts_temp1 = dt:dt:dt*numel(lfp_temp1); ts_temp2 = ts_temp1(end) + [dt:dt:dt*numel(lfp_temp2)];
            ts_temp3 = ts_temp2(end) + [dt:dt:dt*numel(lfp_temp3)]; ts_temp4 = ts_temp3(end) + [dt:dt:dt*numel(lfp_temp4)];
            figure; hold on
            plot(ts_temp1,lfp_temp1,'k'); plot(ts_temp2,lfp_temp2,'r');
            plot(ts_temp3,lfp_temp3,'k'); plot(ts_temp4,lfp_temp4,'r');
        case 'PSD_move_all'
            freq = lfps(1).stats.trialtype.mobile.spectrum.freq; nlfps = length(lfps); %48;
            for i = 1:length(lfps); % 48; % 48 for Schro
                mobile(i,:) = lfps(i).stats.trialtype.mobile.spectrum.psd;
                stationary(i,:) = lfps(i).stats.trialtype.stationary.spectrum.psd;
            end
            figure; hold on;
            shadedErrorBar(freq,nanmean(mobile),nanstd(mobile)/sqrt(nlfps), 'lineprops', 'r');
            shadedErrorBar(freq,nanmean(stationary),nanstd(stationary)/sqrt(nlfps),'lineprops','k');
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
            set(gca, 'TickDir', 'out','ylim',[0 150],'yTick', [0 150], 'FontSize',18);
            
        case 'PSD_eye_single'
            figure; hold on;
            f1 = lfp.stats.trialtype.eyesfree.spectrum.freq;
            psd1 = lfp.stats.trialtype.eyesfree.spectrum.psd;
            f2 = lfp.stats.trialtype.eyesfixed.spectrum.freq;
            psd2 = lfp.stats.trialtype.eyesfixed_stationary.spectrum.psd;
            plot(f1,psd1,'r','LineWidth', 2); plot(f2,psd2,'k','LineWidth', 2); % plot(f3,psd3,'b'); plot(f4,psd4,'c');
            set(gca, 'TickDir', 'out','xlim', [2 50], 'ylim',[0 300],'yTick', [0 300], 'FontSize',18);
            xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
        case 'PSD_eye_all'
            freq = lfps(1).stats.trialtype.eyesfree.spectrum.freq; nlfps = length(lfps); %48;
            for i = 1:length(lfps); % 48; % 48 for Schro
                eyesfree(i,:) = lfps(i).stats.trialtype.eyesfree.spectrum.psd;
                eyesfixed(i,:) = lfps(i).stats.trialtype.eyesfixed.spectrum.psd;
            end
            figure; hold on;
            shadedErrorBar(freq,nanmean(eyesfree),nanstd(eyesfree)/sqrt(nlfps), 'lineprops', 'r');
            shadedErrorBar(freq,nanmean(eyesfixed),nanstd(eyesfixed)/sqrt(nlfps),'lineprops','k');
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
            set(gca, 'TickDir', 'out','ylim',[0 150],'yTick', [0 150], 'FontSize',18);
        case 'PSD_eye_array'  % main plot
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx); nlfps = length(lfps); %48;
            figure; hold on;
            f = lfps(1).stats.trialtype.eyesfree_mobile.spectrum.freq;
            for i=1:nlfps % 48 for Schro
                psd1 = lfps(i).stats.trialtype.eyesfree.spectrum.psd;
                psd2 = lfps(i).stats.trialtype.eyesfixed.spectrum.psd;
                
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                plot(f,psd1,'r'); axis([2 50 0 150]); axis off; box off;
                plot(f,psd2,'k'); axis([2 50 0 150]); axis off; box off;
                xlim([2 50]); ylim([0 250]); vline(15);
            end
        case 'PSD_eye_move_all'  % main plot
            freq = lfps(1).stats.trialtype.eyesfree_mobile.spectrum.freq;
            for i = 1:length(lfps); % 48; % 48 for Schro
                eyesfree_mobile(i,:) = lfps(i).stats.trialtype.eyesfree_mobile.spectrum.psd;
                eyesfree_stationary(i,:) = lfps(i).stats.trialtype.eyesfree_stationary.spectrum.psd;
                eyesfixed_mobile(i,:) = lfps(i).stats.trialtype.eyesfixed_mobile.spectrum.psd;
                eyesfixed_stationary(i,:) = lfps(i).stats.trialtype.eyesfixed_stationary.spectrum.psd;
            end
            figure; hold on;
            %             shadedErrorBar(freq,nanmean(eyesfree_mobile),nanstd(eyesfree_mobile),'lineprops','r');
            %             shadedErrorBar(freq,nanmean(eyesfree_stationary),nanstd(eyesfree_stationary),'lineprops','k');
            %             shadedErrorBar(freq,nanmean(eyesfixed_mobile),nanstd(eyesfixed_mobile),'lineprops','m');
            %             shadedErrorBar(freq,nanmean(eyesfixed_stationary),nanstd(eyesfixed_stationary),'lineprops','b');
            plot(freq,nanmean(eyesfree_mobile),'r', 'LineWidth', 2);
            plot(freq,nanmean(eyesfree_stationary),'k', 'LineWidth', 2);
            plot(freq,nanmean(eyesfixed_mobile),'m', 'LineWidth', 2);
            plot(freq,nanmean(eyesfixed_stationary),'b', 'LineWidth', 2);
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
            set(gca, 'TickDir', 'out','ylim',[0 150],'yTick', [0 150], 'FontSize',18);
        case 'PSD_eye_move_array'  % main plot
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx); nlfps = length(lfps); %48;
            figure; hold on;
            f = lfps(1).stats.trialtype.eyesfree_mobile.spectrum.freq;
            for i=1:nlfps; % 48 for Schro
                psd1 = lfps(i).stats.trialtype.eyesfree_mobile.spectrum.psd;
                psd2 = lfps(i).stats.trialtype.eyesfree_stationary.spectrum.psd;
                psd3 = lfps(i).stats.trialtype.eyesfixed_mobile.spectrum.psd;
                psd4 = lfps(i).stats.trialtype.eyesfixed_stationary.spectrum.psd;
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                plot(f,psd1,'r'); axis([2 50 0 150]); axis off; box off;
                plot(f,psd2,'k'); axis([2 50 0 150]); axis off; box off;
                plot(f,psd3,'m'); axis([2 50 0 150]); axis off; box off;
                plot(f,psd4,'b'); axis([2 50 0 150]); axis off; box off;
                xlim([2 50]); ylim([0 175]); vline(15);
            end
        case 'PSD_eyes_free'
            %             freq = lfps(1).stats.trialtype.eyesfree_mobile.spectrum.freq;
            %             for i = 1:length(lfps)
            %                 eyesfree_mobile(i,:) = lfps(i).stats.trialtype.eyesfree_mobile.spectrum.psd;
            %                 eyesfree_stationary(i,:) = lfps(i).stats.trialtype.eyesfree_stationary.spectrum.psd;
            %                 eyesfixed_mobile(i,:) = lfps(i).stats.trialtype.eyesfixed_mobile.spectrum.psd;
            %                 eyesfixed_stationary(i,:) = lfps(i).stats.trialtype.eyesfixed_stationary.spectrum.psd;
            %             end
            %             psd_eyesfree = mean([mean(eyesfree_mobile); mean(eyesfree_stationary)]);
            %             psd_eyesfree_std = std([std(eyesfree_mobile); mean(eyesfree_stationary)]);
            %             psd_eyesfixed = mean([mean(eyesfixed_mobile); mean(eyesfixed_stationary)]);
            %             psd_eyesfixed_std = std([std(eyesfixed_mobile); mean(eyesfixed_stationary)]);
            %
            %             shadedErrorBar(freq,psd_eyesfree,psd_eyesfree_std,'lineprops','r');
            %             shadedErrorBar(freq,psd_eyesfixed,psd_eyesfixed_std,'lineprops','k');
            %             xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
            %             set(gca, 'TickDir', 'out','ylim',[0 700] ,'yTick', [0 700], 'FontSize',18);
            %             title('Eye free vs eyes fixed')
            
        case 'PSD_eyes_free_all'
            freq = lfps(1).stats.trialtype.eyesfree_mobile.spectrum.freq;
            for i = 1:length(lfps)
                eyesfree_mobile(i,:) = lfps(i).stats.trialtype.eyesfree_mobile.spectrum.psd;
                eyesfree_stationary(i,:) = lfps(i).stats.trialtype.eyesfree_stationary.spectrum.psd;
            end
            figure; hold on;
            shadedErrorBar(freq,nanmean(eyesfree_mobile),nanstd(eyesfree_mobile),'lineprops','r');
            shadedErrorBar(freq,nanmean(eyesfree_stationary),nanstd(eyesfree_stationary),'lineprops','k');
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
            set(gca, 'TickDir', 'out','ylim',[0 300] ,'yTick', [0 300], 'FontSize',18);
            title('Eyes free vs mobile and stationary')
        case 'PSD_eyes_fixed'
            figure; hold on;
            f1 = lfp.stats.trialtype.eyesfixed_mobile.spectrum.freq;
            psd1 = lfp.stats.trialtype.eyesfixed_mobile.spectrum.psd;
            f2 = lfp.stats.trialtype.eyesfixed_stationary.spectrum.freq;
            psd2 = lfp.stats.trialtype.eyesfixed_stationary.spectrum.psd;
            
            hold on; subplot(1,2,1); plot(f1,psd1,'b'); plot(f2,psd2,'c');
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
            subplot(1,2,2); plot(f1,psd2./psd1);
            axis([1 50 0 1.5]); hline(1,'k'); xlabel('Frequency (Hz)'); ylabel('Power spectral density ratio');
            title('Eye fixed vs mobile and stationary')
        case 'PSD_eyes_fixed_all'
            freq = lfps(1).stats.trialtype.eyesfree_mobile.spectrum.freq;
            for i = 1:length(lfps)
                eyesfixed_mobile(i,:) = lfps(i).stats.trialtype.eyesfixed_mobile.spectrum.psd;
                eyesfixed_stationary(i,:) = lfps(i).stats.trialtype.eyesfixed_stationary.spectrum.psd;
            end
            figure; hold on;
            shadedErrorBar(freq,nanmean(eyesfixed_mobile),nanstd(eyesfixed_mobile),'lineprops','m');
            shadedErrorBar(freq,nanmean(eyesfixed_stationary),nanstd(eyesfixed_stationary),'lineprops','b');
            set(gca, 'TickDir', 'out','ylim',[0 300] ,'yTick', [0 300], 'FontSize',18);
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
            title('Eye fixed vs mobile and stationary')
        case 'PSD_densities'
            l_lim = 13 ; h_lim = 20;             % theta 6-10, beta 13-20
            nlfps = 48 ; % length(lfps); %48
            figure; hold on;
            f1 = lfps(1).stats.trialtype.density(1).spectrum.freq;
            for i=1:nlfps, psd1(i,:) = lfps(i).stats.trialtype.density(1).spectrum.psd; end
            f2 = lfps(1).stats.trialtype.density(2).spectrum.freq;
            for i=1:nlfps, psd2(i,:) = lfps(i).stats.trialtype.density(2).spectrum.psd;  end
            subplot(1,2,1); hold on;
            fg1 = shadedErrorBar(f1,mean(psd1),std(psd1),'lineprops','b'); fg2 = shadedErrorBar(f2,mean(psd2),std(psd2),'lineprops','r');
            set(fg1.mainLine, 'LineWidth', 1);  set(fg1.edge, 'LineStyle', 'none'); set(fg2.mainLine, 'LineWidth', 1);  set(fg2.edge, 'LineStyle', 'none');
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
            set(gca, 'TickDir', 'out', 'FontSize',18); ylim([0 100]);
            subplot(1,2,2); fg3 = shadedErrorBar(f1,mean(psd2./psd1),std(psd2./psd1)); axis([1 50 0 1.5]); hline(1,'k');
            set(fg3.mainLine, 'LineWidth', 1); set(gca, 'TickDir', 'out', 'FontSize',18);
            xlabel('Frequency (Hz)'); ylabel('Power spectral density ratio'); ylim([0.5 1.5]);
            f1_band = f1(f1>l_lim & f1<h_lim); f2_band = f2(f2>l_lim & f2<h_lim);
            for i=1:nlfps, psd1_band(i,:) = mean(psd1(i,(f1>l_lim & f1<h_lim))); end
            for i=1:nlfps, psd2_band(i,:) = mean(psd2(i,(f2>l_lim & f2<h_lim))); end
            figure;subplot(1,2,1); hold on;
            errorbar(1,mean(psd1_band),std(psd1_band)/sqrt(nlfps),'b','LineWidth',1); % plot(1,psd1_theta,'.k');
            errorbar(2,mean(psd2_band),std(psd2_band)/sqrt(nlfps),'r','LineWidth',1); %  plot(2,psd2_theta,'.k');
            ymin = floor(min([min(psd2_band) min(psd2_band)]));
            ymax=(ceil(max([max(psd2_band) max(psd2_band)])));
            set(gca,'xlim', [0 3], 'xTick',[],'yLim',[round(mean(psd1_band)-10) round(mean(psd1_band)+10)], 'yTick',[round(mean(psd1_band)-10) round(mean(psd1_band)+10)],'TickDir', 'out', 'FontSize',18);
            ylabel('Power spectral density (\muV^2/Hz)');
            subplot(1,2,2); hold on; plot(psd1_band,psd2_band, '.k', 'MarkerSize',18); plot(0:ymax,0:ymax, '--k');
            set(gca,'TickDir', 'out', 'FontSize',22, 'xTick', [ymin ymax],'yTick', [ymin ymax]);
            xlabel('PSD low density'); ylabel('PSD high density');
            axis([ymin ymax ymin ymax]);
            [h,p] = ttest(psd1_band,psd2_band)
            
        case 'PSD_densities_array'
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx); nlfps = length(lfps); %48;
            figure; hold on;
            f1 = lfps(1).stats.trialtype.density(1).spectrum.freq;
            f2 = lfps(1).stats.trialtype.density(2).spectrum.freq;
            for i=1:nlfps % 48 % 48 for Schro
                psd1 = lfps(i).stats.trialtype.density(1).spectrum.psd;
                psd2 = lfps(i).stats.trialtype.density(2).spectrum.psd;
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                plot(f1,psd1,'b'); axis([2 50 0 250]); axis off; box off;
                plot(f2,psd2,'r'); axis([2 50 0 250]); axis off; box off;
                vline(15);
                xlim([2 50]); ylim([0 75]);
            end
        case 'PSD_accuracy'
            l_lim = 13 ; h_lim = 20;             % theta 6-10, beta 13-20
            nlfps = 48 % length(lfps); % 48
            figure; hold on;
            f1 = lfps(1).stats.trialtype.reward(1).spectrum.freq;
            for i=1:nlfps, psd1(i,:) = lfps(i).stats.trialtype.reward(1).spectrum.psd; end % unrewarded
            f2 = lfps(1).stats.trialtype.reward(2).spectrum.freq;
            for i=1:nlfps, psd2(i,:) = lfps(i).stats.trialtype.reward(2).spectrum.psd; end % rewarded
            subplot(1,2,1); hold on;
            fg1 = shadedErrorBar(f1,mean(psd1),std(psd1),'lineprops','r'); fg2 = shadedErrorBar(f2,mean(psd2),std(psd2),'lineprops','g');
            set(fg1.mainLine, 'LineWidth', 2);  set(fg1.edge, 'LineStyle', 'none'); set(fg2.mainLine, 'LineWidth', 2);  set(fg2.edge, 'LineStyle', 'none');
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
            set(gca, 'TickDir', 'out', 'FontSize',18);                                                                        ylim([0 100]);
            subplot(1,2,2); fg3 = shadedErrorBar(f1,mean(psd2./psd1),std(psd2./psd1)); axis([1 50 0 1.5]); hline(1,'k');
            set(fg3.mainLine, 'LineWidth', 1); set(gca, 'TickDir', 'out', 'FontSize',18); ylim([0.5 1.5]);
            xlabel('Frequency (Hz)'); ylabel('Power spectral density ratio');
            f1_band = f1(f1>l_lim & f1<h_lim); f2_band = f2(f2>l_lim & f2<h_lim);
            for i=1:nlfps, psd1_band(i,:) = mean(psd1(i,(f1>l_lim & f1<h_lim))); end
            for i=1:nlfps, psd2_band(i,:) = mean(psd2(i,(f2>l_lim & f2<h_lim))); end
            figure;subplot(1,2,1); hold on;
            errorbar(1,mean(psd1_band),std(psd1_band)/sqrt(nlfps),'r','LineWidth',1);
            errorbar(2,mean(psd2_band),std(psd2_band)/sqrt(nlfps),'g','LineWidth',1);
            ymin = floor(min([min(psd2_band) min(psd2_band)]));
            ymax=(ceil(max([max(psd2_band) max(psd2_band)])));
            set(gca,'xlim', [0 3], 'xTick',[],'yLim',[round(mean(psd1_band)-10) round(mean(psd1_band)+10)], 'yTick',[round(mean(psd1_band)-10) round(mean(psd1_band)+10)],'TickDir', 'out', 'FontSize',18);
            ylabel('Power spectral density (\muV^2/Hz)');
            subplot(1,2,2); hold on; plot(psd1_band,psd2_band, '.k', 'MarkerSize',18); plot(0:ymax,0:ymax, '--k');
            set(gca,'TickDir', 'out', 'FontSize',22, 'xTick', [0 ymax],'yTick', [0 ymax]);
            xlabel('PSD unrewarded'); ylabel('PSD rewarded');
            axis([ymin ymax ymin ymax]);
            [h,p] = ttest(psd1_band,psd2_band)
            
        case 'PSD_accuracy_array'
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx); nlfps = length(lfps); %48;
            figure; hold on;
            f1 = lfps(1).stats.trialtype.reward(1).spectrum.freq;
            f2 = lfps(1).stats.trialtype.reward(2).spectrum.freq;
            for i=1:nlfps % 48 % for Schroex
                psd1 = lfps(i).stats.trialtype.reward(1).spectrum.psd;
                psd2 = lfps(i).stats.trialtype.reward(2).spectrum.psd;
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                plot(f1,psd1,'r'); axis([2 50 0 250]); axis off; box off;
                plot(f2,psd2,'g'); axis([2 50 0 250]); axis off; box off;
                xlim([2 50]); ylim([0 50]); vline(15);
            end
            
        case 'freq_speed_v_w'
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx); nlfps = length(lfps);
            v = lfps(1).stats.trialtype.all.continuous.v.thetafreq.tuning.stim.mu;
            w = lfps(1).stats.trialtype.all.continuous.w.thetafreq.tuning.stim.mu;
            if strcmp(electrode,'utah2x48'), nlfps = nlfps/2; end
            for i=1:nlfps
                theta_v(i,:) = lfps(i).stats.trialtype.all.continuous.v.thetafreq.tuning.rate.mu;
                beta_v(i,:) = lfps(i).stats.trialtype.all.continuous.v.betafreq.tuning.rate.mu;
                theta_w(i,:) = lfps(i).stats.trialtype.all.continuous.w.thetafreq.tuning.rate.mu;
                beta_w(i,:) = lfps(i).stats.trialtype.all.continuous.w.betafreq.tuning.rate.mu;
            end
            % theta
            figure; hold on;
            subplot(1,2,1); hold on; plot(w,theta_w,'.k'); plot(w, mean(theta_w),'ob','MarkerFaceColor','b');
            xlabel('Angular velocity (deg/s)'); ylabel('\theta - frequency (Hz)');
            w2 = repmat(w,[nlfps,1]); w2 = w2(:); theta_w2 = theta_w(:); pos = (w2>0); neg = (w2<0);
            [b,a,bint,aint] = regress_perp(w2(pos),theta_w2(pos));
            x = linspace(0,75,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','b');
            [b,a,bint,aint] = regress_perp(w2(neg),theta_w2(neg));
            x = linspace(-75,0,100); y = a + b*x; erry = abs([aint(2) + bint(1)*x ; aint(1) + bint(2)*x] - y); shadedErrorBar(x,y,erry,'lineprops','b');
            subplot(1,2,2); hold on; plot(v,theta_v,'.k'); plot(v, mean(theta_v),'ob','MarkerFaceColor','b');
            xlabel('Linear velocity (cm/s)'); ylabel('\theta - frequency (Hz)');
            v2 = repmat(v,[nlfps,1]);theta_v = theta_v(v2>0); v2 = v2(v2>0);
            [b,a,bint,aint] = regress_perp(v2(:),theta_v(:));
            x = linspace(0,200,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x ; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','b');
            set(gca, 'xlim', [0 200]);
            % beta
            figure; hold on;
            subplot(1,2,1); hold on; plot(w,beta_w,'.k'); plot(w, mean(beta_w),'or','MarkerFaceColor','r');
            xlabel('Angular velocity (deg/s)'); ylabel('\beta - frequency (Hz)');
            w2 = repmat(w,[nlfps,1]); w2 = w2(:); beta_w2 = beta_w(:); pos = (w2>0); neg = (w2<0);
            [b,a,bint,aint] = regress_perp(w2(pos),beta_w2(pos));
            x = linspace(0,75,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','r');
            [b,a,bint,aint] = regress_perp(w2(neg),beta_w2(neg));
            x = linspace(-75,0,100); y = a + b*x; erry = abs([aint(2) + bint(1)*x ; aint(1) + bint(2)*x] - y); shadedErrorBar(x,y,erry,'lineprops','r');
            subplot(1,2,2); hold on; plot(v,beta_v,'.k'); plot(v, mean(beta_v),'or','MarkerFaceColor','r');
            xlabel('Linear velocity (cm/s)'); ylabel('\beta - frequency (Hz)');
            v2 = repmat(v,[nlfps,1]);beta_v = beta_v(v2>0); v2 = v2(v2>0);
            [b,a,bint,aint] = regress_perp(v2(:),beta_v(:));
            x = linspace(0,200,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x ; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','r');
            set(gca, 'xlim', [0 200]);
            
        case 'freq_speed_eye'
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx); nlfps = length(lfps);
            h_eye = lfps(1).stats.trialtype.all.continuous.heyevel.thetafreq.tuning.stim.mu;
            v_eye = lfps(1).stats.trialtype.all.continuous.veyevel.thetafreq.tuning.stim.mu;
            if strcmp(electrode,'utah2x48'), nlfps = nlfps/2; end
            for i=1:nlfps
                theta_h(i,:) = lfps(i).stats.trialtype.all.continuous.heyevel.thetafreq.tuning.rate.mu;
                beta_h(i,:) = lfps(i).stats.trialtype.all.continuous.heyevel.betafreq.tuning.rate.mu;
                theta_v(i,:) = lfps(i).stats.trialtype.all.continuous.veyevel.thetafreq.tuning.rate.mu;
                beta_v(i,:) = lfps(i).stats.trialtype.all.continuous.veyevel.betafreq.tuning.rate.mu;
            end
            %theta
            figure; hold on; title('theta')
            subplot(1,2,1); hold on; plot(v_eye,theta_v,'.k'); plot(v_eye, nanmean(theta_v),'ob','MarkerFaceColor','b');
            xlabel('Vertical eye velocity (deg/s)'); ylabel('\theta - frequency (Hz)'); vline(0, '-k');
            v_eye2 = repmat(v_eye,[nlfps,1]);
            %             [b,a,bint,aint] = regress_perp(v_eye2(:),theta_v(:));
            %             x = linspace(0,30,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','b');
            subplot(1,2,2); hold on; plot(h_eye,theta_h,'.k'); plot(h_eye, mean(theta_h),'ob','MarkerFaceColor','b');
            xlabel('Horizontal eye velocity (cm/s)'); ylabel('\theta - frequency (Hz)'); vline(0, '-k');
            %             h_eye2 = repmat(h_eye,[nlfps,1]); h_eye2 = h_eye2(:);
            %             [b,a,bint,aint] = regress_perp(h_eye2(:),theta_h(:));
            %             x = linspace(0,30,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x ; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','b');
            
            % beta
            figure; hold on; title('beta')
            subplot(1,2,1); hold on; plot(v_eye,beta_v,'.k'); plot(v_eye, mean(beta_v),'or','MarkerFaceColor','r');
            xlabel('Vertical eye velocity (deg/s)'); ylabel('\beta - frequency (Hz)'); vline(0, '-k');
            v_eye2 = repmat(v_eye,[nlfps,1]);
            %             [b,a,bint,aint] = regress_perp(v_eye2(:),beta_v(:));
            %             x = linspace(0,30,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','r');
            subplot(1,2,2); hold on; plot(h_eye,beta_h,'.k'); plot(h_eye, mean(beta_h),'or','MarkerFaceColor','r');
            xlabel('Horizontal eye velocity (cm/s)'); ylabel('\beta - frequency (Hz)'); vline(0, '-k');
            %             h_eye2 = repmat(h_eye,[nlfps,1]); h_eye2 = h_eye2(:);
            %             [b,a,bint,aint] = regress_perp(h_eye2(:),beta_h(:));
            %             x = linspace(0,30,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x ; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','r');
            
        case 'reg_coeff'
            figure('Position',[680 690 356 408]); hold on; nlfps = length(lfps);
            nlfps = 48;
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx);
            for i = 1:nlfps
                theta_coeff(:,i) = lfps(i).stats.trialtype.all.continuous.vwhv.thetafreq.regr_coeff;
                theta_CI{i} = lfps(i).stats.trialtype.all.continuous.vwhv.thetafreq.regr_CI;
                beta_coeff(:,i) = lfps(i).stats.trialtype.all.continuous.vwhv.betafreq.regr_coeff;
                beta_CI{i} = lfps(i).stats.trialtype.all.continuous.vwhv.betafreq.regr_CI;
            end
            % theta
            coeff_mu_th = mean(theta_coeff,2); coeff_std = std(theta_coeff,[],2); str = {'v' 'w' 'h eye' 'v eye'}; coeff_sem=std(theta_coeff,[],2)/sqrt(nlfps);
            %plot(theta_coeff, 'o','MarkerSize',4);
            errorbar(1, coeff_mu_th(1),coeff_sem(1), 'MarkerSize',10,'Marker','.');
            errorbar(2, coeff_mu_th(2),coeff_sem(2), 'MarkerSize',10,'Marker','.');
            errorbar(3, coeff_mu_th(3),coeff_sem(3), 'MarkerSize',10,'Marker','.');
            errorbar(4, coeff_mu_th(4),coeff_sem(4), 'MarkerSize',10,'Marker','.');
            set(gca, 'xlim', [0.5 4.5],'xTickLabel',str,'TickDir', 'out', 'FontSize',22);
            ylabel('regression coefficient'); title('theta')
            % beta
            figure('Position',[680 690 356 408]); hold on;
            coeff_mu_be = mean(beta_coeff,2); coeff_std_be = std(beta_coeff,[],2); str = {'v' 'w' 'h eye' 'v eye'}; coeff_sem_be=std(beta_coeff,[],2)/sqrt(nlfps);
            %plot(beta_coeff, 'o','MarkerSize',4);
            errorbar(1, coeff_mu_be(1),coeff_sem_be(1), 'MarkerSize',10,'Marker','.');
            errorbar(2, coeff_mu_be(2),coeff_sem_be(2), 'MarkerSize',10,'Marker','.');
            errorbar(3, coeff_mu_be(3),coeff_sem_be(3), 'MarkerSize',10,'Marker','.');
            errorbar(4, coeff_mu_be(4),coeff_sem_be(4), 'MarkerSize',10,'Marker','.');
            set(gca, 'xlim', [0.5 4.5],'xTickLabel',str,'TickDir', 'out', 'FontSize',22);
            ylabel('regression coefficient'); title('beta')
            
    end
else
    nlfps = length(lfps);
    switch plot_type
        case 'PSD'
            f = lfps(1).stats.trialtype.all.spectrum.freq;
            for i=1:nlfps, psd(i,:) = lfps(i).stats.trialtype.all.spectrum.psd; end
            figure; shadedErrorBar(f,mean(psd),std(psd)/sqrt(nlfps));
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
        case 'PSDarray'
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx);
            figure; hold on;
            f = lfps(1).stats.trialtype.all.spectrum.freq;
            for i=1:nlfps
                psd = lfps(i).stats.trialtype.all.spectrum.psd;
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                plot(f,psd); axis([2 50 0 250]); axis off; box off;
            end
        case 'PSD_movement'
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx);
            if strcmp(electrode,'utah2x48')
                % electrodes 1-48
                figure; hold on;
                f1 = lfps(1).stats.trialtype.stationary.spectrum.freq;
                for i=1:nlfps/2, psd1(i,:) = lfps(i).stats.trialtype.stationary.spectrum.psd; end
                f2 = lfps(1).stats.trialtype.mobile.spectrum.freq;
                for i=1:nlfps/2, psd2(i,:) = lfps(i).stats.trialtype.mobile.spectrum.psd; end
                subplot(1,2,1); hold on;
                shadedErrorBar(f1,mean(psd1),std(psd1),'lineprops','b'); shadedErrorBar(f2,mean(psd2),std(psd2),'lineprops','r');
                xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
                subplot(1,2,2); shadedErrorBar(f1,mean(psd2./psd1),std(psd2./psd1)); axis([1 50 0 1.5]); hline(1,'k');
                xlabel('Frequency (Hz)'); ylabel('Power spectral density ratio');
                % electrodes 49-96
                figure; hold on;
                f1 = lfps(1).stats.trialtype.stationary.spectrum.freq;
                for i=1:nlfps/2, psd1(i,:) = lfps(i+nlfps/2).stats.trialtype.stationary.spectrum.psd; end
                f2 = lfps(1).stats.trialtype.mobile.spectrum.freq;
                for i=1:nlfps/2, psd2(i,:) = lfps(i+nlfps/2).stats.trialtype.mobile.spectrum.psd; end
                subplot(1,2,1); hold on;
                shadedErrorBar(f1,mean(psd1),std(psd1),'lineprops','b'); shadedErrorBar(f2,mean(psd2),std(psd2),'lineprops','r');
                xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
                subplot(1,2,2); shadedErrorBar(f1,mean(psd2./psd1),std(psd2./psd1)); axis([1 50 0 1.5]); hline(1,'k');
                xlabel('Frequency (Hz)'); ylabel('Power spectral density ratio');
            else
                figure; hold on;
                f1 = lfps(1).stats.trialtype.stationary.spectrum.freq;
                for i=1:nlfps, psd1(i,:) = lfps(i).stats.trialtype.stationary.spectrum.psd; end
                f2 = lfps(1).stats.trialtype.mobile.spectrum.freq;
                for i=1:nlfps, psd2(i,:) = lfps(i).stats.trialtype.mobile.spectrum.psd; end
                subplot(1,2,1); hold on;
                shadedErrorBar(f1,mean(psd1),std(psd1),'lineprops','b'); shadedErrorBar(f2,mean(psd2),std(psd2),'lineprops','r');
                xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
                subplot(1,2,2); shadedErrorBar(f1,mean(psd2./psd1),std(psd2./psd1)); axis([1 50 0 1.5]); hline(1,'k');
                xlabel('Frequency (Hz)'); ylabel('Power spectral density ratio');
            end
        case 'PSDarray_movement'
            [xloc,yloc] = map_utaharray([],electrode); 
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx);
            if strcmp(electrode,'utah2x48')
                figure; hold on;
                f1 = lfps(1).stats.trialtype.stationary.spectrum.freq;
                f2 = lfps(1).stats.trialtype.mobile.spectrum.freq;
                for i=1:nlfps
                    psd1 = lfps(i).stats.trialtype.stationary.spectrum.psd;
                    psd2 = lfps(i).stats.trialtype.mobile.spectrum.psd;
                    subplot(18,6,6*(xloc(i)-1) + yloc(i)); hold on;
                    plot(f1,psd1,'k'); plot(f2,psd2,'b'); axis([2 50 0 250]); axis off; box off;
                end
            else
                figure; hold on;
                f1 = lfps(1).stats.trialtype.stationary.spectrum.freq;
                f2 = lfps(1).stats.trialtype.mobile.spectrum.freq;
                for i=1:nlfps
                    psd1 = lfps(i).stats.trialtype.stationary.spectrum.psd;
                    psd2 = lfps(i).stats.trialtype.mobile.spectrum.psd;
                    subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                    plot(f1,psd1,'k'); plot(f2,psd2,'b'); axis([2 50 0 250]); axis off; box off;
                end
            end
        case 'ERP_targ'
            t = lfps(1).stats.trialtype.all.events.target.time;
            for i=1:nlfps, v_mu(i,:) = lfps(i).stats.trialtype.all.events.target.potential_mu; end
            figure; shadedErrorBar(t,mean(v_mu),std(v_mu)/sqrt(nlfps));
            xlim([-1 1]); hline(0,'k'); vline(0,'k'); xlabel('Time rel. to target onset (s)'); ylabel('Event-related potential (\muV)');
        case 'ERParray_targ'
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx);
            figure; hold on;
            t = lfps(1).stats.trialtype.all.events.target.time;
            for i=1:nlfps
                v_mu = lfps(i).stats.trialtype.all.events.target.potential_mu;
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                plot(t,v_mu,'k'); hline(0,'k'); vline(0,'k'); xlim([-1 1]); box on; set(gca,'xtick',[]); set(gca,'ytick',[]);
            end
        case 'ERP_move'
            t = lfps(1).stats.trialtype.all.events.move.time;
            for i=1:nlfps, v_mu(i,:) = lfps(i).stats.trialtype.all.events.move.potential_mu; end
            figure; shadedErrorBar(t,mean(v_mu),std(v_mu)/sqrt(nlfps));
            xlim([-1 1]); hline(0,'k'); vline(0,'k'); xlabel('Time rel. to movement onset (s)'); ylabel('Event-related potential (\muV)');
        case 'ERParray_move'
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx);
            figure; hold on;
            t = lfps(1).stats.trialtype.all.events.move.time;
            for i=1:nlfps
                v_mu = lfps(i).stats.trialtype.all.events.move.potential_mu;
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                plot(t,v_mu,'k'); hline(0,'k'); vline(0,'k'); xlim([-1 1]); box on; set(gca,'xtick',[]); set(gca,'ytick',[]);
            end
        case 'ERP_stop'
            t = lfps(1).stats.trialtype.all.events.stop.time;
            for i=1:nlfps, v_mu(i,:) = lfps(i).stats.trialtype.all.events.stop.potential_mu; end
            figure; shadedErrorBar(t,mean(v_mu),std(v_mu)/sqrt(nlfps));
            xlim([-1 1]); hline(0,'k'); vline(0,'k'); xlabel('Time rel. to end of movement (s)'); ylabel('Event-related potential (\muV)');
        case 'ERParray_stop'
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx);
            figure; hold on;
            t = lfps(1).stats.trialtype.all.events.stop.time;
            for i=1:nlfps
                v_mu = lfps(i).stats.trialtype.all.events.stop.potential_mu;
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                plot(t,v_mu,'k'); hline(0,'k'); vline(0,'k'); xlim([-1 1]); box on; set(gca,'xtick',[]); set(gca,'ytick',[]);
            end
        case 'ERP_rew'
            t = lfps(1).stats.trialtype.all.events.reward.time;
            for i=1:nlfps, v_mu(i,:) = lfps(i).stats.trialtype.all.events.reward.potential_mu; end
            figure; shadedErrorBar(t,mean(v_mu),std(v_mu)/sqrt(nlfps));
            xlim([-1 1]); hline(0,'k'); vline(0,'k'); xlabel('Time rel. to reward delivery (s)'); ylabel('Event-related potential (\muV)');
        case 'ERParray_rew'
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx);
            figure; hold on;
            t = lfps(1).stats.trialtype.all.events.reward.time;
            for i=1:nlfps
                v_mu = lfps(i).stats.trialtype.all.events.reward.potential_mu;
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                plot(t,v_mu,'k'); hline(0,'k'); vline(0,'k'); xlim([-1 1]); box on; set(gca,'xtick',[]); set(gca,'ytick',[]);
            end
        case 'freq_speed'
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx);
            v = lfps(1).stats.trialtype.all.continuous.v.thetafreq.tuning.stim.mu;
            w = lfps(1).stats.trialtype.all.continuous.w.thetafreq.tuning.stim.mu;
            if strcmp(electrode,'utah2x48'), nlfps = nlfps/2; end
            for i=1:nlfps
                theta_v(i,:) = lfps(i).stats.trialtype.all.continuous.v.thetafreq.tuning.rate.mu;
                beta_v(i,:) = lfps(i).stats.trialtype.all.continuous.v.betafreq.tuning.rate.mu;
                theta_w(i,:) = lfps(i).stats.trialtype.all.continuous.w.thetafreq.tuning.rate.mu;
                beta_w(i,:) = lfps(i).stats.trialtype.all.continuous.w.betafreq.tuning.rate.mu;
            end
            % theta
            figure; hold on;
            subplot(1,2,1); hold on; plot(w,theta_w,'.k'); plot(w, mean(theta_w),'ob','MarkerFaceColor','b');
            xlabel('Angular velocity (deg/s)'); ylabel('\theta - frequency (Hz)');
            w2 = repmat(w,[nlfps,1]); w2 = w2(:); theta_w2 = theta_w(:); pos = (w2>0); neg = (w2<0);
            [b,a,bint,aint] = regress_perp(w2(pos),theta_w2(pos));
            x = linspace(0,75,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','b');
            [b,a,bint,aint] = regress_perp(w2(neg),theta_w2(neg));
            x = linspace(-75,0,100); y = a + b*x; erry = abs([aint(2) + bint(1)*x ; aint(1) + bint(2)*x] - y); shadedErrorBar(x,y,erry,'lineprops','b');
            subplot(1,2,2); hold on; plot(v,theta_v,'.k'); plot(v, mean(theta_v),'ob','MarkerFaceColor','b');
            xlabel('Linear velocity (cm/s)'); ylabel('\theta - frequency (Hz)');
            v2 = repmat(v,[nlfps,1]); v2 = v2(:);
            [b,a,bint,aint] = regress_perp(v2(:),theta_v(:));
            x = linspace(0,200,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x ; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','b');
            % beta
            figure; hold on;
            subplot(1,2,1); hold on; plot(w,beta_w,'.k'); plot(w, mean(beta_w),'or','MarkerFaceColor','r');
            xlabel('Angular velocity (deg/s)'); ylabel('\beta - frequency (Hz)');
            w2 = repmat(w,[nlfps,1]); w2 = w2(:); beta_w2 = beta_w(:); pos = (w2>0); neg = (w2<0);
            [b,a,bint,aint] = regress_perp(w2(pos),beta_w2(pos));
            x = linspace(0,75,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','r');
            [b,a,bint,aint] = regress_perp(w2(neg),beta_w2(neg));
            x = linspace(-75,0,100); y = a + b*x; erry = abs([aint(2) + bint(1)*x ; aint(1) + bint(2)*x] - y); shadedErrorBar(x,y,erry,'lineprops','r');
            subplot(1,2,2); hold on; plot(v,beta_v,'.k'); plot(v, mean(beta_v),'or','MarkerFaceColor','r');
            xlabel('Linear velocity (cm/s)'); ylabel('\beta - frequency (Hz)');
            v2 = repmat(v,[nlfps,1]); v2 = v2(:);
            [b,a,bint,aint] = regress_perp(v2(:),beta_v(:));
            x = linspace(0,200,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x ; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','r');
        case 'coherence_dist'
            C = pop_lfps.stats.crosslfp.coher;
            f = pop_lfps.stats.crosslfp.freq;
            if length(electrode)>1 end
            switch electrode
                case 'utah96'
                    [xloc,yloc] = map_utaharray([],electrode); [~,electrode_id] = MapChannel2Electrode(electrode);
                    spatial_coher = []; spatial_dist = [];
                    ind2row = @(i,j) min(i,j) + (max(i,j)-1)*(max(i,j)-2)/2; % to read the output of "coherencyc_unequal_length_trials" function from Chronux
                    chan2elec = @(i,j) [electrode_id(i) electrode_id(j)];
                    for i=1:nlfps
                        for j=1:i-1
                            spatial_coher(end+1,:) = C(:,ind2row(i,j));
                            spatial_dist(end+1) = sqrt(diff(xloc(chan2elec(i,j)))^2 + diff(yloc(chan2elec(i,j)))^2); % in units of electrodes
                        end
                    end
                    spatial_distances = unique(spatial_dist);
                    spatial_coher_mu = cell2mat(arrayfun(@(x) mean(spatial_coher(spatial_dist==x,:)), spatial_distances, 'UniformOutput', false)');
                    spatial_coher_sem = cell2mat(arrayfun(@(x) std(spatial_coher(spatial_dist==x,:))/sqrt(sum(spatial_dist==x)), spatial_distances, 'UniformOutput', false)');
                    %%
                    figure; hold on; subplot(1,2,1); hold on;
                    cmap = gray(numel(spatial_distances));
                    for i=1:numel(spatial_distances), plot(f,spatial_coher_mu(i,:),'Color',cmap(i,:)); end
                    axis([2 80 0.65 1]); xlabel('Frequency (Hz)'); ylabel('Magnitude of coherence between LFPs'); set(gca,'Fontsize',10);
                    [~,theta] = min(abs(f - theta_peak)); [~,beta] = min(abs(f - beta_peak)); spatial_multiplier = prs.electrodespacing;
                    %
                    subplot(1,2,2); hold on; %errorbar(spatial_multiplier*spatial_distances,spatial_coher_mu(:,theta),spatial_coher_sem(:,theta),'ok','MarkerFaceColor','r','Capsize',0);
                    hold on; errorbar(spatial_multiplier*spatial_distances,spatial_coher_mu(:,beta),spatial_coher_sem(:,beta),'dk','Capsize',0);
                    spatialprs = fmincon(@(x) sum([spatial_coher_mu(:,beta)' - (1 - x(1)*(1 - exp(-(spatial_multiplier*spatial_distances)/x(2))))].^2),[1 1],[],[]);
                    plot(linspace(0,5,100),(1 - spatialprs(1)*(1 - exp(-(linspace(0,5,100))/spatialprs(2)))),'k');
                    axis([0 5 0.7 1]); xlabel('Distance between electrodes (mm)'); ylabel('Magnitude of coherence between LFPs');
                    %                     legend('\theta (8.5 Hz)','\beta (18.5 Hz)');
                    set(gca,'Fontsize',10);
                case 'utah2x48'
                    [xloc,yloc] = map_utaharray([],electrode); [~,electrode_id] = MapChannel2Electrode(electrode);
                    spatial_coher = []; spatial_dist = []; spatial_loc = [];
                    ind2row = @(i,j) min(i,j) + (max(i,j)-1)*(max(i,j)-2)/2; % to read the output of "coherencyc_unequal_length_trials" function from Chronux
                    chan2elec = @(i,j) [electrode_id(i) electrode_id(j)];
                    for i=1:nlfps
                        for j=1:i-1
                            spatial_coher(end+1,:) = C(:,ind2row(i,j));
                            spatial_dist(end+1) = sqrt(diff(xloc(chan2elec(i,j)))^2 + diff(yloc(chan2elec(i,j)))^2); % in units of electrodes
                            spatial_loc(end+1,:) = (chan2elec(i,j) <= 48); % true = 1:48, false = 49:96
                        end
                    end
                    set1 = prod(spatial_loc,2);
                    spatial_dist1 = spatial_dist; spatial_dist1(set1 == 0) = 20;
                    spatial_distances = unique(spatial_dist1);
                    spatial_coher_mu = cell2mat(arrayfun(@(x,y) mean(spatial_coher(spatial_dist1==x,:)), spatial_distances, 'UniformOutput', false)');
                    spatial_coher_sem = cell2mat(arrayfun(@(x,y) std(spatial_coher(spatial_dist1==x,:))/sqrt(sum(spatial_dist1==x)), spatial_distances, 'UniformOutput', false)');
                    %%
                    figure; hold on; subplot(1,2,1); hold on;
                    cmap = gray(numel(spatial_distances));
                    for i=1:numel(spatial_distances), plot(f,spatial_coher_mu(i,:),'Color',cmap(i,:)); end
                    axis([2 80 0.65 1]); xlabel('Frequency (Hz)'); ylabel('Magnitude of coherence between LFPs'); set(gca,'Fontsize',10);
                    [~,theta] = min(abs(f - theta_peak)); [~,beta] = min(abs(f - beta_peak)); spatial_multiplier = prs.electrodespacing;
                    %
                    subplot(1,2,2); hold on; %errorbar(spatial_multiplier*spatial_distances,spatial_coher_mu(:,theta),spatial_coher_sem(:,theta),'ok','MarkerFaceColor','r','Capsize',0);
                    hold on; errorbar(spatial_multiplier*spatial_distances,spatial_coher_mu(:,beta),spatial_coher_sem(:,beta),'sk','Capsize',0);
                    spatialprs = fmincon(@(x) sum([spatial_coher_mu(:,beta)' - (1 - x(1)*(1 - exp(-(spatial_multiplier*spatial_distances)/x(2))))].^2),[1 1],[],[]);
                    plot(linspace(0,5,100),(1 - spatialprs(1)*(1 - exp(-(linspace(0,5,100))/spatialprs(2)))),'k');
                    axis([0 5 0.7 1]); xlabel('Distance between electrodes (mm)'); ylabel('Magnitude of coherence between LFPs');
                    %                     legend('\theta (8.5 Hz)','\beta (18.5 Hz)');
                    set(gca,'Fontsize',10);
                    
                case 'linearprobe24'
                    
            end
        case 'phase_dist'
            phi = pop_lfps.stats.crosslfp.phase;
            f = pop_lfps.stats.crosslfp.freq;
            [xloc,yloc] = map_utaharray([],electrode); [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            switch electrode
                case 'utah96'
                    spatial_phasediff = zeros(nlfps,nlfps,numel(f)); spatial_dist = zeros(nlfps,nlfps);
                    ind2row = @(i,j) min(i,j) + (max(i,j)-1)*(max(i,j)-2)/2; % to read the output of "coherencyc_unequal_length_trials" function from Chronux
                    chan2elec = @(i,j) [electrode_id(i) electrode_id(j)];
                    for i=1:nlfps
                        for j=1:nlfps
                            if i==j, spatial_phasediff(i,j,:) = zeros(numel(f),1); % zero phase-lag with itself
                            elseif i>j, spatial_phasediff(i,j,:) = phi(:,ind2row(i,j));
                            elseif i<j, spatial_phasediff(i,j,:) = -phi(:,ind2row(i,j)); %phase x rel. to y = -phase y rel. to x
                            end
                            spatial_dist(i,j) = sqrt(diff(xloc(chan2elec(i,j)))^2 + diff(yloc(chan2elec(i,j)))^2);
                        end
                    end
                    %% theta phase map
                    %             [~,theta] = min(abs(f - theta_peak));
                    %% beta phase map
                    [~,beta] = min(abs(f - beta_peak));
                    phasediffs = mean(squeeze(spatial_phasediff(:,:,beta)),2);
                    [phasediffs_sorted,phaseorder] = sort(phasediffs);
                    electrode_id_sorted = electrode_id(phaseorder);
                    cmap = cool(nlfps);
                    figure; hold on;
                    subplot(1,2,1); hold on;
                    for i=1:nlfps
                        plot(f,(180/pi)*squeeze(spatial_phasediff(phaseorder(1),phaseorder(i),:)),'Color',cmap(i,:)); % plot leader vs everyone else
                    end
                    axis([1 80 -50 50]); hline(0,'k'); xlabel('Frequency (Hz)'); ylabel('Phase of coherence between LFPs (deg)');
                    subplot(1,2,2); hold on;
                    zloc = nan(max(xloc),max(yloc));
                    for i = 1:nlfps
                        zloc(xloc(electrode_id_sorted(i)),yloc(electrode_id_sorted(i))) = i;
                        plot(xloc(electrode_id_sorted(i)),yloc(electrode_id_sorted(i)),'o','Color',cmap(i,:),'MarkerFaceColor',cmap(i,:));
                    end
                    % fill in the edges of the array (for smoothing)
                    zloc(1,1) = 0.5*(zloc(1,2) + zloc(2,1)); zloc(1,end) = 0.5*(zloc(1,end-1) + zloc(2,end));
                    zloc(end,1) = 0.5*(zloc(end-1,1) + zloc(end,2)); zloc(end,end) = 0.5*(zloc(end,end-1) + zloc(end-1,end));
                    axis([0 11 0 11]); axis off; colormap(cool); colorbar;
                    maxtimelag = ((phasediffs_sorted(end) - phasediffs_sorted(1))/(2*pi))*(1/beta_peak)*1e3;
                    colorbar('Ticks',[0,1],'TickLabels',{[num2str(0) ' ms'],[num2str(round(maxtimelag*10)/10) ' ms']},'Fontsize',14);
                    %             DrawPhaseArrows([xloc yloc],electrode_id_sorted);
                    figure; imagesc(imresize(zloc,10)); colormap(cool);
                    %% velocity
                    spatial_phasediff_beta = squeeze(spatial_phasediff(:,:,beta)); spatial_phasediff_beta = spatial_phasediff_beta(:);
                    spatial_dists = unique(spatial_dist);
                    for i=2:numel(spatial_dists)
                        median_phasediff_beta(i) = median(abs(spatial_phasediff_beta(spatial_dist(:)==spatial_dists(i))));
                        sem_phasediff_beta(i) = 1.2533*std(abs(spatial_phasediff_beta(spatial_dist(:)==spatial_dists(i))))/sqrt(sum(spatial_dist(:)==spatial_dists(i)));
                        [F,X] = ecdf(abs(spatial_phasediff_beta(spatial_dist(:)==spatial_dists(i))));
                        [X,indx] = unique(X); F = F(indx);
                        ecdf_phasediff_beta(i,:) = interp1(X,F,linspace(0,0.5,101));
                    end
                    figure; surf(spatial_dists',linspace(0,0.5,101)',ecdf_phasediff_beta'); colormap(goodcolormap('bwr',100)); set(gca,'YDir','reverse')
                    hold on; plot(spatial_dists,median_phasediff_beta,'dk'); axis([0 9.5 0 0.2906]); % 0.2325 rad @ 18.5 Hz => 2ms
                case 'utah2x48'
                    [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
                    spatial_phasediff = zeros(nlfps,nlfps,numel(f)); spatial_dist = zeros(nlfps,nlfps);
                    ind2row = @(i,j) min(i,j) + (max(i,j)-1)*(max(i,j)-2)/2; % to read the output of "coherencyc_unequal_length_trials" function from Chronux
                    chan2elec = @(i,j) [electrode_id(i) electrode_id(j)];
                    for i=1:nlfps
                        for j=1:nlfps
                            if i==j, spatial_phasediff(i,j,:) = zeros(numel(f),1); % zero phase-lag with itself
                            elseif i>j, spatial_phasediff(i,j,:) = phi(:,ind2row(i,j));
                            elseif i<j, spatial_phasediff(i,j,:) = -phi(:,ind2row(i,j)); %phase x rel. to y = -phase y rel. to x
                            end
                            spatial_dist(i,j) = sqrt(diff(xloc(chan2elec(i,j)))^2 + diff(yloc(chan2elec(i,j)))^2);
                        end
                    end
                    spatial_dist = spatial_dist(reorderindx,reorderindx); spatial_dist = spatial_dist(1:nlfps/2,1:nlfps/2);
                    spatial_phasediff = spatial_phasediff(reorderindx,reorderindx,:); spatial_phasediff = spatial_phasediff(1:nlfps/2,1:nlfps/2,:);
                    electrode_id = electrode_id(reorderindx);
                    %% theta phase map
                    %             [~,theta] = min(abs(f - theta_peak));
                    %% beta phase map
                    [~,beta] = min(abs(f - beta_peak));
                    phasediffs = mean(squeeze(spatial_phasediff(:,:,beta)),2);
                    [phasediffs_sorted,phaseorder] = sort(phasediffs);
                    electrode_id_sorted = electrode_id(phaseorder);
                    cmap = cool(nlfps/2);
                    figure; hold on;
                    subplot(1,2,1); hold on;
                    for i=1:nlfps/2
                        plot(f,(180/pi)*squeeze(spatial_phasediff(phaseorder(1),phaseorder(i),:)),'Color',cmap(i,:)); % plot leader vs everyone else
                    end
                    axis([1 80 -50 50]); hline(0,'k'); xlabel('Frequency (Hz)'); ylabel('Phase of coherence between LFPs (deg)');
                    subplot(1,2,2); hold on;
                    zloc = nan(max(xloc(1:nlfps/2)),max(yloc(1:nlfps/2)));
                    for i = 1:nlfps/2
                        zloc(xloc(electrode_id_sorted(i)),yloc(electrode_id_sorted(i))) = i;
                        plot(xloc(electrode_id_sorted(i)),yloc(electrode_id_sorted(i)),'o','Color',cmap(i,:),'MarkerFaceColor',cmap(i,:));
                    end
                    % fill in the edges of the array (for smoothing utah96)
                    %                     zloc(1,1) = 0.5*(zloc(1,2) + zloc(2,1)); zloc(1,end) = 0.5*(zloc(1,end-1) + zloc(2,end));
                    %                     zloc(end,1) = 0.5*(zloc(end-1,1) + zloc(end,2)); zloc(end,end) = 0.5*(zloc(end,end-1) + zloc(end-1,end));
                    axis([0 11 0 11]); axis off; colormap(cool); colorbar;
                    maxtimelag = ((phasediffs_sorted(end) - phasediffs_sorted(1))/(2*pi))*(1/beta_peak)*1e3;
                    colorbar('Ticks',[0,1],'TickLabels',{[num2str(0) ' ms'],[num2str(round(maxtimelag*10)/10) ' ms']},'Fontsize',14);
                    %             DrawPhaseArrows([xloc yloc],electrode_id_sorted);
                    figure; imagesc(imresize(zloc,10)); colormap(cool);
                    %% velocity
                    spatial_phasediff_beta = squeeze(spatial_phasediff(:,:,beta)); spatial_phasediff_beta = spatial_phasediff_beta(:);
                    spatial_dists = unique(spatial_dist);
                    for i=2:numel(spatial_dists)
                        median_phasediff_beta(i) = mean(abs(spatial_phasediff_beta(spatial_dist(:)==spatial_dists(i))));
                        sem_phasediff_beta(i) = 1.2533*std(abs(spatial_phasediff_beta(spatial_dist(:)==spatial_dists(i))))/sqrt(sum(spatial_dist(:)==spatial_dists(i)));
                        [F,X] = ecdf(abs(spatial_phasediff_beta(spatial_dist(:)==spatial_dists(i))));
                        [X,indx] = unique(X); F = F(indx);
                        ecdf_phasediff_beta(i,:) = interp1(X,F,linspace(0,0.5,101));
                    end
                    figure; surf(spatial_dists',linspace(0,0.5,101)',ecdf_phasediff_beta'); colormap(goodcolormap('bwr',100)); set(gca,'YDir','reverse')
                    hold on; plot(spatial_dists,median_phasediff_beta,'sk'); axis([0 9.5 0 0.31]); % 0.2325 rad @ 18.5 Hz => 2ms
            end
            
        case 'sim_coherence_dist_all'
            % MST
            dist_mst = pop_lfps.stats.trialtype.all.MST.dist; coher_mst = pop_lfps.stats.trialtype.all.MST.coherByElectrode; phase_mst =  pop_lfps.stats.trialtype.all.MST.phaseByDist; freq =  pop_lfps.stats.trialtype.all.crosslfp.freq;
            %plot coher
            cmap = jet(24);
            figure; hold on; for k=1:24, plot(freq,coher_mst(:,k),'Color',cmap(k,:)); end
            set(gca,'xlim',[2 50], 'ylim', [0.9 1], 'TickDir', 'out', 'FontSize', 20); box off
            title('Coherence MST'); xlabel('frequency');
            %plot phase
            figure; hold on; for k=1:24, plot(freq,phase_mst(:,k),'Color',cmap(k,:)); end
            set(gca,'xlim',[2 50], 'ylim', [-0.2 0.2], 'TickDir', 'out', 'FontSize', 20); box off
            title('Phase MST');
            % plot across distance  (plot for diff frequencies)
            figure; plot(dist_mst,nanmean(coher_mst(6:12,:))); hold on;
            set(gca,'xlim',[1 24], 'ylim', [0.8 1],'xTick',[1 23], 'TickDir', 'out', 'FontSize', 20); box off
            title('Coherence across distance 6-12 Hz MST'); xlabel('electrode distance'); ylabel('coherence')
            
            %                 % distance-coherence
            %                 spatial_coher = pop_lfps.stats.crosslfp.spatial_coher;
            %                 figure; hold on; title('spatial coherence MST')
            %                 for i = 2:40
            %                     plot(squeeze(nanmean(spatial_coher(i,1:24,:))))
            %                 end
            
            % PPC
            dist_ppc =  pop_lfps.stats.trialtype.all.PPC.dist; coher_ppc =  pop_lfps.stats.trialtype.all.PPC.coher; phase_ppc = pop_lfps.stats.trialtype.all.PPC.phase; freq =  pop_lfps.stats.trialtype.all.stats.crosslfp.freq;
            %plot coher
            cmap = jet(49);
            figure; hold on; for k=1:49, plot(freq,coher_ppc(:,k),'Color',cmap(k,:)); end
            set(gca,'xlim',[2 50], 'ylim', [0.75 1], 'TickDir', 'out', 'FontSize', 20); box off
            title('Coherence PPC'); xlabel('frequency'); ylabel('coherence'); 
            %plot phase
            figure; hold on; for k=1:49, plot(freq,phase_ppc(:,k),'Color',cmap(k,:)); end
            set(gca,'xlim',[2 50], 'ylim', [-0.4 0.4], 'TickDir', 'out', 'FontSize', 20); box off
            title('Phase PPC'); xlabel('frequency'); ylabel('phase'); 
            % plot across distance  (plot for diff frequencies)
            figure; plot(dist_ppc,nanmean(coher_ppc(6:12,:))); hold on;
            set(gca,'xlim',[1 12], 'ylim', [0.8 0.9],'xTick',[1 11], 'TickDir', 'out', 'FontSize', 20); box off
            title('Coherence across distance 6-12 Hz PPC'); xlabel('electrodes'); ylabel('coherence')
             
             case 'sim_coherence_dist_rew'
            % MST
            dist_mst = pop_lfps.stats.trialtype.reward.MST.dist; coher_mst = pop_lfps.stats.trialtype.reward.MST.coherByDist; phase_mst = pop_lfps.stats.trialtype.reward.MST.phaseByDist; freq = pop_lfps.stats.trialtype.reward.crosslfp.freq;
            %plot coher
            cmap = jet(24);
            figure; hold on; for k=1:24, plot(freq,coher_mst(:,k),'Color',cmap(k,:)); end
            set(gca,'xlim',[2 50], 'ylim', [0.75 1], 'TickDir', 'out', 'FontSize', 20); box off
            title('Coherence rew MST'); xlabel('frequency'); ylabel('coherence');
            %plot phase
            figure; hold on; for k=1:24, plot(freq,phase_mst(:,k),'Color',cmap(k,:)); end
            set(gca,'xlim',[2 50], 'ylim', [-0.5 0.2], 'TickDir', 'out', 'FontSize', 20); box off
            title('Phase rew MST'); xlabel('frequency'); ylabel('rad');
            % plot across distance  (plot for diff frequencies)
            figure; plot(dist_mst,nanmean(coher_mst(6:12,:))); hold on;
            set(gca,'xlim',[1 24], 'ylim', [0.8 1],'xTick',[1 23], 'TickDir', 'out', 'FontSize', 20); box off
            title('Coherence across distance 6-12 Hz rew MST'); xlabel('electrode distance'); ylabel('coherence')
            
            %                 % distance-coherence
            %                 spatial_coher = pop_lfps.stats.crosslfp.spatial_coher;
            %                 figure; hold on; title('spatial coherence MST')
            %                 for i = 2:40
            %                     plot(squeeze(nanmean(spatial_coher(i,1:24,:))))
            %                 end
            
            % PPC
            dist_ppc = pop_lfps.stats.trialtype.reward.PPC.dist; coher_ppc = pop_lfps.stats.trialtype.reward.PPC.coherByDist; phase_ppc = pop_lfps.stats.trialtype.reward.PPC.phaseByDist; freq = pop_lfps.stats.trialtype.reward.crosslfp.freq;
            %plot coher
            cmap = jet(49);
            figure; hold on; for k=1:49, plot(freq,coher_ppc(:,k),'Color',cmap(k,:)); end
            set(gca,'xlim',[2 50], 'ylim', [0.8 1], 'TickDir', 'out', 'FontSize', 20); box off
            title('Coherence rew PPC'); xlabel('frequency'); ylabel('coherence'); 
            %plot phase
            figure; hold on; for k=1:49, plot(freq,phase_ppc(:,k),'Color',cmap(k,:)); end
            set(gca,'xlim',[2 50], 'ylim', [-0.4 0.4], 'TickDir', 'out', 'FontSize', 20); box off
            title('Phase rew PPC'); xlabel('frequency'); ylabel('phase'); 
            % plot across distance  (plot for diff frequencies)
            figure; plot(dist_ppc,nanmean(coher_ppc(6:12,:))); hold on;
            set(gca,'xlim',[1 12], 'ylim', [0.8 0.95],'xTick',[1 11], 'TickDir', 'out', 'FontSize', 20); box off
            title('Coherence across distance 6-12 Hz rew PPC'); xlabel('electrodes'); ylabel('coherence')
            
             case 'sim_coherence_dist_density'
            % MST
            dist_mst =  pop_lfps.stats.trialtype.density.MST.dist; coher_mst = pop_lfps.stats.trialtype.density.MST.coherByDist; phase_mst = pop_lfps.stats.trialtype.density.MST.phaseByDist; freq = pop_lfps.stats.trialtype.density.crosslfp.freq;
            %plot coher
            cmap = jet(24);
            figure; hold on; for k=1:24, plot(freq,coher_mst(:,k),'Color',cmap(k,:)); end
            set(gca,'xlim',[2 50], 'ylim', [0.9 1], 'TickDir', 'out', 'FontSize', 20); box off
            title('Coherence MST (density)'); xlabel('frequency');
            %plot phase
            figure; hold on; for k=1:24, plot(freq,phase_mst(:,k),'Color',cmap(k,:)); end
            set(gca,'xlim',[2 50], 'ylim', [-0.2 0.2], 'TickDir', 'out', 'FontSize', 20); box off
            title('Phase MST (density)');
            % plot across distance  (plot for diff frequencies)
            figure; plot(dist_mst,nanmean(coher_mst(6:12,:))); hold on;
            set(gca,'xlim',[1 24], 'ylim', [0.8 1],'xTick',[1 23], 'TickDir', 'out', 'FontSize', 20); box off
            title('Coherence across distance 6-12 Hz MST (density)'); xlabel('electrode distance'); ylabel('coherence')
            
            %                 % distance-coherence
            %                 spatial_coher = pop_lfps.stats.crosslfp.spatial_coher;
            %                 figure; hold on; title('spatial coherence MST')
            %                 for i = 2:40
            %                     plot(squeeze(nanmean(spatial_coher(i,1:24,:))))
            %                 end
            
            % PPC
            dist_ppc = pop_lfps.stats.trialtype.density.PPC.dist; coher_ppc = pop_lfps.stats.trialtype.density.PPC.coher; phase_ppc = pop_lfps.stats.trialtype.density.PPC.phase; freq = pop_lfps.stats.trialtype.density.crosslfp.freq;
            %plot coher
            cmap = jet(49);
            figure; hold on; for k=1:49, plot(freq,coher_ppc(:,k),'Color',cmap(k,:)); end
            set(gca,'xlim',[2 50], 'ylim', [0.75 1], 'TickDir', 'out', 'FontSize', 20); box off
            title('Coherence PPC (density)'); xlabel('frequency'); ylabel('coherence'); 
            %plot phase
            figure; hold on; for k=1:49, plot(freq,phase_ppc(:,k),'Color',cmap(k,:)); end
            set(gca,'xlim',[2 50], 'ylim', [-0.4 0.4], 'TickDir', 'out', 'FontSize', 20); box off
            title('Phase PPC (density)'); xlabel('frequency'); ylabel('phase'); 
            % plot across distance  (plot for diff frequencies)
            figure; plot(dist_ppc,nanmean(coher_ppc(6:12,:))); hold on;
            set(gca,'xlim',[1 12], 'ylim', [0.8 0.9],'xTick',[1 11], 'TickDir', 'out', 'FontSize', 20); box off
            title('Coherence across distance 6-12 Hz PPC (density)'); xlabel('electrodes'); ylabel('coherence')
            
          

             case 'sim_coherence_dist_areas_all'
            % across areas  --  area 1 is MST, area 2 is PPC. 
             cmap = jet(24);
             coher12 = pop_lfps.stats.trialtype.all.crossarea.coher12; freq = pop_lfps.stats.trialtype.all.crosslfp.freq;
             figure; hold on; for k=1:24, plot(freq,coher12(:,k),'Color',cmap(k,:)); end  
             set(gca,'xlim',[2 50], 'ylim', [0.75 0.85], 'yTick', [0.75 0.8], 'TickDir', 'out', 'FontSize', 20); box off
             title('MST --> PPC')
             
             cmap = jet(96);
             coher21 = pop_lfps.stats.trialtype.all.crossarea.coher21; 
             figure; hold on; for k=1:96, plot(freq,coher21(:,k),'Color',cmap(k,:)); end 
             set(gca,'xlim',[2 50], 'ylim', [0.75 0.85], 'yTick', [0.75 0.8], 'TickDir', 'out', 'FontSize', 20); box off
             title('PPC --> MST')
             
             %phase
             cmap = jet(24);
             phase12 = pop_lfps.stats.trialtype.all.crossarea.phase12;
             figure; hold on; for k=1:24, plot(freq,phase12(:,k),'Color',cmap(k,:)); end
             set(gca,'xlim',[2 50], 'ylim', [-0.5 0.5], 'yTick', [-0.5 0.5], 'TickDir', 'out', 'FontSize', 20); box off
             title('MST --- <PPC>'); hline(0, '--k');
             
             cmap = jet(96);
             phase21 = pop_lfps.stats.trialtype.all.crossarea.phase21;
             figure; hold on; for k=1:96, plot(freq,phase21(:,k),'Color',cmap(k,:)); end
             set(gca,'xlim',[2 50], 'ylim', [-0.5 0.5], 'yTick', [-0.5 0.5], 'TickDir', 'out', 'FontSize', 20); box off
             title('PPC --- <MST>'); hline(0, '--k');
             
             % By electrode
             % MST
             cmap = jet(24);
             elec_mst = pop_lfps.stats.trialtype.all.MST.coherByElectrode;
             for k=1:24
                 plot(freq,elec_mst(:,k),'Color',cmap(k,:)); hold on; 
                 set(gca,'xlim',[2 50], 'ylim', [0.75 0.95], 'yTick', [0.75 0.95], 'TickDir', 'out','FontSize', 18); box off
                 xlabel('frequency'); ylabel('coherency')
             end
             
             % PPC
             elec_ppc = pop_lfps.stats.trialtype.all.PPC.coherByElectrode;
             [xloc,yloc] = map_utaharray([],'utah96');
             for i=1:96
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                 plot(freq,elec_ppc(:,k),'Color', 'k'); box off;
                 set(gca,'xlim',[2 50], 'ylim', [0.7 0.9], 'TickDir', 'out'); 
             end
             
             
             case 'sim_coherence_dist_areas_rew'
            % across areas  --  area 1 is MST, area 2 is PPC. 
               % across areas  --  area 1 is MST, area 2 is PPC. 
             cmap = jet(24);
             coher12 = pop_lfps.stats.trialtype.reward.crossarea.coher12; freq = pop_lfps.stats.trialtype.reward.crosslfp.freq;
             figure; hold on; for k=1:24, plot(freq,coher12(:,k),'Color',cmap(k,:)); end  
             set(gca,'xlim',[2 50], 'ylim', [0.75 0.85], 'yTick', [0.75 0.85], 'TickDir', 'out', 'FontSize', 20); box off
             title('MST --> PPC'); xlabel('frequency'); ylabel('coherence'); 
             
             cmap = jet(96);
             coher21 = pop_lfps.stats.trialtype.reward.crossarea.coher21; 
             figure; hold on; for k=1:96, plot(freq,coher21(:,k),'Color',cmap(k,:)); end 
             set(gca,'xlim',[2 50], 'ylim', [0.8 0.85], 'yTick', [0.8 0.85], 'TickDir', 'out', 'FontSize', 20); box off
             title('PPC --> MST'); xlabel('frequency'); ylabel('coherence');
             
             %phase
             cmap = jet(24);
             phase12 = pop_lfps.stats.trialtype.reward.crossarea.phase12;
             figure; hold on; for k=1:24, plot(freq,phase12(:,k),'Color',cmap(k,:)); end
             set(gca,'xlim',[2 50], 'ylim', [-0.5 0.5], 'yTick', [-0.5 0.5], 'TickDir', 'out', 'FontSize', 20); box off
             title('MST --- <PPC>'); hline(0, '--k'); xlabel('frequency'); ylabel('rad');
             
             cmap = jet(96);
             phase21 = pop_lfps.stats.trialtype.reward.crossarea.phase21;
             figure; hold on; for k=1:96, plot(freq,phase21(:,k),'Color',cmap(k,:)); end
             set(gca,'xlim',[2 50], 'ylim', [-0.5 0.5], 'yTick', [-0.5 0.5], 'TickDir', 'out', 'FontSize', 20); box off
             title('PPC --- <MST>'); hline(0, '--k'); xlabel('frequency'); ylabel('rad');
             
             % By electrode
             % MST
             cmap = jet(24); 
             elec_mst = pop_lfps.stats.trialtype.reward.MST.coherByElectrode;
             for k=1:24
                 plot(freq,elec_mst(:,k),'Color',cmap(k,:)); hold on; 
                 set(gca,'xlim',[2 50], 'ylim', [0.75 1], 'yTick', [0.75 1], 'TickDir', 'out','FontSize', 18); box off
                 xlabel('frequency'); ylabel('coherency'); title('coher by electrode MST');
             end
             
             % PPC
             elec_ppc = pop_lfps.stats.trialtype.reward.PPC.coherByElectrode;
             [xloc,yloc] = map_utaharray([],'utah96');
             for i=1:96
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                 plot(freq,elec_ppc(:,k),'Color', 'k'); box off;
                 set(gca,'xlim',[2 50], 'ylim', [0.85 0.95],'yTick', [0.85 0.95], 'TickDir', 'out');
             end
 
             
             case 'sim_coherence_dist_areas_density'
             % across areas  --  area 1 is MST, area 2 is PPC. 
             cmap = jet(24);
             coher12 = pop_lfps.stats.trialtype.density.crossarea.coher12; freq = pop_lfps.stats.trialtype.density.crosslfp.freq;
             figure; hold on; for k=1:24, plot(freq,coher12(:,k),'Color',cmap(k,:)); end  
             set(gca,'xlim',[2 50], 'ylim', [0.75 0.85], 'yTick', [0.75 0.8], 'TickDir', 'out', 'FontSize', 20); box off
             title('MST --> PPC')
             
             cmap = jet(96);
             coher21 = pop_lfps.stats.trialtype.density.crossarea.coher21; 
             figure; hold on; for k=1:96, plot(freq,coher21(:,k),'Color',cmap(k,:)); end 
             set(gca,'xlim',[2 50], 'ylim', [0.75 0.85], 'yTick', [0.75 0.8], 'TickDir', 'out', 'FontSize', 20); box off
             title('PPC --> MST')
             
             %phase
             cmap = jet(24);
             phase12 = pop_lfps.stats.trialtype.density.crossarea.phase12;
             figure; hold on; for k=1:24, plot(freq,phase12(:,k),'Color',cmap(k,:)); end
             set(gca,'xlim',[2 50], 'ylim', [-0.5 0.5], 'yTick', [-0.5 0.5], 'TickDir', 'out', 'FontSize', 20); box off
             title('MST --- <PPC>'); hline(0, '--k');
             
             cmap = jet(96);
             phase21 = pop_lfps.stats.trialtype.all.crossarea.phase21;
             figure; hold on; for k=1:96, plot(freq,phase21(:,k),'Color',cmap(k,:)); end
             set(gca,'xlim',[2 50], 'ylim', [-0.5 0.5], 'yTick', [-0.5 0.5], 'TickDir', 'out', 'FontSize', 20); box off
             title('PPC --- <MST>'); hline(0, '--k');
             
             % By electrode
             % MST
             cmap = jet(24);
             elec_mst = pop_lfps.stats.trialtype.all.MST.coherByElectrode;
             for k=1:24
                 plot(freq,elec_mst(:,k),'Color',cmap(k,:)); hold on; 
                 set(gca,'xlim',[2 50], 'ylim', [0.9 1], 'yTick', [0.75 0.95], 'TickDir', 'out','FontSize', 18); box off
                 xlabel('frequency'); ylabel('coherency')
             end
             
             % PPC
             elec_ppc = pop_lfps.stats.trialtype.all.PPC.coherByElectrode;
             [xloc,yloc] = map_utaharray([],'utah96');
             for i=1:96
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                 plot(freq,elec_ppc(:,k),'Color', 'k'); box off;
                 set(gca,'xlim',[2 50], 'ylim', [0.7 0.9], 'TickDir', 'out'); 
             end
    end
end