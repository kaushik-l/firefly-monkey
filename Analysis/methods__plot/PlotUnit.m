function PlotUnit(behv,unit,plot_type,prs)

%% parameters
binwidth_abs = prs.binwidth_abs;
binwidth_warp = prs.binwidth_warp;
trlkrnlwidth = prs.trlkrnlwidth;
electrode = prs.electrode;

correct = behv.stats.trialtype.reward(1).trlindx;
incorrect = behv.stats.trialtype.reward(2).trlindx;
crazy = ~(behv.stats.trialtype.all.trlindx);
indx_all = ~crazy;

% behavioural data
behv_all = behv.trials(~crazy); ntrls_all = length(behv_all);
behv_correct = behv.trials(correct); ntrls_correct = length(behv_correct);
behv_incorrect = behv.trials(incorrect); ntrls_incorrect = length(behv_incorrect);

behv_trials = behv.trials(indx_all);
if isfield(unit,'trials'), spks_trials = unit.trials(indx_all); end
events_trials = cell2mat({behv_trials.events});
ntrls = length(behv_trials);

%% order trials based on trial duration
Td = [events_trials.t_end] - [events_trials.t_targ];
[~,indx] = sort(Td);
behv_trials = behv_trials(indx);
if isfield(unit,'trials'), spks_trials = spks_trials(indx); end
events_trials = events_trials(indx);
switch lower(plot_type)
    case 'raster_move'
        figure; hold on;set(gcf,'Position',[85 -276 700 1000]);
        for i=1:ntrls
            tspk = spks_trials(i).tspk(spks_trials(i).tspk>0);
            if ~isempty(tspk)
                plot(tspk(1:30:end),i,'.r','MarkerSize',2,'Color',[.5 .5 .5]);
%                 plot(events_trials(i).t_end,i,'.k');
            end
        end
        xlim([0 4]);
    case 'raster_start'
        %% raster plot - aligned to start of trial
        figure; hold on;
        for i=1:ntrls_all
            if ~isempty(spks_all(i).tspk)
                plot(spks_all(i).tspk(1:3:end),i,'ok','markersize',0.2,'markerFacecolor','k');
            end
        end
        xlim([0 4]); axis off;
        
    case 'raster_end'
        %% raster plot - aligned to end of trial
        figure; hold on;
        for i=1:ntrls_all
            if ~isempty(spks_all(i).tspk2end)
                plot(spks_all(i).tspk2end(1:4:end),i,'ob','markersize',0.2,'markerFacecolor','b');
            end
        end
        xlim([-4 0]); axis off;
        
    case 'raster_warp'
        %% raster plot - normalised by trial duration
        figure; hold on;
        for i=1:ntrls_all
            if ~isempty(spks_all(i).reltspk)
                plot(spks_all(i).reltspk,i,'ob','markersize',0.2,'markerFacecolor','b');
            end
        end
        xlim([0 1]); axis off;
        
    case 'rate_start'
        alignpos = zeros(1,ntrls_all);
