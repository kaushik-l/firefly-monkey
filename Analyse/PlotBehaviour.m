function PlotBehaviour(behv,plot_type,prs)

maxtrls = 200; %prs.maxtrls; % maximum #trials to plot
rewardwin = prs.rewardwin;
bootstrap_trl = prs.bootstrap_trl;

%% combine behaviour from all sessions
if length(behv) > 1, behv = CombineBehv(behv); end

%% behavioural data
ntrl = length(behv.trials);
correct = logical(behv.stats.trlindx.correct);
incorrect = logical(behv.stats.trlindx.incorrect);
crazy = logical(behv.stats.trlindx.crazy);

behv_all = behv.trials(~crazy); ntrls_all = length(behv_all);
behv_correct = behv.trials(correct); ntrls_correct = length(behv_correct);
behv_incorrect = behv.trials(incorrect); ntrls_incorrect = length(behv_incorrect);

%% plot
switch plot_type
    case 'distance'
        hold on;
        r_fly = behv.stats.pos_final.r_fly(~crazy);
        r_monk = behv.stats.pos_final.r_monk(~crazy);
        if ntrls_all > maxtrls
            trl_indx = randperm(ntrls_all);
            trl_indx = trl_indx(1:maxtrls);
            plot(r_fly(trl_indx), r_monk(trl_indx), '.k','markersize',2);
        else
            plot(r_fly, r_monk, '.k');
        end
        axis([0 400 0 400]);
        plot(0:400,0:400,'r','Linewidth',1);
        set(gca, 'XTick', [0 200 400], 'XTickLabel', [0 2 4], 'Fontsize',14);
        xlabel('Target, r(m)');
        set(gca, 'YTick', [0 200 400], 'YTickLabel', [0 2 4]);
        ylabel('Response, r(m)');
    case 'angle'
        hold on;
        theta_fly = behv.stats.pos_final.theta_fly(~crazy);
        theta_monk = behv.stats.pos_final.theta_monk(~crazy);
        if ntrls_all > maxtrls
            trl_indx = randperm(ntrls_all);
            trl_indx = trl_indx(1:maxtrls);
            plot(theta_fly(trl_indx), theta_monk(trl_indx), '.k','markersize',2);
        else
            plot(theta_fly, theta_monk, '.k');
        end
        axis([-40 40 -40 40]);
        plot(-40:40,-40:40,'r','Linewidth',1);
        set(gca, 'XTick', [-40 0 40], 'XTickLabel', [-40 0 40], 'Fontsize',14);
        xlabel('Target, \theta(deg)');
        set(gca, 'YTick', [-40 0 40], 'YTickLabel', [-40 0 40]);
        ylabel('Response, \theta(deg)');
        hline(0, 'k'); vline(0, 'k');
        removeaxes;
    case 'accuracy'
        r_fly = behv.stats.pos_final.r_fly(~crazy);
        r_monk = behv.stats.pos_final.r_monk(~crazy);
        theta_fly = pi*abs(behv.stats.pos_final.theta_fly(~crazy))/180;
        theta_monk = pi*abs(behv.stats.pos_final.theta_monk(~crazy))/180;
        ntrls = length(r_fly);
        % actual accuracy
        for i=1:ntrls
            dist2fly(i) = distance([r_fly(i) theta_fly(i)], [r_monk(i) theta_monk(i)], 'polar');
        end
        pCorrect = sum(dist2fly < rewardwin)/ntrls; % fraction of correct trials
        % shuffled estimate
        for j=1:bootstrap_trl
            indx = randperm(ntrls);
            r_monk2 = r_monk(indx); theta_monk2 = theta_monk(indx); % shuffle responses
            % shuffled accuracy
            for i=1:ntrls
                dist2fly_shuffled(i) = distance([r_fly(i) theta_fly(i)], [r_monk2(i) theta_monk2(i)], 'polar');
            end
            pCorrect_shuffled(j) = sum(dist2fly_shuffled < rewardwin)/ntrls;
        end
        pCorrect_shuffled_mu = mean(pCorrect_shuffled);
        pCorrect_shuffled_sig = std(pCorrect_shuffled);
    case 'error'
        r_fly = behv.stats.pos_final.r_fly(~crazy);
        r_monk = behv.stats.pos_final.r_monk(~crazy);
        theta_fly = pi*abs(behv.stats.pos_final.theta_fly(~crazy))/180;
        theta_monk = pi*abs(behv.stats.pos_final.theta_monk(~crazy))/180;
        ntrls = length(r_fly);
        % actual accuracy
        for i=1:ntrls
            dist2fly(i) = distance([r_fly(i) theta_fly(i)], [r_monk(i) theta_monk(i)], 'polar');
        end
        dist2fly_med = median(dist2fly); % median distance to target
        % shuffled estimate
        for j=1:bootstrap_trl
            indx = randperm(ntrls);
            r_monk2 = r_monk(indx); theta_monk2 = theta_monk(indx); % shuffle responses
            % shuffled accuracy
            for i=1:ntrls
                dist2fly_shuffled(i) = distance([r_fly(i) theta_fly(i)], [r_monk2(i) theta_monk2(i)], 'polar');
            end
            dist2fly_shuffled_med(j) = median(dist2fly_shuffled);
        end
        dist2fly_shuffled_iqr = iqr(dist2fly_shuffled_med);
        dist2fly_shuffled_med = median(dist2fly_shuffled_med);
    case 'targets'
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
    case 'trajectories'
        hold on;
        x_monk = behv.stats.pos_abs.x_monk(correct);
        y_monk = behv.stats.pos_abs.y_monk(correct);
        if ntrls_correct > maxtrls
            trl_indx = randperm(ntrls_correct);
            trl_indx = trl_indx(1:maxtrls);
            x_monk = x_monk(trl_indx); y_monk = y_monk(trl_indx);
            for i=1:maxtrls, plot(x_monk{i}(10:end), y_monk{i}(10:end), 'k','Linewidth',0.1); end
        else
            for i=1:ntrls_correct, plot(x_monk{i}(10:end), y_monk{i}(10:end), 'k','Linewidth',0.1); end
        end
end