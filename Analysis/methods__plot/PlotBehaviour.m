function PlotBehaviour(behv,plot_type,prs)

maxtrls = 2000; %prs.maxtrls; % maximum #trials to plot
rewardwin = prs.rewardwin;
maxrewardwin = prs.maxrewardwin;
bootstrap_trl = prs.bootstrap_trl;
Fs = prs.fs_smr/prs.factor_downsample;
ncorrbins = prs.ncorrbins;

%% combine behaviour from all sessions
if length(behv) > 1, behv = CombineBehv(behv); end

%% behavioural data
correct = behv.stats.trialtype.reward(strcmp({behv.stats.trialtype.reward.val},'rewarded')).trlindx;
incorrect = behv.stats.trialtype.reward(strcmp({behv.stats.trialtype.reward.val},'unrewarded')).trlindx;
crazy = ~(correct | incorrect); ntrls = sum(~crazy);
behv_correct = behv.trials(correct); ntrls_correct = length(behv_correct);
behv_incorrect = behv.trials(incorrect); ntrls_incorrect = length(behv_incorrect);

%% plot
switch plot_type
    case 'distance'
        figure; hold on;
        r_fly = behv.stats.pos_final.r_fly(~crazy);
        r_monk = behv.stats.pos_final.r_monk(~crazy);
        if ntrls > maxtrls
            trl_indx = randperm(ntrls);
            trl_indx = trl_indx(1:maxtrls);
            plot(r_fly(trl_indx), r_monk(trl_indx), '.','Color',[.5 .5 .5],'markersize',2);
%             [b, a, bint, aint, r, p]=regress_perp(r_fly(trl_indx)',r_monk(trl_indx)',0.05,2)
        else
            plot(r_fly, r_monk, '.k');
        end
        axis([0 400 0 400]);
        plot(0:400,0:400,'--k','Linewidth',1);
        set(gca, 'XTick', [0 200 400], 'XTickLabel', [0 2 4], 'Fontsize',14);
        xlabel('Target, r(m)');
        set(gca, 'YTick', [0 200 400], 'YTickLabel', [0 2 4]);
        ylabel('Response, r(m)');
    case 'angle'
        figure; hold on;
        theta_fly = behv.stats.pos_final.theta_fly(~crazy);
        theta_monk = behv.stats.pos_final.theta_monk(~crazy);
        if ntrls > maxtrls
            trl_indx = randperm(ntrls);
            trl_indx = trl_indx(1:maxtrls);
            plot(theta_fly(trl_indx), theta_monk(trl_indx), '.','Color',[.5 .5 .5],'markersize',2);
%             [b, a, bint, aint, r, p]=regress_perp(theta_fly(trl_indx)',theta_monk(trl_indx)',0.05,2)
        else
            plot(theta_fly, theta_monk, '.k');
        end
        axis([-40 40 -40 40]);
        plot(-40:40,-40:40,'--k','Linewidth',1);
        set(gca, 'XTick', [-40 0 40], 'XTickLabel', [-40 0 40], 'Fontsize',14);
        xlabel('Target, \theta(deg)');
        set(gca, 'YTick', [-40 0 40], 'YTickLabel', [-40 0 40]);
        ylabel('Response, \theta(deg)');
        hline(0, 'k'); vline(0, 'k');
        removeaxes;
    case 'targets'
        figure;
        r_fly = behv.stats.pos_final.r_fly(~crazy);
        theta_fly = behv.stats.pos_final.theta_fly(~crazy)*pi/180;
        indx = find(r_fly>100 & r_fly<400 & theta_fly>-0.7 & theta_fly<0.7); % clean up
        r_fly = r_fly(indx); theta_fly = theta_fly(indx);
        x_fly = r_fly.*sin(theta_fly); y_fly = r_fly.*cos(theta_fly); % convert to cartesian
        ntrls = length(x_fly);
        if ntrls > maxtrls
            trl_indx = randperm(ntrls);
            trl_indx = trl_indx(1:maxtrls);
            plot(x_fly(trl_indx), y_fly(trl_indx), '.k','markersize',2);
        else
            plot(x_fly, y_fly, '.k');
        end
        box off; axis([-250 250 -50 450]);
        set(gca, 'XTick', -200:100:200, 'XTickLabel', -2:2, 'Fontsize',14);
        xlabel('x (m)');
        set(gca, 'YTick', 0:100:400, 'YTickLabel', 0:4);
        ylabel('y (m)');
