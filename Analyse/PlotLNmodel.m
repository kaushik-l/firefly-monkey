function PlotLNmodel(LNmodels,tuning,tuning_binedges)

%% Description
% This will plot the results of all the preceding analyses: the model
% performance, the model-derived tuning curves, and the firing rate tuning
% curves.

dt = 0.012;
%% plot the tuning curves obtained by binning

% create x-axis vectors
xvals_1 = 0.5*(tuning_binedges(1,1:end-1) + tuning_binedges(1,2:end));
xvals_2 = 0.5*(tuning_binedges(2,1:end-1) + tuning_binedges(2,2:end));
xvals_3 = 0.5*(tuning_binedges(3,1:end-1) + tuning_binedges(3,2:end));

% plot the tuning curves
figure; set(gcf,'Position',[1200 0 1600 800]); hold on;
subplot(3,3,1); box off;
shadedErrorBar(tuning.v.tuning.stim.mu,tuning.v.tuning.rate.mu,tuning.v.tuning.rate.sem,'lineprops',{'r','linewidth',2});
xlabel('linear velocity (cm/s)');
ylabel('Firing rate (spk/s) [BINNING]','Fontsize',12);
% title('Linear Velocity');
subplot(3,3,2); box off;
shadedErrorBar(tuning.w.tuning.stim.mu,tuning.w.tuning.rate.mu,tuning.w.tuning.rate.sem,'lineprops',{'Color',[0 0.75 0.5],'linewidth',2});
xlabel('angular velocity (deg/s)'); xlim([-90 90]);
% title('Angular Velocity');
subplot(3,3,3); box off;
shadedErrorBar(tuning.r_targ.tuning.stim.mu,tuning.r_targ.tuning.rate.mu,tuning.r_targ.tuning.rate.sem,'lineprops',{'b','linewidth',2});
xlabel('distance to target (cm)');
% title('Distance to target (cm)');