%         for i=1:ntrls_all, alignpos(i) = find(behv_all(i).ts>0,1); end
        %% psth - aligned to start of trial
        nspk = struct2mat(spks_all,'nspk','start');
        trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
        nspk = conv2nan(nspk, trlkrnl);
        % plot
        ns_max = size(nspk,2);
        ts = binwidth_abs:binwidth_abs:ns_max*binwidth_abs;
        nspk = nspk/binwidth_abs;
        nspk(isnan(nspk)) = 0; % display nan as white pixels
        figure; hold on;
        imagesc(ts,1:size(nspk,1),nspk,[0  max(mean(nspk))]);
        colordata = colormap; colordata(1,:) = [1 1 1]; colormap(colordata);
        set(gca,'Ydir','normal'); axis([0 5 100 ntrls_all]); %axis off;
        
    case 'rate_end'
        alignpos = zeros(1,ntrls_all);
        %% psth - aligned to end of trial
        % find longest trial
        nspk2end = struct2mat(spks_all,'nspk2end',alignpos);
        trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
        nspk2end = conv2nan(nspk2end, trlkrnl);
        % plot
        ns_max = size(nspk2end,2);
        ts = -ns_max*binwidth_abs:binwidth_abs:-binwidth_abs;
        nspk2end = nspk2end/binwidth_abs;
        nspk2end(isnan(nspk2end)) = 0;  % display nan as white pixels
        figure; hold on;
        imagesc(ts,1:size(nspk2end,1),nspk2end,[0 max(mean(nspk2end))]);
        colordata = colormap; colordata(1,:) = [1 1 1]; colormap(colordata);
        set(gca,'Ydir','normal'); axis([-4 0 100 ntrls_all]); %axis off;
        
    case 'rate_warp'
        %% psth - normalised by trial duration
        ns_max = length(spks_all(1).relnspk);
        relnspk = nan(ntrls_all,ns_max);
        for i=1:ntrls_all
            relnspk(i,:) = spks_all(i).relnspk;
        end
        trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
        relnspk = conv2(relnspk, trlkrnl, 'valid');
        % calculate centre of mass
        ts = 1:ns_max;
        t_com = nansum(relnspk.*repmat(ts,[size(relnspk,1) 1]),2)./nansum(relnspk,2);
        % plot
        relnspk = relnspk/binwidth_warp;
        relnspk(isnan(relnspk)) = 0;  % display nan as white pixels
        figure; hold on;
        imagesc(ts,1:size(relnspk,1),relnspk,[0 max(mean(relnspk))]);
        colordata = colormap; colordata(1,:) = [1 1 1]; colormap(colordata);
        set(gca,'Ydir','normal'); ylim([100 ntrls_all]); %axis off;
        plot(t_com,1:size(relnspk,1));
        
    case 'psth_warp'
        %% same as rate_warp but trial averaged
        ns_max = length(spks_all(1).relnspk);
        relnspk = nan(ntrls_all,ns_max);
        for i=1:ntrls_all
            relnspk(i,:) = spks_all(i).relnspk;
        end
        trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
        relnspk = conv2(relnspk, trlkrnl, 'valid');
        % plot
        relnspk = mean(relnspk)/binwidth_warp; % mean across trials
        ts = linspace(0,1,length(relnspk));
        figure(7); hold on;
        plot(ts,relnspk);
        set(gca,'Ydir','normal'); %axis off;
    case 'rate_start_ptb'
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
        % unptb trials
        nspk_unptb = nspk(~ptb_indx,:);
        % ptb trials
        nspk_ptb = nspk(ptb_indx,:);
        trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
        nspk_unptb = conv2nan(nspk_unptb, trlkrnl); nspk_ptb = conv2nan(nspk_ptb, trlkrnl);
        % plot
        ts = binwidth_abs:binwidth_abs:ns_max*binwidth_abs;
        nspk_unptb = nspk_unptb/binwidth_abs; nspk_ptb = nspk_ptb/binwidth_abs;
        nspk_unptb(isnan(nspk_unptb)) = 0; nspk_ptb(isnan(nspk_ptb)) = 0; % display nan as white pixels
        figure; hold on;
        imagesc(ts,1:size(nspk_unptb,1),nspk_unptb,[0  max(mean(nspk_unptb))]);
        colordata = colormap; colordata(1,:) = [1 1 1]; colormap(colordata);
        set(gca,'Ydir','normal'); %axis([0 4 100 ntrls_all]); %axis off;
        figure; hold on;
        imagesc(ts,1:size(nspk_ptb,1),nspk_ptb,[0  max(mean(nspk_unptb))]);
        colordata = colormap; colordata(1,:) = [1 1 1]; colormap(colordata);
        set(gca,'Ydir','normal'); %axis([0 4 100 ntrls_all]); %axis off;
    case 'rate_ptb'
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
        % unptb trials
        nspk_unptb = nspk(~ptb_indx,:);
        % ptb trials
        nspk_ptb = nspk(ptb_indx,:);
        % delay aligned response
        ptb_times = ptb_delay(ptb_indx);
        [~,ptb_order] = sort(ptb_times);
        nspk_ptb = nspk_ptb(ptb_order,:);
        trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
        nspk_unptb = conv2nan(nspk_unptb, trlkrnl); nspk_ptb = conv2nan(nspk_ptb, trlkrnl);
        % plot
        ts = binwidth_abs:binwidth_abs:ns_max*binwidth_abs;
        nspk_unptb = nspk_unptb/binwidth_abs; nspk_ptb = nspk_ptb/binwidth_abs;
        nspk_unptb(isnan(nspk_unptb)) = 0; nspk_ptb(isnan(nspk_ptb)) = 0; % display nan as white pixels
        figure; hold on;
        imagesc(ts,1:size(nspk_unptb,1),nspk_unptb,[0  max(mean(nspk_unptb))]);
        colordata = colormap; colordata(1,:) = [1 1 1]; colormap(colordata);
        set(gca,'Ydir','normal'); %axis([0 4 100 ntrls_all]); %axis off;