%         removeaxes;
    case 'trajectories'
        figure; hold on;
        x_monk = behv.stats.pos_abs.x_monk(correct);
        y_monk = behv.stats.pos_abs.y_monk(correct);
        if ntrls_correct > maxtrls
            trl_indx = randperm(ntrls_correct);
            trl_indx = trl_indx(1:maxtrls);
            x_monk = x_monk(trl_indx); y_monk = y_monk(trl_indx);
            for i=1:maxtrls, plot(x_monk{i}(10:end), y_monk{i}(10:end), ...
                    'Color', [.5 .5 .5],'Linewidth',0.1); end
        else
            for i=1:ntrls_correct, plot(x_monk{i}(10:end), y_monk{i}(10:end), ...
                    'Color', [.5 .5 .5],'Linewidth',0.1); end
        end
        box off; axis([-250 250 -50 450]);
        set(gca, 'XTick', -200:100:200, 'XTickLabel', -2:2, 'Fontsize',14);
        xlabel('x (m)');
        set(gca, 'YTick', 0:100:400, 'YTickLabel', 0:4);
        ylabel('y (m)');
%         removeaxes;
    case 'example_trial'
        trials = behv.trials(correct);
        r_fly = behv.stats.pos_final.r_fly(correct);
        theta_fly = behv.stats.pos_final.theta_fly(correct)*pi/180;
        x_fly = r_fly.*sin(theta_fly); % convert to cartesian 
        y_fly = r_fly.*cos(theta_fly);
        x_monk = behv.stats.pos_abs.x_monk(correct);
        y_monk = behv.stats.pos_abs.y_monk(correct);
        %% choose a random trial
        indx = randsample(1:ntrls_correct, 1);
        % position
        x_monk = x_monk{indx}(5:end); y_monk = y_monk{indx}(5:end) + 37.5;
        x_fly = x_fly(indx); y_fly = y_fly(indx);
        % velocity
        v = trials(indx).continuous.v;
        w = trials(indx).continuous.w;
        %% plot
        figure; hold on;
        nt = length(x_monk);
        t = linspace(0,nt/Fs,nt);        
        z = zeros(size(t));
        col = t;  % This is the color, vary with time (t) in this case.        
        set(gca,'Fontsize',14);
        title(['trial #' num2str(indx)]);
        % plot target location
        scatter(x_fly,y_fly,20,'or','filled');
        % draw circle to denote reward zone
        t2 = linspace(0,2*pi);plot(65*cos(t2)+x_fly,65*sin(t2)+y_fly);
        % plot trajectory
        surface([x_monk';x_monk'],[y_monk';y_monk'],[z;z],[col;col],...
            'edgecol','interp','linew',2); 
        box off; axis equal; axis([-250 250 -50 450]); %removeaxes;
        nt = length(v);
        t = linspace(0,nt/Fs,nt);
        z = zeros(size(t));
        col = t;
        figure; hold on;set(gca,'Fontsize',14);
        xlabel('time'); ylabel('Linear speed');
        surface([t;t],[v';v'],[z;z],[col;col],'edgecol','interp','linew',4);
%         removeaxes;
        figure; hold on; set(gca,'Fontsize',14);
        xlabel('time'); ylabel('Angular speed');
        surface([t;t],[w';w'],[z;z],[col;col],'facecol','no','edgecol','interp','linew',4);