%% compute and plot the model-derived response profiles
if ~isnan(LNmodels.selected_model)
    if LNmodels.selected_model==1
        % pull out the parameter values
        param(1,:) = LNmodels.param{LNmodels.selected_model}(1:10);
        param(2,:) = LNmodels.param{LNmodels.selected_model}(11:20);
        param(3,:) = LNmodels.param{LNmodels.selected_model}(21:30);
        % compute the scale factors
        scale_factor_1 = mean(exp(param(2,:)))*mean(exp(param(3,:)))/dt;
        scale_factor_2 = mean(exp(param(1,:)))*mean(exp(param(3,:)))/dt;
        scale_factor_3 = mean(exp(param(1,:)))*mean(exp(param(2,:)))/dt;
        % compute the model-derived response profiles
        r1 = scale_factor_1*exp(param(1,:));
        r2 = scale_factor_2*exp(param(2,:));
        r3 = scale_factor_3*exp(param(3,:));
    elseif LNmodels.selected_model==2
        % pull out the parameter values
        param(1,:) = LNmodels.param{LNmodels.selected_model}(1:10);
        param(2,:) = LNmodels.param{LNmodels.selected_model}(11:20);
        % compute the scale factors
        scale_factor_1 = mean(exp(param(2,:)))/dt;
        scale_factor_2 = mean(exp(param(1,:)))/dt;
        % compute the model-derived response profiles
        r1 = scale_factor_1*exp(param(1,:));
        r2 = scale_factor_2*exp(param(2,:));
        r3 = nan(1,10);
    elseif LNmodels.selected_model==3
        % pull out the parameter values
        param(1,:) = LNmodels.param{LNmodels.selected_model}(1:10);
        param(3,:) = LNmodels.param{LNmodels.selected_model}(11:20);
        % compute the scale factors
        scale_factor_1 = mean(exp(param(3,:)))/dt;
        scale_factor_3 = mean(exp(param(1,:)))/dt;
        % compute the model-derived response profiles
        r1 = scale_factor_1*exp(param(1,:));
        r2 = nan(1,10);
        r3 = scale_factor_3*exp(param(3,:));
    elseif LNmodels.selected_model==4
        % pull out the parameter values
        param(2,:) = LNmodels.param{LNmodels.selected_model}(1:10);
        param(3,:) = LNmodels.param{LNmodels.selected_model}(11:20);
        % compute the scale factors
        scale_factor_2 = mean(exp(param(3,:)))/dt;
        scale_factor_3 = mean(exp(param(2,:)))/dt;
        % compute the model-derived response profiles
        r1 = nan(1,10);
        r2 = scale_factor_2*exp(param(2,:));
        r3 = scale_factor_3*exp(param(3,:));
    elseif LNmodels.selected_model==5
        % pull out the parameter values
        param(1,:) = LNmodels.param{LNmodels.selected_model}(1:10);
        % compute the scale factors
        scale_factor_1 = 1/dt;
        % compute the model-derived response profiles
        r1 = scale_factor_1*exp(param(1,:));
        r2 = nan(1,10);
        r3 = nan(1,10);
    elseif LNmodels.selected_model==6
        % pull out the parameter values
        param(2,:) = LNmodels.param{LNmodels.selected_model}(1:10);
        % compute the scale factors
        scale_factor_2 = 1/dt;
        % compute the model-derived response profiles
        r1 = nan(1,10);
        r2 = scale_factor_2*exp(param(2,:));
        r3 = nan(1,10);
    elseif LNmodels.selected_model==7
        % pull out the parameter values
        param(3,:) = LNmodels.param{LNmodels.selected_model}(1:10);
        % compute the scale factors
        scale_factor_3 = 1/dt;
        % compute the model-derived response profiles
        r1 = nan(1,10);
        r2 = nan(1,10);
        r3 = scale_factor_3*exp(param(3,:));
    end
    % plot the model-derived response profiles
    subplot(3,3,4); box off;
    plot(xvals_1,r1,'r','linewidth',2);
    xlabel('linear velocity (cm/s)');
    ylabel('Firing rate (spk/s) [MODEL]','Fontsize',12);
    % title('Linear Velocity');
    subplot(3,3,5); box off;
    plot(xvals_2,r2,'Color',[0 0.75 0.5],'linewidth',2);
    xlabel('angular velocity (deg/s)'); xlim([-90 90]);
    % title('Angular Velocity');
    subplot(3,3,6); box off
    plot(xvals_3,r3,'b','linewidth',2);
    xlabel('distance to target (cm)');
    % title('Distance to target (cm)');
    
    
    % make the axes match
    subplot(3,3,1)
    caxis([min(min(r1),min(tuning.v.tuning.rate.mu)) max(max(r1),max(tuning.v.tuning.rate.mu))])
    subplot(3,3,4)
    caxis([min(min(r1),min(tuning.v.tuning.rate.mu)) max(max(r1),max(tuning.v.tuning.rate.mu))])
    
    subplot(3,3,2)
    caxis([min(min(r2),min(tuning.w.tuning.rate.mu)) max(max(r2),max(tuning.w.tuning.rate.mu))])
    subplot(3,3,5)
    caxis([min(min(r2),min(tuning.w.tuning.rate.mu)) max(max(r2),max(tuning.w.tuning.rate.mu))])
    
    subplot(3,3,3)
    caxis([min(min(r3),min(tuning.r_targ.tuning.rate.mu)) max(max(r3),max(tuning.r_targ.tuning.rate.mu))])
    subplot(3,3,6)
    caxis([min(min(r3),min(tuning.r_targ.tuning.rate.mu)) max(max(r3),max(tuning.r_targ.tuning.rate.mu))])
end


%% compute and plot the model performances

% ordering:
% pos&hd&spd&theta / pos&hd&spd / pos&hd&th / pos&spd&th / hd&spd&th / pos&hd /
% pos&spd / pos&th/ hd&spd / hd&theta / spd&theta / pos / hd / speed/ theta
testFit_mat = cell2mat(LNmodels.testFit);
LLH_values = reshape(testFit_mat(:,3),10,7);
LLH_increase_mean = mean((LLH_values));
LLH_increase_sem = std((LLH_values))/sqrt(10);
subplot(3,3,7:9);
errorbar(LLH_increase_mean,LLH_increase_sem,'ok','linewidth',3);
hold on;
if ~isnan(LNmodels.selected_model)
    plot(LNmodels.selected_model,LLH_increase_mean(LNmodels.selected_model),'.r','markersize',25);
end
plot(0.5:7.5,zeros(8,1),'--k','linewidth',2);
hold off;
box off;
set(gca,'fontsize',20);
set(gca,'XLim',[0 8]); set(gca,'XTick',1:7);
yrange = get(gca,'Ylim'); yrange = abs(yrange); set(gca,'Ylim',[-max(yrange(1),yrange(2)) max(yrange(1),yrange(2))]);
set(gca,'XTickLabel',{'VWD','VW','VD','WD','V','W','D'});
% legend('Model performance','Selected model','Baseline');
ylabel('Log likelihood increase','Fontsize',12);