%         figure; hold on;
%         imagesc(ts,1:size(nspk_ptb,1),nspk_ptb,[0  max(mean(nspk_unptb))]);
%         colordata = colormap; colordata(1,:) = [1 1 1]; colormap(colordata);
%         set(gca,'Ydir','normal'); %axis([0 4 100 ntrls_all]); %axis off;
    case 'rate_density'
        stats = unit.stats;
        clr = {'b','c','m','r'};
        % aligned to start
        figure; hold on;
        for i=1:length(stats.density)
            t = stats.density(i).nspk.t;
            r_mu = stats.density(i).nspk.mu;
            r_sig = stats.density(i).nspk.sig;
            shadedErrorBar(t,r_mu,r_sig,'lineprops',clr{i});
        end
        xlim([0.2 2.2]);
        % aligned to end
        figure; hold on;
        for i=1:length(stats.density)
            t = stats.density(i).nspk2end.t;
            r_mu = stats.density(i).nspk2end.mu;
            r_sig = stats.density(i).nspk2end.sig;
            shadedErrorBar(t,r_mu,r_sig,'lineprops',clr{i});
        end
        xlim([-2 0]);
        % time rescaled
        figure; hold on;
        for i=1:length(stats.density)
            t = stats.density(i).relnspk.t;
            r_mu = stats.density(i).relnspk.mu;
            r_sig = stats.density(i).relnspk.sig;
            shadedErrorBar(t,r_mu,r_sig,'lineprops',clr{i});
        end
        xlim([0 1]);
    
    case 'rate_reward'
        stats = unit.stats;
        clr = {'b','c','m','r'};
        % aligned to start
%         figure; hold on;
%         for i=1:length(stats.reward)
%             t = stats.reward(i).nspk.t;
%             r_mu = stats.reward(i).nspk.mu;
%             r_sig = stats.reward(i).nspk.sig;
%             shadedErrorBar(t,r_mu,r_sig,'lineprops',clr{i});
%         end
%         xlim([0 2]);
        % aligned to end
        figure; hold on;
        for i=1:length(stats.reward)
            t = stats.reward(i).nspk2end.t;
            r_mu = stats.reward(i).nspk2end.mu;
            r_sig = stats.reward(i).nspk2end.sig;
            shadedErrorBar(t,r_mu,r_sig,'lineprops',clr{i});
        end
        xlim([-2 0]);

    case 'tuning_events'
        %% temporal
        contexts = {'all','reward','density','landmark'}; ncontexts = length(contexts);
        events = {'move','target','reward','stop'}; nevents = length(events);
        trialtype = unit.stats.trialtype;
        hold on;
        for i=1:ncontexts
            nconds = length(trialtype.(contexts{i}));
            for j=1:nconds
                for k=1:nevents
                    subplot(ncontexts,nevents,nevents*(i-1) + k); hold on;
                    t = trialtype.(contexts{i})(j).events.(events{k}).time;
                    r = trialtype.(contexts{i})(j).events.(events{k}).rate;
                    plot(t,r,'Linewidth',2);
                end
            end
        end
        
    case 'tuning_continuous'
        %% continuous variables
        contexts = {'all','reward','density','landmark'}; ncontexts = length(contexts);
        trialtype = unit.stats.trialtype;
        nvars = length(trialtype.all.models.LNP.x);
        for i=1:ncontexts
            nconds = length(trialtype.(contexts{i}));
            for j=1:nconds
                bestmodel = trialtype.(contexts{i})(j).models.LNP.bestmodel;
                if ~isnan(bestmodel)
                    for k=1:nvars
                        subplot(ncontexts,nvars,nvars*(i-1) + k); hold on;
                        x = trialtype.(contexts{i})(j).models.LNP.x{k};
                        y = trialtype.(contexts{i})(j).models.LNP.wts{bestmodel}{k};
                        if ~isempty(y), plot(x,y,'Linewidth',2); end
                    end
                end
            end
        end
        
    case 'gam'
        %% plot model-based tuning functions
        nvars = numel(unit.Uncoupledmodel.x);
        figure; hold on;
        bestmodel = unit.Uncoupledmodel.bestmodel;
        ymin = inf; ymax = -inf;
        for i=1:nvars
            subplot(2,ceil(nvars/2),i); hold on;
            plot(unit.Uncoupledmodel.x{i},unit.Uncoupledmodel.marginaltunings{end}{i},'k');
            if ~isempty(unit.Uncoupledmodel.marginaltunings{bestmodel}{i})
                plot(unit.Uncoupledmodel.x{i},unit.Uncoupledmodel.marginaltunings{bestmodel}{i},'r');
                ymin = min(ymin,min(unit.Uncoupledmodel.marginaltunings{bestmodel}{i}));
                ymax = max(ymax,max(unit.Uncoupledmodel.marginaltunings{bestmodel}{i}));
            end
            xlim2 = get(gca,'xlim'); xlim2 = [floor(xlim2(1)) ceil(xlim2(2))]; 
            set(gca,'xlim',xlim2,'xTick',xlim2,'Fontsize',10);
        end
        % match y-scales
        subplot(2,ceil(nvars/2),1); ylabel('(spk/s)');
        for i=1:nvars
            subplot(2,ceil(nvars/2),i);
            ylim2 = [floor(ymin) ceil(ymax)]; set(gca,'ylim',ylim2);
            xlabel(prs.GAM_varname{i}(1:min(4,length(prs.GAM_varname{i}))));
            if strcmp(unit.Uncoupledmodel.xtype{i},'event')
                set(gca,'xlim',[-0.5 0.5],'XTick',[-0.5 0.5]); 
                xlabel({'Time (s) rel. to'; prs.GAM_varname{i}}); vline(0,'k'); 
            end
        end
        pnum = find(cellfun(@(x) ~isempty(x), unit.Uncoupledmodel.marginaltunings{bestmodel}),1);
        subplot(2,ceil(nvars/2),pnum);
        legend({'full model','best model'});
        %% plot log-likelihood vlues of aaaaaalllll models
        modelclass = cell2mat(unit.Uncoupledmodel.class);
        nmodels = size(modelclass,1);
        for i=1:nmodels, LLval(i) = nanmean(unit.Uncoupledmodel.testFit{i}(:,3)); end
