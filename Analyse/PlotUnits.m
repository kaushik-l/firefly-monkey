function PlotUnits(behv,units,plot_type,prs)

%% parameters
binwidth_abs = prs.binwidth_abs;
binwidth_warp = prs.binwidth_warp;
trlkrnlwidth = prs.trlkrnlwidth;
nunits = length(units);

correct = behv.stats.trlindx.correct;
incorrect = behv.stats.trlindx.incorrect;
crazy = behv.stats.trlindx.crazy;
indx_all = ~crazy;

% behavioural data
behv_all = behv.trials(~crazy); ntrls_all = length(behv_all);
behv_correct = behv.trials(correct); ntrls_correct = length(behv_correct);
behv_incorrect = behv.trials(incorrect); ntrls_incorrect = length(behv_incorrect);

%% population dynamics
switch plot_type
    case 'psth_trial'
        %% psth of all neurons on one trial
        spks_all = units(1).trials(~crazy);
        spks_all = spks_all(indx_all);
        ns_max = length(spks_all(1).relnspk);
        % initialise response matrix (Neurons x Time)
        r = nan(length(prs.goodorder),ns_max);
        k = 0;
        for j=prs.goodorder %1:nunits
            k = k+1;
            % neural data
            spks_all = units(j).trials(~crazy);
            relnspk = nan(ntrls_all,ns_max);
            ts = 1:ns_max;
            for i=1:ntrls_all
                relnspk(i,:) = spks_all(i).relnspk;
            end
            t_com(k) = nanmean(t_com_trial);
            trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
            relnspk = conv2(relnspk, trlkrnl, 'valid');
            relnspk = mean(relnspk)/binwidth_warp; % mean across trials
            relnspk = relnspk/max(relnspk); % normalise psth of individual neurons
            r(k,:) = relnspk;
        end        
        % plot
        figure; imagesc(r); set(gca,'Ydir','normal'); axis off;
        
    case 'density_scatter'
        figure; hold on;
        for i=1:nunits
            stats = units(i).stats;
            p(1) = stats.nspkpeak.density.p(1,2);
            p(2) = stats.nspk2endpeak.density.p(1,2);
            if p(1) < p(2)
                if p(1)<0.005
                    plot(stats.density(1).nspk.mupeak,stats.density(end).nspk.mupeak,'ok','MarkerFaceColor','k');
                else
                    plot(stats.density(1).nspk.mupeak,stats.density(end).nspk.mupeak,'ok');
                end
            else
                if p(2)<0.005
                    plot(stats.density(1).nspk2end.mupeak,stats.density(end).nspk2end.mupeak,'ok','MarkerFaceColor','k');
                else
                    plot(stats.density(1).nspk2end.mupeak,stats.density(end).nspk2end.mupeak,'ok');
                end
            end
        end
        plot(1:1:25,1:1:25,'r'); axis([1 25 1 25]);
        set(gca, 'XScale', 'log');
        set(gca, 'YScale', 'log');
        set(gca,'XTick',[1 10 20]); set(gca,'YTick',[1 10 20]);
        xlabel('log firing rate (lowest density)'); ylabel('log firing rate (highest density)');
        
    case 'reward_scatter'
        figure; hold on;
        for i=1:nunits
            stats = units(i).stats;
            p(1) = stats.nspkpeak.reward.p(1,2);
            p(2) = stats.nspk2endpeak.reward.p(1,2);
            if p(1) < p(2)
                if p(1)<0.005
                    plot(stats.reward(end).nspk.mupeak,stats.reward(1).nspk.mupeak,'ok','MarkerFaceColor','k');
                else
                    plot(stats.reward(end).nspk.mupeak,stats.reward(1).nspk.mupeak,'ok');
                end
            else
                if p(2)<0.005
                    plot(stats.reward(end).nspk2end.mupeak,stats.reward(1).nspk2end.mupeak,'ok','MarkerFaceColor','k');
                else
                    plot(stats.reward(end).nspk2end.mupeak,stats.reward(1).nspk2end.mupeak,'ok');
                end
            end
        end
        plot(1:1:25,1:1:25,'r'); axis([1 25 1 25]);
        set(gca, 'XScale', 'log');
        set(gca, 'YScale', 'log');
        set(gca,'XTick',[1 10 20]); set(gca,'YTick',[1 10 20]);
        xlabel('log firing rate (rewarded)'); ylabel('log firing rate (unrewarded)');
