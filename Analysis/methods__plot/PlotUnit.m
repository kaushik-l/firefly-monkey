function PlotUnit(prs,behv,unit,plot_type,trial_type)

%% parameters
binwidth_abs = prs.binwidth_abs;
binwidth_warp = prs.binwidth_warp;
trlkrnlwidth = prs.trlkrnlwidth;
electrode = prs.electrode_type;

% select trial indices
trialtypes = fields(behv.stats.trialtype);
selectedtrialtype = strcmp(trialtypes,trial_type);
conditions = behv.stats.trialtype.(trialtypes{selectedtrialtype});
condnames = {conditions.val}; nconds = numel(conditions);
for k=1:nconds, trlindx(k,:) = conditions(k).trlindx; end
cmap = brewermap(2,'PuOr');

% behavioural data
behv_trials = behv.trials;
events_trials = cell2mat({behv_trials.events});
if isprop(unit,'trials'), spks_trials = unit.trials; end

%% order trials based on trial duration
switch lower(plot_type)
    case 'raster_move'
        %% raster plot - aligned to movement onset
        for k=1:nconds
            ntrls = sum(trlindx(k,:));
            % select
            spks_selectedtrials = spks_trials(trlindx(k,:));
            events_selectedtrials = events_trials(trlindx(k,:));
            % re-order
            Td = [events_trials(trlindx(k,:)).t_end] - [events_trials(trlindx(k,:)).t_targ]; [~,indx] = sort(Td);
            spks_selectedtrials = spks_selectedtrials(indx); events_selectedtrials = events_selectedtrials(indx);
            subplot(1,nconds,k); hold on;set(gcf,'Position',[100 100 400 400]);
            for i=1:ntrls
                tspk = spks_selectedtrials(i).tspk - events_selectedtrials(i).t_move;
                if ~isempty(tspk), plot(tspk(1:30:end),i,'.r','MarkerSize',2,'Color',[.5 .5 .5]); end % plot every 30th spike
            end
            xlim([min(prs.ts.move) max(prs.ts.move)]); xlabel('Time from movement onset (s)'); ylabel('Trial number');
        end
    case 'raster_targ'
        %% raster plot - aligned to target onset
        for k=1:nconds
            ntrls = sum(trlindx(k,:));
            % select
            spks_selectedtrials = spks_trials(trlindx(k,:));
            events_selectedtrials = events_trials(trlindx(k,:));
            % re-order
            Td = [events_trials(trlindx(k,:)).t_end] - [events_trials(trlindx(k,:)).t_targ]; [~,indx] = sort(Td);
            spks_selectedtrials = spks_selectedtrials(indx); events_selectedtrials = events_selectedtrials(indx);
            subplot(1,nconds,k); hold on;set(gcf,'Position',[100 100 400 400]);
            for i=1:ntrls
                tspk = spks_selectedtrials(i).tspk - events_selectedtrials(i).t_targ;
                if ~isempty(tspk), plot(tspk(1:30:end),i,'.r','MarkerSize',2,'Color',[.5 .5 .5]); end % plot every 30th spike
            end
            xlim([min(prs.ts.target) max(prs.ts.target)]); xlabel('Time from target onset (s)'); ylabel('Trial number');
        end
        
    case 'raster_stop'
        %% raster plot - aligned to end of movement
        for k=1:nconds
            ntrls = sum(trlindx(k,:));
            % select
            spks_selectedtrials = spks_trials(trlindx(k,:));
            events_selectedtrials = events_trials(trlindx(k,:));
            % re-order
            Td = [events_trials(trlindx(k,:)).t_end] - [events_trials(trlindx(k,:)).t_targ]; [~,indx] = sort(Td);
            spks_selectedtrials = spks_selectedtrials(indx); events_selectedtrials = events_selectedtrials(indx);
            subplot(1,nconds,k); hold on;set(gcf,'Position',[300 300 400 400]);
            for i=1:ntrls
                tspk = spks_selectedtrials(i).tspk - events_selectedtrials(i).t_stop;
                if ~isempty(tspk), plot(tspk(1:30:end),i,'.r','MarkerSize',2,'Color',[.5 .5 .5]); end % plot every 30th spike
            end
            xlim([min(prs.ts.stop) max(prs.ts.stop)]); xlabel('Time from stopping (s)'); ylabel('Trial number');
        end     
        
    case 'raster_rew'
        %% raster plot - aligned to reward delivery
        for k=1:nconds
            ntrls = sum(trlindx(k,:));
            % select
            spks_selectedtrials = spks_trials(trlindx(k,:));
            events_selectedtrials = events_trials(trlindx(k,:));
            % re-order
            Td = [events_trials(trlindx(k,:)).t_end] - [events_trials(trlindx(k,:)).t_targ]; [~,indx] = sort(Td);
            spks_selectedtrials = spks_selectedtrials(indx); events_selectedtrials = events_selectedtrials(indx);
            subplot(1,nconds,k); hold on;set(gcf,'Position',[100 100 400 400]);
            for i=1:ntrls
                tspk = spks_selectedtrials(i).tspk - events_selectedtrials(i).t_rew;
                if ~isempty(tspk), plot(tspk(1:30:end),i,'.r','MarkerSize',2,'Color',[.5 .5 .5]); end % plot every 30th spike
            end
            xlim([min(prs.ts.reward) max(prs.ts.reward)]); xlabel('Time from stopping (s)'); ylabel('Trial number');
        end
        
    case 'rate_move'
        %% mean firing rate - aligned to movement onset
        for k=1:nconds
            hold on;set(gcf,'Position',[100 100 400 400]);
            t = unit.stats.trialtype.(trial_type)(k).events.move.time;
            r = unit.stats.trialtype.(trial_type)(k).events.move.rate;
            plot(t,r);
        end
        legend(condnames);
        xlim([min(prs.ts.move) max(prs.ts.move)]); xlabel('Time from movement onset (s)'); ylabel('Mean firing rate (spk/s)');
        
    case 'rate_targ'
        %% mean firing rate - aligned to target onset
        for k=1:nconds
            hold on;set(gcf,'Position',[100 100 400 400]);
            t = unit.stats.trialtype.(trial_type)(k).events.target.time;
            r = unit.stats.trialtype.(trial_type)(k).events.target.rate;
            plot(t,r);
        end
        legend(condnames);
        xlim([min(prs.ts.target) max(prs.ts.target)]); xlabel('Time from target onset (s)'); ylabel('Mean firing rate (spk/s)');
        
    case 'rate_stop'
        %% mean firing rate - aligned to monkey stopping
        for k=1:nconds
            hold on;set(gcf,'Position',[100 100 400 400]);
            t = unit.stats.trialtype.(trial_type)(k).events.stop.time;
            r = unit.stats.trialtype.(trial_type)(k).events.stop.rate;
            plot(t,r);
        end
        legend(condnames);
        xlim([min(prs.ts.stop) max(prs.ts.stop)]); xlabel('Time from stopping (s)'); ylabel('Mean firing rate (spk/s)');
        
    case 'rate_rew'
        %% mean firing rate - aligned to reward delivery
        for k=1:nconds
            hold on;set(gcf,'Position',[100 100 400 400]);
            t = unit.stats.trialtype.(trial_type)(k).events.reward.time;
            r = unit.stats.trialtype.(trial_type)(k).events.reward.rate;
            plot(t,r);
        end
        legend(condnames);
        xlim([min(prs.ts.reward) max(prs.ts.reward)]); xlabel('Time from reward (s)'); ylabel('Mean firing rate (spk/s)');        
        
    case 'gam_uncoupled'
        condition = unit;
        %% plot model-based tuning functions
        nvars = numel(condition(1).Coupledmodel.x)-1;
        bestmodel = condition(1).Uncoupledmodel.bestmodel;
        figure; hold on;
        ymin = inf; ymax = -inf;
        for k=1:nconds
            if ~isnan(bestmodel)
                for i=1:nvars
                    subplot(2,ceil(nvars/2),i); hold on;
                    if ~isempty(condition(k).Uncoupledmodel.marginaltunings{bestmodel}{i})
                        shadedErrorBar(condition(k).Uncoupledmodel.x{i},condition(k).Uncoupledmodel.marginaltunings{bestmodel}{i}.mean,...
                            condition(k).Uncoupledmodel.marginaltunings{bestmodel}{i}.std,'lineprops',{'Color',cmap(k,:)});
                        ymin = min(ymin,min(condition(k).Uncoupledmodel.marginaltunings{bestmodel}{i}.mean));
                        ymax = max(ymax,max(condition(k).Uncoupledmodel.marginaltunings{bestmodel}{i}.mean));
                    end
                    xlim2 = get(gca,'xlim'); xlim2 = [floor(xlim2(1)) ceil(xlim2(2))];
                    set(gca,'xlim',xlim2,'xTick',xlim2,'Fontsize',10);
                end
                % match y-scales
                subplot(2,ceil(nvars/2),1); ylabel('(spk/s)');
                for i=1:nvars
                    subplot(2,ceil(nvars/2),i);
                    ylim2 = [floor(ymin) ceil(ymax)]; set(gca,'ylim',ylim2);
                    xlabel(prs.varlookup(prs.GAM_varname{i}));
                    %                 xlabel(prs.GAM_varname{i}(1:min(4,length(prs.GAM_varname{i}))));
                    if strcmp(condition(k).Coupledmodel.xtype{i},'event')
                        if strcmp(prs.GAM_varname{i},'target_OFF')
                            set(gca,'xlim',[-0.5 0.5],'XTick',[-0.3 0.2],'XTickLabel',[-0.3 0.2] + 0.3); 
                            xlabel({'Time (s) rel. to'; prs.varlookup(prs.GAM_varname{i})},'Interpreter','none'); vline(-0.3,'k');
                        else
                            set(gca,'xlim',[-0.5 0.5],'XTick',[-0.5 0 0.5]);
                            xlabel({'Time (s) rel. to'; prs.varlookup(prs.GAM_varname{i})},'Interpreter','none'); vline(0,'k');
                        end
                    end
                end
                pnum = find(cellfun(@(x) ~isempty(x), condition(k).Uncoupledmodel.marginaltunings{bestmodel}),1);
                subplot(2,ceil(nvars/2),pnum);
            end
        end
        h = findobj(gca);
        legend(h(4*(nconds:-1:1)),condnames,'Location','best');

    case 'gam_coupled'
        condition = unit;
        %% plot model-based tuning functions
        nvars = numel(condition(1).Coupledmodel.x)-1;
        figure; hold on;
        ymin = inf; ymax = -inf;
        for k=1:nconds
            for i=1:nvars
                subplot(2,ceil(nvars/2),i); hold on;
                if ~isempty(condition(k).Coupledmodel.marginaltunings{i}.mean)
                    shadedErrorBar(condition(k).Coupledmodel.x{i},condition(k).Coupledmodel.marginaltunings{i}.mean,...
                        condition(k).Coupledmodel.marginaltunings{i}.std,'lineprops',{'Color',cmap(k,:)});
                    ymin = min(ymin,min(condition(k).Coupledmodel.marginaltunings{i}.mean));
                    ymax = max(ymax,max(condition(k).Coupledmodel.marginaltunings{i}.mean));
                end
                xlim2 = get(gca,'xlim'); xlim2 = [floor(xlim2(1)) ceil(xlim2(2))];
                set(gca,'xlim',xlim2,'xTick',xlim2,'Fontsize',10);
            end
            % match y-scales
            subplot(2,ceil(nvars/2),1); ylabel('(spk/s)');
            for i=1:nvars
                subplot(2,ceil(nvars/2),i);
                ylim2 = [floor(ymin) ceil(ymax)]; set(gca,'ylim',ylim2);
                xlabel(prs.varlookup(prs.GAM_varname{i}));