%         colorcode = jet(max(sum(modelclass,2)));
        colorcode = [0.7 0.3 0.8 ; [0.7 0.3 0.8] + 0.2; [0 0.6 0]; [0 0.6 0] + 0.3; ...
    [0.25 0.25 0.25]; [0.5 0.5 0.5]; [0.75 0.75 0.75]; [1 1 1]]; % hardcode for 8 vars (4 cont + 4 discrete)
        stackedbarweb(LLval, modelclass, colorcode);
%         figure; bar(LLval,'stacked'); axis([0 nmodels 0 max(LLval)]);
    case 'sfc'
        lfps = unit.stats.trialtype.all.continuous.lfps;
        nlfps = length(lfps);
        f = lfps(1).sta.f;
        maxpeak = nan(nlfps,1);
        sfc = nan(nlfps,length(f));
        for i=1:nlfps
            sfc(i,:) = lfps(i).sta.sfc;
            [pks,locs] = findpeaks(sfc(i,:),f,'minpeakprominence',0.001);
            if ~isempty(max(pks((locs>5 & locs<40)))), maxpeak(i) = max(pks((locs>5 & locs<40))); end
        end
        maxpeak = max(maxpeak); if isnan(maxpeak), maxpeak = 1e-3; end        
        switch electrode
            case 'utah96'
                [xloc,yloc] = map_utaharray([],electrode);
                [channel_id,electrode_id] = MapChannel2Electrode(electrode);
                [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
                sfc = sfc(reorderindx,:);
                hold on;
                for i=1:nlfps
                    subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                    plot(f,sfc(i,:)); axis([2 70 -1e-1*maxpeak 1.5*maxpeak]); axis off;
                    if i==electrode_id(unit.channel_id), axis on; box on; set(gca,'XTick',[]); set(gca,'YTick',[]); end
                end
        end
        
    case 'sta'
        lfps = unit.stats.trialtype.all.continuous.lfps;
        nlfps = length(lfps);
        t = lfps(1).sta.t;
        maxpeak = nan(nlfps,1);
        sta = nan(nlfps,length(t));
        for i=1:nlfps
            sta(i,:) = lfps(i).sta.lfp;
            maxpeak = max(max(sta(i,:)),abs(min(sta(i,:))));
        end
        maxpeak = max(maxpeak);
        switch electrode
            case 'utah96'
                [xloc,yloc] = map_utaharray([],electrode);
                [channel_id,electrode_id] = MapChannel2Electrode(electrode);
                [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
                sta = sta(reorderindx,:);
                hold on;
                for i=1:nlfps
                    subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                    plot(t,sta(i,:)); ylim([-1.5*maxpeak 1.5*maxpeak]); xlim([-0.2 0.2]); axis off;
                    if i==electrode_id(unit.channel_id), axis on; box on; set(gca,'XTick',[]); set(gca,'YTick',[]); end
                end
        end
        
    case 'sta_beta'
        lfps = unit.stats.trialtype.all.continuous.lfps;
        nlfps = length(lfps);
        t = lfps(1).sta_beta.t;
        maxpeak = nan(nlfps,1);
        sta = nan(nlfps,length(t));
        for i=1:nlfps
            sta(i,:) = lfps(i).sta_beta.lfp;
            maxpeak = max(max(sta(i,:)),abs(min(sta(i,:))));
        end
        maxpeak = max(maxpeak);
        switch electrode
            case 'utah96'
                [xloc,yloc] = map_utaharray([],electrode);
                [channel_id,electrode_id] = MapChannel2Electrode(electrode);
                [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
                sta = sta(reorderindx,:);
                hold on;
                for i=1:nlfps
                    subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                    plot(t,sta(i,:)); ylim([-1.5*maxpeak 1.5*maxpeak]); axis off;
                    if i==electrode_id(unit.channel_id), axis on; box on; set(gca,'XTick',[]); set(gca,'YTick',[]); end
                end
        end
    case 'phase'
        lfps = unit.stats.trialtype.all.continuous.lfps;
        nlfps = length(lfps);
        maxrate = nan(nlfps,1); minrate = nan(nlfps,1);
        for i=1:nlfps
            phi(i,:) = lfps(i).phase.tuning.stim.mu;
            rate(i,:) = lfps(i).phase.tuning.rate.mu;
            maxrate(i) = max(rate(i,:));
            minrate(i) = min(rate(i,:));
        end
        maxrate = max(maxrate); minrate = min(minrate);
        switch electrode
            case 'utah96'
                [xloc,yloc] = map_utaharray([],electrode);
                [channel_id,electrode_id] = MapChannel2Electrode(electrode);
                [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
                phi = phi(reorderindx,:); rate = rate(reorderindx,:);
                hold on;
                for i=1:nlfps
                    subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                    plot(phi(i,:),rate(i,:)); ylim([minrate-0.5*maxrate 1.5*maxrate]); 
                    vline(0,'k'); axis off;
                    if i==electrode_id(unit.channel_id), axis on; box on; set(gca,'XTick',[]); set(gca,'YTick',[]); end
                end
        end
    case 'phase_beta'
        lfps = unit.stats.trialtype.all.continuous.lfps;
        nlfps = length(lfps);
        maxrate = nan(nlfps,1); minrate = nan(nlfps,1);
        for i=1:nlfps
            phi(i,:) = lfps(i).phase_beta.tuning.stim.mu;
            rate(i,:) = lfps(i).phase_beta.tuning.rate.mu;
            maxrate(i) = max(rate(i,:));
            minrate(i) = min(rate(i,:));
        end
        maxrate = max(maxrate); minrate = min(minrate);
        switch electrode
            case 'utah96'
                [xloc,yloc] = map_utaharray([],electrode);
                [channel_id,electrode_id] = MapChannel2Electrode(electrode);
                [~,indx] = sort(electrode_id); reorderindx = channel_id(indx);
                phi = phi(reorderindx,:); rate = rate(reorderindx,:);
                hold on;
                for i=1:nlfps
                    subplot(10,10,10*(xloc(i)-1) + yloc(i)); hold on;
                    plot(phi(i,:),rate(i,:)); %ylim([minrate-0.5*maxrate 1.5*maxrate]);
                    vline(0,'k'); axis off;
                    if i==electrode_id(unit.channel_id), axis on; box on; set(gca,'XTick',[]); set(gca,'YTick',[]); end
                end
        end
end