%         removeaxes;
        % plot eye movements
        figure; hold on; plot(t,trials(indx).continuous.zle); plot(t,trials(indx).continuous.zre); ylim([-30 30]);
        figure; hold on; plot(t,trials(indx).continuous.yle); plot(t,trials(indx).continuous.yre); ylim([-30 30]);
    case 'ROC'
        rewardwin = behv.stats.accuracy.rewardwin;
        pCorrect = behv.stats.accuracy.pCorrect;
        pCorrect_shuffled_mu = behv.stats.accuracy.pCorrect_shuffled_mu;
        figure; hold on;
        plot(rewardwin,pCorrect,'k');
        plot(rewardwin,pCorrect_shuffled_mu,'Color',[.5 .5 .5]);
        xlabel('Hypothetical reward window (m)'); ylabel('Fraction of rewarded trials');
        lessticks('x'); lessticks('y');
        % ROC curve
        figure; hold on;
        plot(pCorrect_shuffled_mu,pCorrect,'k');
        xlabel('Shuffled accuracy'); ylabel('Actual accuracy');
        lessticks('x'); lessticks('y');
    case 'saccade'
        trials = behv.trials(~crazy);        
        for i=1:length(trials)
            t_sac(i).t_beg = trials(i).events.t_sac;
            t_stop = trials(i).events.t_stop;
            if ~isempty(t_stop)
                t_sac(i).t_stop = trials(i).events.t_sac - t_stop;
            else
                t_sac(i).t_stop = [];
            end
        end
        t_sac_beg = cell2mat({t_sac.t_beg}');
        t_sac_stop = cell2mat({t_sac.t_stop}');        
        %% bootstrap
        % saccade relative to trial onset
        ts_beg = linspace(-1,3,100); psac = [];
        for i=1:1000
            indx = randperm(length(t_sac_beg)); indx = indx(1:2000);
            [psac(i,:),~] = hist(t_sac_beg(indx),ts_beg);
        end
        psac_beg_mu = mean(psac);
        psac_beg_sig = std(psac);        
        % saccade relative to stopping time
        ts_stop = linspace(-2,2,100); psac = [];
        for i=1:1000
            indx = randperm(length(t_sac_stop)); indx = indx(1:2000);
            [psac(i,:),~] = hist(t_sac_stop(indx),ts_stop);
        end
        psac_stop_mu = mean(psac);
        psac_stop_sig = std(psac);
        
        %% plot saccade hist
        figure; hold on;
        shadedErrorBar(ts_beg,psac_beg_mu,psac_beg_sig);
        axis([-0.2 2 0 150]);
        figure; hold on;
        shadedErrorBar(ts_stop,psac_stop_mu,psac_stop_sig);
        axis([-1 0.6 0 150]);
    case 'gaze_beg'
        trials = behv.trials(~crazy);
        r_fly = behv.stats.pos_rel.r_targ(~crazy);
        theta_fly = behv.stats.pos_rel.theta_targ(~crazy);
        x_reye = behv.stats.pos_rel.x_leye(~crazy);
        y_reye = behv.stats.pos_rel.y_leye(~crazy);
        figure; hold on;
        for i=1:ntrls
            t_sac = trials(i).events.t_sac; t_sac = t_sac(t_sac>0 & t_sac<0.3);
            if ~isempty(t_sac)
                t_sac = t_sac(1);
                ts = trials(i).continuous.ts; t_indx = find(ts>t_sac+0.05,1);
                r_eye = sqrt(x_reye{i}.^2 + y_reye{i}.^2);
                plot(r_fly{i}(t_indx),r_eye(t_indx),'.','Color',[.5 .5 .5],'markersize',2);
            else
                r_eye = sqrt(x_reye{i}.^2 + y_reye{i}.^2);
                plot(r_fly{i}(50),0.8*r_eye(50),'.','Color',[.5 .5 .5],'markersize',2);
            end
        end
        axis([0 500 0 500]);
        plot(0:400,0:400,'--k');
        xlabel('Target distance (m)'); ylabel('Gaze distance (m)');
        lessticks('x'); lessticks('y');
        % plot angle
        figure; hold on;
        for i=1:ntrls
            t_sac = trials(i).events.t_sac; t_sac = t_sac(t_sac>0 & t_sac<0.3);
            if ~isempty(t_sac)
                t_sac = t_sac(1);
                ts = trials(i).continuous.ts; t_indx = find(ts>t_sac+0.05,1);
                theta_eye = atan2d(x_reye{i}(t_indx),y_reye{i}(t_indx));
                plot(theta_fly{i}(t_indx),2*theta_eye,'.','Color',[.5 .5 .5],'markersize',2);
            else
                theta_eye = atan2d(x_reye{i}(50),y_reye{i}(50));
                plot(theta_fly{i}(50),1.7*theta_eye,'.','Color',[.5 .5 .5],'markersize',2);
            end
        end
        axis([-50 50 -50 50]);
        plot(-50:50,-50:50,'--k');
        xlabel('Target angle (deg)'); ylabel('Gaze angle (deg)');
        lessticks('x'); lessticks('y');
        hline(0, 'k'); vline(0, 'k');
%         removeaxes;
    case 'gaze_temporal'
        trials = behv.trials(~crazy);
        r_fly = behv.stats.pos_rel.r_targ(~crazy);
        x_reye = behv.stats.pos_rel.x_leye(~crazy);
        y_reye = behv.stats.pos_rel.y_leye(~crazy);
        figure; hold on;
        for i=1:ntrls
            t_sac = trials(i).events.t_sac; t_sac = t_sac(t_sac>0 & t_sac<0.3);
            if ~isempty(t_sac)
                t_sac = t_sac(1);
                ts = trials(i).continuous.ts; t_indx = find(ts>t_sac+0.05);
                r_eye = sqrt(x_reye{i}.^2 + y_reye{i}.^2);
                plot(ts,r_eye,'Color',[.5 .5 .5],'markersize',2);
            end
        end
        axis([0 3 0 500]);
        % plot distance to fly
        figure; hold on;
        for i=1:ntrls
            t_sac = trials(i).events.t_sac; t_sac = t_sac(t_sac>0 & t_sac<0.3);
            if ~isempty(t_sac)
                t_sac = t_sac(1);
                ts = trials(i).continuous.ts; t_indx = find(ts>t_sac+0.05);
                plot(ts,r_fly{i},'Color',[.5 .5 .5],'markersize',2);
            end
        end
        axis([0 3 0 500]);
        % plot gaze distance vs dist2fly
        figure; hold on;
        for i=1:ntrls
            t_sac = trials(i).events.t_sac; t_sac = t_sac(t_sac>0 & t_sac<0.3);
            if ~isempty(t_sac)
                t_sac = t_sac(1);
                ts = trials(i).continuous.ts; t_indx = find(ts>t_sac+0.05);
                r_eye = sqrt(x_reye{i}.^2 + y_reye{i}.^2);
                plot(r_fly{i}(t_indx),r_eye(t_indx),'Color',[.5 .5 .5],'markersize',2);
            end
        end
        axis([0 500 0 500]);
    case 'gaze_corr'
        indx = ~crazy;
        trials = behv.trials(indx);
        r_fly = behv.stats.pos_rel.r_fly(indx);
        theta_fly = behv.stats.pos_rel.theta_fly(indx);
        x_reye = behv.stats.pos_rel.x_reye(indx);
        y_reye = behv.stats.pos_rel.y_reye(indx);
        count = 0;
        for i=1:ntrls
           t_sac = trials(i).t_sac; t_sac = t_sac(t_sac>0 & t_sac<0.5);
           T = trials(i).t_end - trials(i).t_beg;
           if ~isempty(trials(i).t_stop), T_end = T - trials(i).t_stop; end
           if ~isempty(t_sac) && T>1.5 && T_end>0.4 && trials(i).t_stop>0.3
               count = count+1;
               % until target off
               ts = trials(i).ts; t_indx = find(ts<0.3);
               r_eye = sqrt(x_reye{i}.^2 + y_reye{i}.^2);
               r_fly2 = rebin(ts(t_indx),r_fly{i}(t_indx),15);
               r_eye2 = rebin(ts(t_indx),r_eye(t_indx),15);
               % until end of movement
               ts = trials(i).ts; t_indx = find(ts>0.3 & ts<trials(i).t_stop);
               r_eye = sqrt(x_reye{i}.^2 + y_reye{i}.^2);
               r_fly2 = [r_fly2 rebin(ts(t_indx),r_fly{i}(t_indx),ncorrbins)];
               r_eye2 = [r_eye2 rebin(ts(t_indx),r_eye(t_indx),ncorrbins)];
               % 300ms beyond
               ts = trials(i).ts; t_indx = find(ts>trials(i).t_stop & ts<trials(i).t_stop+0.4);
               r_fly_mat(count,:) = [r_fly2 rebin(ts(t_indx),r_fly{i}(t_indx),20)];
               r_eye_mat(count,:) = [r_eye2 rebin(ts(t_indx),r_eye(t_indx),20)];
           end
        end
        r_eye_mat(r_eye_mat>1e3) = nan;
        nt = size(r_eye_mat,2);        
        %% bootstrap
        for k=1:bootstrap_trl
            indx = randperm(size(r_eye_mat,1)); indx = indx(1:300);
            r_eye_mat2 = r_eye_mat(indx,:); r_fly_mat2 = r_fly_mat(indx,:);
            for j=1:nt
                if sum(~isnan(r_fly_mat2(:,j)) & ~isnan(r_eye_mat2(:,j)))>100 % minimum 100 trials
                    corr_temp = corrcoef(r_fly_mat2(:,j),r_eye_mat2(:,j),'rows','complete');
                    corr_gazefly(k,j) = corr_temp(1,2);
                else
                    corr_gazefly(k,j) = nan;
                end
            end
        end
        corr_gazefly_mu = nanmean(corr_gazefly);
        corr_gazefly_sig = nanstd(corr_gazefly);
        hold on; shadedErrorBar(1:135,corr_gazefly_mu,corr_gazefly_sig);
    case 'gaze_corr2'
        trials = behv.trials(~crazy);
        r_fly = behv.stats.pos_rel.r_fly(~crazy);
        theta_fly = behv.stats.pos_rel.theta_fly(~crazy);
        x_reye = behv.stats.pos_rel.x_leye(~crazy);
        y_reye = behv.stats.pos_rel.y_leye(~crazy);

        r_fly = cell2matspecial(r_fly);
        x_reye = cell2matspecial(x_reye);
        y_reye = cell2matspecial(y_reye);
        r_eye = sqrt(x_reye.^2 + y_reye.^2);
        r_eye(r_eye>1e3) = nan;
        
        nt = size(r_eye,2);
        for j=1:nt
            if sum(~isnan(r_fly(:,j)) & ~isnan(r_eye(:,j)))>100 % minimum 100 trials
                corr_temp = corrcoef(r_fly(:,j),r_eye(:,j),'rows','complete');
                corr_gazefly(j) = corr_temp(1,2);
            else
                corr_gazefly(j) = nan;
            end
        end
        hold on; plot(corr_gazefly);
    case 'vergence'
        fly_ONduration = prs.fly_ONduration;
        saccade_duration = prs.saccade_duration;
        pretrial = prs.pretrial;
        posttrial = prs.posttrial;
        trials = behv.trials(~crazy);
        for i=1:ntrls
            % identify time of target fixation
            sacstart = []; sacend = []; sacampli = [];
            t_sac{i} = trials(i).events.t_sac;
            t_sac2 = t_sac{i};
            ts{i} = trials(i).continuous.ts;
            t_stop(i) = trials(i).events.t_stop;
            zle{i} = trials(i).continuous.zle;
            yle{i} = trials(i).continuous.yle;
            zre{i} = trials(i).continuous.zre;
            yre{i} = trials(i).continuous.yre;
            sac_indx = t_sac{i}>0 & t_sac{i}<2*fly_ONduration;
            if any(sac_indx)
                t_sacs = t_sac{i}(sac_indx);
                for j=1:length(t_sacs)
                    sacstart(j) = find(ts{i}>(t_sacs(j)), 1);
                    sacend(j) = find(ts{i}>(t_sacs(j) + saccade_duration), 1);
                    sacampli(j) = nanmean([sum(abs(zle{i}(sacstart(j)) - zle{i}(sacend(j)))^2 + abs(yle{i}(sacstart(j)) - yle{i}(sacend(j)))^2) ...
                        sum(abs(zre{i}(sacstart(j)) - zre{i}(sacend(j)))^2 + abs(yre{i}(sacstart(j)) - yre{i}(sacend(j)))^2)]);
                end
                t_fix(i) = t_sacs(sacampli == max(sacampli)) + saccade_duration/2;
            else, t_fix(i) = 0 + saccade_duration/2;
            end % if no saccade detected, assume monkey was already fixating on target
            % remove saccade periods from eye position data
            sacstart = []; sacend = [];
            for j=1:length(t_sac2)
                sacstart(j) = find(ts{i}>(t_sac2(j) - saccade_duration/2), 1);
                sacend(j) = find(ts{i}>(t_sac2(j) + saccade_duration/2), 1);
%                 xt{i}(sacstart(j):sacend(j)) = nan;  % fly x - position
                yle{i}(sacstart(j):sacend(j)) = nan; % left eye horizontal position
                yre{i}(sacstart(j):sacend(j)) = nan; % right eye horizontal position
%                 yt{i}(sacstart(j):sacend(j)) = nan;  % fly y - position
                zle{i}(sacstart(j):sacend(j)) = nan; % left eye vertical position
                zre{i}(sacstart(j):sacend(j)) = nan; % right eye vertical position
            end
%             t_fix(i) = 0;
            pretrial = 0; posttrial = 0;
            % select data between target fixation and end of movement
%             xt{i} = x_fly{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial)); yt{i} = y_fly{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial));
%             xt{i}(isnan(xt{i})) = xt{i}(find(~isnan(xt{i}),1)); yt{i}(isnan(yt{i})) = yt{i}(find(~isnan(yt{i}),1));
            yle{i} = yle{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial)); yre{i} = yre{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial));
            zle{i} = zle{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial)); zre{i} = zre{i}(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial));
            
            % actual eye position
            ver_mean{i} = nanmean([zle{i} , zre{i}],2); % mean vertical eye position (of the two eyes)
            hor_mean{i} = nanmean([yle{i} , yre{i}],2); % mean horizontal eye position
            ver_diff{i} = 0.5*(zle{i} - zre{i}); % 0.5*difference between vertical eye positions (of the two eyes)
            hor_diff{i} = 0.5*(yle{i} - yre{i}); % 0.5*difference between horizontal eye positions
            % fly position
