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
        case 'rawLFP_movement'
            ntrls = numel(lfp.stationary);
            trlindx = floor(rand*(ntrls-1))
            lfp_temp1 = lfp.stationary(trlindx).lfp; lfp_temp2 = lfp.mobile(trlindx).lfp;
            lfp_temp3 = lfp.stationary(trlindx+1).lfp; lfp_temp4 = lfp.mobile(trlindx+1).lfp;
            dt = prs.dt;
            ts_temp1 = dt:dt:dt*numel(lfp_temp1); ts_temp2 = ts_temp1(end) + [dt:dt:dt*numel(lfp_temp2)]; 
            ts_temp3 = ts_temp2(end) + [dt:dt:dt*numel(lfp_temp3)]; ts_temp4 = ts_temp3(end) + [dt:dt:dt*numel(lfp_temp4)];
            figure; hold on; 
            plot(ts_temp1,lfp_temp1,'k'); plot(ts_temp2,lfp_temp2,'r');
            plot(ts_temp3,lfp_temp3,'k'); plot(ts_temp4,lfp_temp4,'r');
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
    end
end