end

for j=1:nunits
    % neural data
    spks_all = units(j).trials(~crazy);    
    % order trials based on trial duration
%     spks_all = spks_all(indx_all);
    switch plot_type
        case 'raster_start'
            %% raster plot - aligned to start of trial
            figure(1); hold on; SubplotArray('multiunits',units(j).channel_no);
            for i=1:ntrls_all
                hold on;
                if ~isempty(spks_all(i).tspk)
                    plot(spks_all(i).tspk(1:3:end),i,'ob','markersize',0.2,'markerFacecolor','b');
                end
            end
            xlim([0 4]); axis off;
            
        case 'raster_end'
            %% raster plot - aligned to end of trial
            figure(2); hold on; SubplotArray('multiunits',units(j).channel_no);
            for i=1:ntrls_all
                hold on;
                if ~isempty(spks_all(i).tspk2end)
                    plot(spks_all(i).tspk2end(1:4:end),i,'ob','markersize',0.2,'markerFacecolor','b');
                end
            end
            xlim([-4 0]); axis off;
            
        case 'raster_warp'
            %% raster plot - normalised by trial duration
            figure(3); hold on; SubplotArray('multiunits',units(j).channel_no);
            for i=1:ntrls_all
                hold on;
                if ~isempty(spks_all(i).reltspk)
                    plot(spks_all(i).reltspk,i,'ob','markersize',0.2,'markerFacecolor','b');
                end
            end
            xlim([0 1]); axis off;
            
        case 'rate_start'
            %% rate - aligned to start of trial
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
            nspk = nspk/binwidth_abs;
            % plot
            figure(4); hold on; SubplotArray('multiunits',units(j).channel_no);
            imagesc(nspk,[0  max(mean(nspk))]);
            set(gca,'Ydir','normal'); %axis off;
            
        case 'rate_end'
            %% rate - aligned to end of trial
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
            trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
            nspk2end = conv2nan(nspk2end, trlkrnl);
            nspk2end = nspk2end/binwidth_abs;
            % plot
            figure(5); hold on; SubplotArray('multiunits',units(j).channel_no);
            imagesc(nspk2end,[0 max(mean(nspk2end))]);
            set(gca,'Ydir','normal'); axis off;
            
        case 'rate_warp'
            %% rate - normalised by trial duration
            ns_max = length(spks_all(1).relnspk);
            relnspk = nan(ntrls_all,ns_max);
            for i=1:ntrls_all
                relnspk(i,:) = spks_all(i).relnspk;
            end
            trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
            relnspk = conv2(relnspk, trlkrnl, 'valid');
            relnspk = relnspk/binwidth_warp;
            % plot
            figure(6); hold on; SubplotArray('multiunits',units(j).channel_no);
            imagesc(relnspk,[0 max(mean(relnspk))]);
            set(gca,'Ydir','normal'); %axis off;
        case 'psth_warp'
            %% same as rate_warp but trial averaged
            ns_max = length(spks_all(1).relnspk);
            relnspk = nan(ntrls_all,ns_max);
            for i=1:ntrls_all
                relnspk(i,:) = spks_all(i).relnspk;
            end
            trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
            relnspk = conv2(relnspk, trlkrnl, 'valid');
            relnspk = mean(relnspk)/binwidth_warp; % mean across trials
            relnspk = relnspk/max(relnspk); % normalise psth of individual neurons
            % plot
            ts = linspace(0,1,length(relnspk));
            figure(7); hold on;
            plot(ts,relnspk,'b'); axis off;
        case 'variance_explained'
            for k=1:length(units)
                unit = units(k);
                
                % neural data
                spks_correct = unit.trials(correct);
                
                vars = fields(unit.weights.mu);
                for i=1:length(vars)
                    weights.(vars{i}) = unit.weights.mu.(vars{i}).data;
                end
                weights.hist = interp1(unit.weights.mu.hist.tr,unit.weights.mu.hist.data,unit.weights.mu.firefly.tr);
                weights.hist(isnan(weights.hist)) = 0;
                % predict
                for i = 1:ntrls_correct
                    % horizontal eye position
                    r_pred(i).eyeh = conv(behv_correct(i).yle,weights.eyepos(:,1),'same');
                    % vertical eye position
                    r_pred(i).eyev = conv(behv_correct(i).zle,weights.eyepos(:,2),'same');
                    % linear velocity
                    r_pred(i).linvel = conv(behv_correct(i).v,weights.linvel,'same');
                    % angular velocity
                    r_pred(i).angvel = conv(behv_correct(i).w,weights.angvel,'same');
                    % target
                    behv_correct(i).firefly = zeros(length(behv_correct(i).ts),1);
                    behv_correct(i).firefly(behv_correct(i).ts>0.2 & behv_correct(i).ts<0.5) = 1;
                    r_pred(i).firefly = conv(behv_correct(i).firefly,weights.firefly,'same');
                    % spike history
                    ts = behv_correct(i).ts;
                    spktrain = zeros(length(behv_correct(i).ts),1);
                    tspk = spks_correct(i).tspk;
                    for j=1:length(tspk)
                        spktrain(abs(ts-tspk(j)) == min(abs(ts-tspk(j)))) = 1;
                    end
                    r_pred(i).hist = conv(spktrain,weights.hist,'same');
                    % full prediction
                    r_pred(i).total = r_pred(i).eyeh + r_pred(i).eyev + r_pred(i).linvel + r_pred(i).angvel + r_pred(i).firefly + r_pred(i).hist;
                end
                
                % data
                nspk = struct2mat(spks_correct,'nspk','start');
                trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
                nspk = conv2nan(nspk, trlkrnl);
                nspk_true = nspk./repmat(nanmean(nspk,2),[1 size(nspk,2)]);
                
                % prediction total
                nspk = struct2mat(r_pred,'total','start');
                trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
                nspk_pred = conv2nan(nspk, trlkrnl);
                nspk_pred = exp(nspk_pred);                
                % variance explained
                varexp_total(k) = 1-mean(nanvar((nspk_pred - nspk_true),[],2)./nanvar(nspk_true,[],2));
                
                % prediction linvel
                nspk = struct2mat(r_pred,'firefly','start');
                trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
                nspk_pred = conv2nan(nspk, trlkrnl);
                nspk_pred = exp(nspk_pred);
                % variance explained
                varexp_ff(k) = 1-mean(nanvar((nspk_pred - nspk_true),[],2)./nanvar(nspk_true,[],2));
                
                % prediction linvel
                nspk = struct2mat(r_pred,'linvel','start');
                trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
                nspk_pred = conv2nan(nspk, trlkrnl);
                nspk_pred = exp(nspk_pred);
                % variance explained
                varexp_v(k) = 1-mean(nanvar((nspk_pred - nspk_true),[],2)./nanvar(nspk_true,[],2));
                
                % prediction angvel
                nspk = struct2mat(r_pred,'angvel','start');
                trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
                nspk_pred = conv2nan(nspk, trlkrnl);
                nspk_pred = exp(nspk_pred);
                % variance explained
                varexp_w(k) = 1-mean(nanvar((nspk_pred - nspk_true),[],2)./nanvar(nspk_true,[],2));
                
                % prediction eye horz
                nspk = struct2mat(r_pred,'eyeh','start');
                trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
                nspk_pred = conv2nan(nspk, trlkrnl);
                nspk_pred = exp(nspk_pred);
                % variance explained
                varexp_eyeh(k) = 1-mean(nanvar((nspk_pred - nspk_true),[],2)./nanvar(nspk_true,[],2));
                
                % prediction eye vert
                nspk = struct2mat(r_pred,'eyev','start');
                trlkrnl = ones(trlkrnlwidth,1)/trlkrnlwidth;
                nspk_pred = conv2nan(nspk, trlkrnl);
                nspk_pred = exp(nspk_pred);
                % variance explained
                varexp_eyev(k) = 1-mean(nanvar((nspk_pred - nspk_true),[],2)./nanvar(nspk_true,[],2));
            end
            x=1;
    end
end