%                 xlabel(prs.GAM_varname{i}(1:min(4,length(prs.GAM_varname{i}))));
                if strcmp(condition(k).Coupledmodel.xtype{i},'event')
                    if strcmp(prs.GAM_varname{i},'target_OFF')
                        set(gca,'xlim',[-0.5 0.5],'XTick',[-0.3 0.2],'XTickLabel',[-0.3 0.2] + 0.3); 
                        xlabel({'Time (s) rel. to'; prs.varlookup(prs.GAM_varname{i})},'Interpreter','none'); vline(-0.3,'k');
                    else
                        set(gca,'xlim',[-0.5 0.5],'XTick',[-0.5 0 0.5]);
                        xlabel({'Time (s) rel. to'; prs.varlookup(prs.GAM_varname{i})},'Interpreter','none'); vline(0,'k');
                    end
                end
            end
            pnum = find(cellfun(@(x) ~isempty(x), condition(k).Coupledmodel.marginaltunings),1);
            subplot(2,ceil(nvars/2),pnum);
        end
        h = findobj(gca);
        legend(h(4*(nconds:-1:1)),condnames,'Location','best');
        
    case 'gam_coupledvsuncoupled'
        condition = unit;
        %% plot model-based tuning functions
        nvars = numel(condition(1).Coupledmodel.x)-1;
        bestmodel = condition(1).Uncoupledmodel.bestmodel;
        figure; hold on;
        ymin = inf; ymax = -inf;
        for k=1:nconds
            if ~isnan(bestmodel)
                for i=1:nvars
                    subplot(2,ceil(nvars/2),i); hold on;
                    if ~isempty(condition(k).Uncoupledmodel.marginaltunings{bestmodel}{i})
                        plot(condition(k).Uncoupledmodel.x{i},condition(k).Uncoupledmodel.marginaltunings{bestmodel}{i}.mean,'Color',cmap(k,:),'linestyle','--');
                        plot(condition(k).Coupledmodel.x{i},condition(k).Coupledmodel.marginaltunings{i}.mean,'Color',cmap(k,:));
                        ymin = min(ymin,min(condition(k).Uncoupledmodel.marginaltunings{bestmodel}{i}.mean));
                        ymax = max(ymax,max(condition(k).Uncoupledmodel.marginaltunings{bestmodel}{i}.mean));
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
                    if strcmp(condition(k).Uncoupledmodel.xtype{i},'event')
                        set(gca,'xlim',[-0.5 0.5],'XTick',[-0.5 0.5]);
                        xlabel({'Time (s) rel. to'; prs.GAM_varname{i}}); vline(0,'k');
                    end
                end
                pnum = find(cellfun(@(x) ~isempty(x), condition(k).Uncoupledmodel.marginaltunings{bestmodel}),1);
                subplot(2,ceil(nvars/2),pnum);
            end
        end
        h = findobj(gca);
        legend([h(2) h(3)],{'Coupled','Uncoupled'},'Location','best');

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