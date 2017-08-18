function PlotUnit(behv,unit,plot_type,prs)

%% parameters
binwidth_abs = prs.binwidth_abs;
binwidth_warp = prs.binwidth_warp;
trlkrnlwidth = prs.trlkrnlwidth;

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
Td_all = [behv_all.t_end] - [behv_all.t_beg];
rew_all = [behv_all.reward];

switch plot_type
    case 'raster_start'
        %% raster plot - aligned to start of trial
        figure; hold on;
        for i=1:ntrls_all
            if ~isempty(spks_all(i).tspk)
                plot(spks_all(i).tspk(1:3:end),i,'oy','markersize',0.8,'markerFacecolor','r');
            end
        end
        xlim([0 4]); axis off;
        
    case 'raster_end'
        %% raster plot - aligned to end of trial
        figure; hold on;
        for i=1:ntrls_all
            if ~isempty(spks_all(i).tspk2end)
                plot(spks_all(i).tspk2end(1:4:end),i,'ob','markersize',0.8,'markerFacecolor','b');
            end
        end
        xlim([-4 0]); axis off;
        
    case 'raster_warp'
        %% raster plot - normalised by trial duration
        figure; hold on;
        for i=1:ntrls_all
            if ~isempty(spks_all(i).reltspk)
                plot(spks_all(i).reltspk,i,'ob','markersize',0.8,'markerFacecolor','b');
            end
        end
        xlim([0 1]); axis off;
        
    case 'raster_reward'
        %% raster plot aligned to reward onset
        figure; hold on;
   
        Tr = [behv_all.t_rew] - [behv_all.t_beg];
        for i=1:ntrls_all 
            if ~isempty(spks_all(i).tspk) && ~isnan(Tr(i))
                plot(spks_all(i).tspk(1:3:end) - Tr(i) + 0.1,i,'or','markersize',0.8,'markerFacecolor','r');
                plot(0.1,i,'ok','markersize',0.8,'markerFacecolor','k');
            end
        end
        %xlim([-4 0]); axis off;
    case 'rate_start'
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
        trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
        nspk = conv2nan(nspk, trlkrnl);
        % plot
        ts = binwidth_abs:binwidth_abs:ns_max*binwidth_abs;
        nspk = nspk/binwidth_abs;
        nspk(isnan(nspk)) = 0; % display nan as white pixels
        figure; imagesc(ts,1:ntrls_all,nspk,[0  max(mean(nspk))]);
        colordata = colormap; colordata(1,:) = [1 1 1]; colormap(colordata);
        set(gca,'Ydir','normal','box', 'off','TickDir', 'out'); axis([0 4 100 ntrls_all]); %axis off;
        ylabel('Trial'); xlabel('Time(s)'); 
        
    case 'rate_end'
        %% psth - aligned to end of trial
        % find longest trial
        ns = zeros(1,ntrls_all);
        for i=1:ntrls_all
            ns(i) = length(spks_all(i).nspk2end);
        end
        ns_max = max(ns);
        % store responses in a matrix (Trial x Time)
        nspk2end = nan(ntrls_all,ns_max);
        rewardcount = 0;
        for i=1:ntrls_all
            if behv_all(i).reward
                rewardcount = rewardcount + 1;
                nspk2end(rewardcount,end-ns(i)+1:end) = spks_all(i).nspk2end;
            end
        end
        trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
        nspk2end = conv2nan(nspk2end, trlkrnl);
        % plot
        ts = -ns_max*binwidth_abs:binwidth_abs:-binwidth_abs;
        nspk2end = nspk2end/binwidth_abs;
        nspk2end(isnan(nspk2end)) = 0;  % display nan as white pixels
        figure; imagesc(ts,1:ntrls_all,nspk2end,[0  max(mean(nspk2end))]);
        yyaxis left; colordata = colormap; colordata(1,:) = [1 1 1]; colormap(colordata);
        set(gca,'Ydir','normal', 'box', 'off','TickDir', 'out'); axis([-4 -0.5 100 ntrls_all]); %axis off;
        ylabel('Trial'); xlabel('Time(s)'); 
        % plot psth on top
        yyaxis right; plot(ts,nanmean(nspk2end), 'LineWidth', 3, 'Color', 'r'); set(gca,'XTick', [-4:0.5:0], 'TickDir', 'out', 'box', 'off');vline([-1 -0.7]);
        
    case 'rate_warp'
        %% psth - normalised by trial duration
        ns_max = length(spks_all(1).relnspk);
        relnspk = nan(ntrls_all,ns_max);
        for i=1:ntrls_all
            relnspk(i,:) = spks_all(i).relnspk;
        end
        trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
        relnspk = conv2(relnspk, trlkrnl, 'valid');
        % plot
        relnspk = relnspk/binwidth_warp;
        relnspk(isnan(relnspk)) = 0;  % display nan as white pixels
        figure; imagesc(relnspk,[0 max(mean(relnspk))]);
        colordata = colormap; colordata(1,:) = [1 1 1]; colormap(colordata);
        set(gca,'Ydir','normal'); ylim([100 ntrls_all]); %axis off;
case 'rate_reward'
        %% psth - aligned to start of reward TODO Add time to end 
        % find longest trial
        ns = zeros(1,ntrls_all);
        for i=1:ntrls_all
            ns(i) = length(spks_all(i).nspk);
        end
        ns_max = max(ns);
        % store responses in a matrix (Trial x Time)
        nspk = nan(ntrls_all,ns_max);
        for i=1:ntrls_all
            nspk(i,1:ns(i)) = spks_all(i).nspk; % Trials already sorted
        end
        trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
        nspk = conv2nan(nspk, trlkrnl);
        count=0;
        Tr = [behv_all.t_rew] - [behv_all.t_beg];
%         for i=1:ntrls_all
%             rew_indx(i) = round(Tr(i)/prs.binwidth_abs);
%             if ~isnan(rew_indx(i))
%                 count = count+1;
%                 nspk2rew(count,:) = circshift(nspk(i,:),-rew_indx(i)+75); % do not use a number
%             end
%         end
        
        % Hist of reward times 
        % juice_time = [behv_all.t_end] - [behv_all.t_rew]; <--This does not give the actual reward time. Delays in the system

        % plot  
        ts = binwidth_abs:binwidth_abs:ns_max*binwidth_abs; % redefine to make it to the ts the same as the longest trial.
        nspk2rew = nspk/binwidth_abs;
        %nspk2rew(isnan(nspk2rew)) = 0;  % display nan as white pixels
        figure; imagesc(ts,1:size(nspk2rew,1),nspk2rew,[0  1.5*max(mean(nspk2rew))]);
        yyaxis left; colordata = colormap; colordata(1,:) = [1 1 1]; colormap(colordata);
        set(gca,'Ydir','normal','XTick', [0:0.1:2], 'TickDir', 'out', 'box', 'off'); axis([0 ts(150) 100 count]); vline(ts(75));
        ylabel('Trial'); xlabel('Time(s)');
        yyaxis right; plot(ts,nanmean(nspk2rew(301:end,:)), 'LineWidth', 3, 'Color', 'r'); set(gca,'XTick', [0:0.1:2], 'TickDir', 'out', 'box', 'off'); xlim([0 ts(95)]);
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
        set(gca,'Ydir','normal'); axis off;
end