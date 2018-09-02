function PlotLFP(lfps,pop_lfps,electrode_id,plot_type,prs)

theta_peak = prs.lfp_theta_peak;
beta_peak = prs.lfp_beta_peak;
electrode = prs.electrode;

if electrode_id ~= 0
    lfp = lfps([lfps.electrode_id]==electrode_id);
    switch plot_type
        case 'PSD'
            f = lfp.stats.trialtype.all.spectrum.freq;
            psd = lfp.stats.trialtype.all.spectrum.psd;
            figure; plot(f,psd);
            xlim([2 50]); xlabel('Frequency (Hz)'); ylabel('Power spectral density (\muV^2/Hz)');
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
        case 'PSDarray_movement'
            [xloc,yloc] = map_utaharray([],electrode);
            [channel_id,electrode_id] = MapChannel2Electrode(electrode);
            [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
            lfps = lfps(reorderindx);
            figure; hold on;
            f1 = lfps(1).stats.trialtype.stationary.spectrum.freq;
            f2 = lfps(1).stats.trialtype.mobile.spectrum.freq;
            for i=1:nlfps
                psd1 = lfps(i).stats.trialtype.stationary.spectrum.psd;
                psd2 = lfps(i).stats.trialtype.mobile.spectrum.psd;
                subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                plot(f1,psd1,'k'); plot(f2,psd2,'b'); axis([2 50 0 250]); axis off; box off;
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
            v = lfps(1).stats.trialtype.all.continuous.v.thetafreq.tuning.stim.mu;
            w = lfps(1).stats.trialtype.all.continuous.w.thetafreq.tuning.stim.mu;
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
            subplot(1,2,1); hold on; plot(w,beta_w,'.k'); plot(w, mean(beta_w),'ob','MarkerFaceColor','b');
            xlabel('Angular velocity (deg/s)'); ylabel('\beta - frequency (Hz)');
            w2 = repmat(w,[nlfps,1]); w2 = w2(:); beta_w2 = beta_w(:); pos = (w2>0); neg = (w2<0);
            [b,a,bint,aint] = regress_perp(w2(pos),beta_w2(pos));
            x = linspace(0,75,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','b');
            [b,a,bint,aint] = regress_perp(w2(neg),beta_w2(neg));
            x = linspace(-75,0,100); y = a + b*x; erry = abs([aint(2) + bint(1)*x ; aint(1) + bint(2)*x] - y); shadedErrorBar(x,y,erry,'lineprops','b');
            subplot(1,2,2); hold on; plot(v,beta_v,'.k'); plot(v, mean(beta_v),'ob','MarkerFaceColor','b');
            xlabel('Linear velocity (cm/s)'); ylabel('\beta - frequency (Hz)');
            v2 = repmat(v,[nlfps,1]); v2 = v2(:);
            [b,a,bint,aint] = regress_perp(v2(:),beta_v(:));
            x = linspace(0,200,100); y = a + b*x; erry = abs([aint(2) + bint(2)*x ; aint(1) + bint(1)*x] - y); shadedErrorBar(x,y,erry,'lineprops','b');
        case 'coherence_dist'
            C = pop_lfps.stats.crosslfp.coher;
            f = pop_lfps.stats.crosslfp.freq;
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
                    subplot(1,2,2); hold on; errorbar(spatial_multiplier*spatial_distances,spatial_coher_mu(:,theta),spatial_coher_sem(:,theta),'ok','MarkerFaceColor','r','Capsize',0);
                    hold on; errorbar(spatial_multiplier*spatial_distances,spatial_coher_mu(:,beta),spatial_coher_sem(:,beta),'ok','MarkerFaceColor','b','Capsize',0);
                    axis([0 5 0.7 1]); xlabel('Distance between electrodes (mm)'); ylabel('Magnitude of coherence between LFPs');
                    legend('\theta (8.5 Hz)','\beta (18.5 Hz)'); set(gca,'Fontsize',10);
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
                    spatial_distances = unique(spatial_dist);
                    spatial_coher_mu = cell2mat(arrayfun(@(x,y) mean(spatial_coher(spatial_dist==x,:)), spatial_distances, 'UniformOutput', false)');
                    spatial_coher_sem = cell2mat(arrayfun(@(x,y) std(spatial_coher(spatial_dist==x,:))/sqrt(sum(spatial_dist==x)), spatial_distances, 'UniformOutput', false)');
                    %%
                    figure; hold on; subplot(1,2,1); hold on;
                    cmap = gray(numel(spatial_distances));
                    for i=1:numel(spatial_distances), plot(f,spatial_coher_mu(i,:),'Color',cmap(i,:)); end
                    axis([2 80 0.65 1]); xlabel('Frequency (Hz)'); ylabel('Magnitude of coherence between LFPs'); set(gca,'Fontsize',10);
                    [~,theta] = min(abs(f - theta_peak)); [~,beta] = min(abs(f - beta_peak)); spatial_multiplier = prs.electrodespacing;
                    %
                    subplot(1,2,2); hold on; errorbar(spatial_multiplier*spatial_distances,spatial_coher_mu(:,theta),spatial_coher_sem(:,theta),'ok','MarkerFaceColor','r','Capsize',0);
                    hold on; errorbar(spatial_multiplier*spatial_distances,spatial_coher_mu(:,beta),spatial_coher_sem(:,beta),'ok','MarkerFaceColor','b','Capsize',0);
                    axis([0 5 0.7 1]); xlabel('Distance between electrodes (mm)'); ylabel('Magnitude of coherence between LFPs');
                    legend('\theta (8.5 Hz)','\beta (18.5 Hz)'); set(gca,'Fontsize',10);
            end
        case 'phase_dist'
            phi = pop_lfps.stats.crosslfp.phase;
            f = pop_lfps.stats.crosslfp.freq;
            [xloc,yloc] = map_utaharray([],electrode); [~,electrode_id] = MapChannel2Electrode(electrode);
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
            [~,theta] = min(abs(f - theta_peak)); [~,beta] = min(abs(f - beta_peak));
            %% theta phase map
            phasediffs = mean(squeeze(spatial_phasediff(:,:,theta)),2);
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
            for i = 1:nlfps
                plot(xloc(electrode_id_sorted(i)),yloc(electrode_id_sorted(i)),'o','Color',cmap(i,:),'MarkerFaceColor',cmap(i,:));
            end
            axis([0 11 0 11]); axis off; colormap(cool); colorbar;
            maxtimelag = ((phasediffs_sorted(end) - phasediffs_sorted(1))/(2*pi))*(1/theta_peak)*1e3;
            colorbar('Ticks',[0,1],'TickLabels',{[num2str(0) ' ms'],[num2str(round(maxtimelag*10)/10) ' ms']},'Fontsize',14);
            %             DrawPhaseArrows([xloc yloc],electrode_id_sorted);
            %% beta phase map
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
            for i = 1:nlfps
                plot(xloc(electrode_id_sorted(i)),yloc(electrode_id_sorted(i)),'o','Color',cmap(i,:),'MarkerFaceColor',cmap(i,:));
            end
            axis([0 11 0 11]); axis off; colormap(cool); colorbar;
            maxtimelag = ((phasediffs_sorted(end) - phasediffs_sorted(1))/(2*pi))*(1/beta_peak)*1e3;
            colorbar('Ticks',[0,1],'TickLabels',{[num2str(0) ' ms'],[num2str(round(maxtimelag*10)/10) ' ms']},'Fontsize',14);
            %             DrawPhaseArrows([xloc yloc],electrode_id_sorted);
    end
end