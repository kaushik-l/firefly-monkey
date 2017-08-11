function PlotBehaviour(behv,plot_type,prs)

maxtrls = 200; %prs.maxtrls; % maximum #trials to plot
rewardwin = prs.rewardwin;
maxrewardwin = prs.maxrewardwin;
bootstrap_trl = prs.bootstrap_trl;
Fs = prs.fs_smr/prs.factor_downsample;

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
        figure; hold on;
        r_fly = behv.stats.pos_final.r_fly(~crazy);
        r_monk = behv.stats.pos_final.r_monk(~crazy);
        if ntrls_all > maxtrls
            trl_indx = randperm(ntrls_all);
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
        if ntrls_all > maxtrls
            trl_indx = randperm(ntrls_all);
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
        removeaxes;
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
        removeaxes;
    case 'example_trial'
        trials = behv.trials(correct);
        r_fly = behv.stats.pos_final.r_fly(correct);
        theta_fly = behv.stats.pos_final.theta_fly(correct)*pi/180;
        x_fly = r_fly.*sin(theta_fly); % convert to cartesian 
        y_fly = r_fly.*cos(theta_fly);
        x_monk = behv.stats.pos_abs.x_monk(correct);
        y_monk = behv.stats.pos_abs.y_monk(correct);
        %% choose a random trial
        indx = 2122; %randsample(1:ntrls_correct, 1);
        % position
        x_monk = x_monk{indx}(5:end); y_monk = y_monk{indx}(5:end) + 37.5;
        x_fly = x_fly(indx); y_fly = y_fly(indx);
        % velocity
        v = trials(indx).v;
        w = trials(indx).w;
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
        box off; axis equal; axis([-250 250 -50 450]); removeaxes;
        nt = length(v);
        t = linspace(0,nt/Fs,nt);
        z = zeros(size(t));
        col = t;
        figure; hold on;set(gca,'Fontsize',14);
        xlabel('time'); ylabel('Linear speed');
        surface([t;t],[v';v'],[z;z],[col;col],'edgecol','interp','linew',4);
        removeaxes;
        figure; hold on; set(gca,'Fontsize',14);
        xlabel('time'); ylabel('Angular speed');
        surface([t;t],[w';w'],[z;z],[col;col],'facecol','no','edgecol','interp','linew',4);
        removeaxes;
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
        figure;
        plot(pCorrect_shuffled_mu,pCorrect,'k');
        xlabel('Shuffled accuracy'); ylabel('Actual accuracy');
        lessticks('x'); lessticks('y');
end