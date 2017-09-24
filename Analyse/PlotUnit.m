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
% ptb data
ptb_delay = [behv_all.ptb_delay]; ptb_delay = ptb_delay/1000; % in secs
ptb_indx = (ptb_delay~=0);
ptb_linear = [behv_all.ptb_linear];
ptb_angular = [behv_all.ptb_angular];

switch plot_type
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
        set(gca,'Ydir','normal'); axis([0 4 100 1400]); %axis off;
        
    case 'rate_end'
        %% psth - aligned to end of trial
        % find longest trial
        nspk2end = struct2mat(spks_all,'nspk2end','end');
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
        set(gca,'Ydir','normal'); axis([-4 0 100 ntrls_all]); axis off;
        plot(t_com,1:size(nspk2end,1));
        
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
end