%             rt{i} = sqrt(xt{i}.^2 + yt{i}.^2);
%             thetat{i} = atan2d(xt{i},yt{i});
        end
        %%
%         figure; hold on;
%         for i=1:ntrls
%             plot((1/Fs)*(1:length(hor_diff{i})),hor_diff{i},'Color',[0.5 0.5 0.5]);
%             if ~isempty(hor_diff{i})
%                 plot((1/Fs)*1,hor_diff{i}(find(~isnan(hor_diff{i}),1)),'.b');
%                 plot((1/Fs)*length(hor_diff{i}),hor_diff{i}(find(~isnan(hor_diff{i}),1,'last')),'.r');
%             end
%         end
%         ylim([-4 4]);
        %%
        hor_diff_beg = nan(ntrls,1); hor_diff_end = nan(ntrls,1);
        for i=1:ntrls
            if ~isempty(hor_diff{i})
                hor_diff_beg(i) = hor_diff{i}(find(~isnan(hor_diff{i}),1));
                hor_diff_end(i) = hor_diff{i}(find(~isnan(hor_diff{i}),1,'last'));
            end
        end
        figure; hold on;
        [F,X,FLO,FUP] = ecdf(hor_diff_beg);
        shadedErrorBar(X+0.5,F,[F-FLO FUP-F],'lineprops','-b');
        [F,X,FLO,FUP] = ecdf(hor_diff_end);
        shadedErrorBar(X+0.5,F,[F-FLO FUP-F],'lineprops','-r');
        axis([0 4 0 1]);
    case 'left_right'
        trials = behv.trials(~crazy);
        x_reye = behv.stats.pos_rel.x_reye(~crazy);
        y_reye = behv.stats.pos_rel.y_reye(~crazy);
        x_leye = behv.stats.pos_rel.x_leye(~crazy);
        y_leye = behv.stats.pos_rel.y_leye(~crazy);
        figure; hold on;
        for i=1:ntrls
            t_sac = trials(i).t_sac; t_sac = t_sac(t_sac>0 & t_sac<0.3);
            if ~isempty(t_sac)
                t_sac = t_sac(1);
                ts = trials(i).ts; t_indx = find(ts>t_sac+0.05,1);
                r_reye = sqrt(x_reye{i}.^2 + y_reye{i}.^2);
                r_leye = sqrt(x_leye{i}.^2 + y_leye{i}.^2);
                plot(r_leye(t_indx),1.2*r_reye(t_indx),'.','Color',[.5 .5 .5],'markersize',2);
            else
                r_reye = sqrt(x_reye{i}.^2 + y_reye{i}.^2);
                r_leye = sqrt(x_leye{i}.^2 + y_leye{i}.^2);
                plot(r_leye(50),r_reye(50),'.','Color',[.5 .5 .5],'markersize',2);
            end
        end
        axis([0 400 0 400]); plot(0:400,0:400,'--k');
        xlabel('gaze distance [monocular] (m)');
        ylabel('gaze distance [binocular] (m)');
    case 'ptb_distance'
        r_fly = behv.stats.pos_final.r_fly(~crazy);
        r_monk = behv.stats.pos_final.r_monk(~crazy);
        ptb_indx = [behv_all.ptb_delay] ~= 0;
        ptb_lin = [behv_all.ptb_linear];
        ptb_ang = [behv_all.ptb_angular];
        % data without ptb
        figure; hold on; 
        plot(r_fly(~ptb_indx),r_monk(~ptb_indx),'.b');        
        axis([0 400 0 400]);
        plot(0:400,0:400,'--k','Linewidth',1);
        set(gca, 'XTick', [0 200 400], 'XTickLabel', [0 2 4], 'Fontsize',14);
        xlabel('Target, r(m)');
        set(gca, 'YTick', [0 200 400], 'YTickLabel', [0 2 4]);
        ylabel('Response, r(m)');
        % data with ptb
        hold on;
        plot(r_fly(ptb_indx),r_monk(ptb_indx),'.r');
        axis([0 400 0 400]);
        plot(0:400,0:400,'--k','Linewidth',1);
        set(gca, 'XTick', [0 200 400], 'XTickLabel', [0 2 4], 'Fontsize',14);
        xlabel('Target, r(m)');
        set(gca, 'YTick', [0 200 400], 'YTickLabel', [0 2 4]);
        ylabel('Response, r(m)');
    case 'ptb_angle'
        theta_fly = behv.stats.pos_final.theta_fly(~crazy);
        theta_monk = behv.stats.pos_final.theta_monk(~crazy);
        ptb_indx = [behv_all.ptb_delay] ~= 0;
        % data without ptb
        figure; hold on;
        plot(theta_fly(~ptb_indx),theta_monk(~ptb_indx),'.b');
        axis([-40 40 -40 40]);
        plot(-40:40,-40:40,'--k','Linewidth',1);
        set(gca, 'XTick', [-40 0 40], 'XTickLabel', [-40 0 40], 'Fontsize',14);
        xlabel('Target, \theta(deg)');
        set(gca, 'YTick', [-40 0 40], 'YTickLabel', [-40 0 40]);
        ylabel('Response, \theta(deg)');
        hline(0, 'k'); vline(0, 'k');
%         removeaxes;
        % data with ptb
        hold on;
        plot(theta_fly(ptb_indx),theta_monk(ptb_indx),'.r');
        axis([-40 40 -40 40]);
        plot(-40:40,-40:40,'--k','Linewidth',1);
        set(gca, 'XTick', [-40 0 40], 'XTickLabel', [-40 0 40], 'Fontsize',14);
        xlabel('Target, \theta(deg)');
        set(gca, 'YTick', [-40 0 40], 'YTickLabel', [-40 0 40]);
        ylabel('Response, \theta(deg)');
        hline(0, 'k'); vline(0, 'k');
%         removeaxes;
end