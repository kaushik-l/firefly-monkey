%% static parameters
delta = 3.5/2; % IOD = 2*delta
z = -100;

%% target location
r = linspace(15,600,93); % cm
th = linspace(-40,40,21); % deg
[R,TH] = meshgrid(r,th);
Y = R./sqrt(1 + tand(TH).^2);
X = Y.*tand(TH);

%% theoretical predictions for eye position as a function of the centre of target location
yle_pred = atan2d(X + delta, sqrt(Y.^2 + z^2));
yre_pred = atan2d(X - delta, sqrt(Y.^2 + z^2));
zle_pred = atan2d(z , sqrt(Y.^2 + (X + delta).^2));
zre_pred = atan2d(z , sqrt(Y.^2 + (X - delta).^2));
ver_mean_pred = 0.5*(zle_pred + zre_pred); % mean vertical eye position (of the two eyes)
hor_mean_pred = 0.5*(yle_pred + yre_pred); % mean horizontal eye position
ver_diff_pred = 0.5*(zle_pred - zre_pred); % 0.5*difference between vertical eye positions (of the two eyes)
hor_diff_pred = 0.5*(yle_pred - yre_pred); % 0.5*difference between horizontal eye positions

%% plot
figure; hold on;set(gcf,'Position',[85 276 1000 300]);

cmap = gray(size(R,1));
subplot(1,3,1); hold on;
for i=1:size(R,1), plot(R(i,:),ver_mean_pred(i,:),'Color',cmap(end-i+1,:)); end
xlabel('Target distance (cm)'); ylabel('Elevation (deg)');

cmap = gray(size(TH,2));
subplot(1,3,2); hold on;
for i=1:size(TH,2), plot(TH(:,i),hor_mean_pred(:,i),'Color',cmap(i,:)); end
xlabel('Target angle (deg)'); ylabel('Lateral version (deg)');

cmap = gray(size(R,1));
subplot(1,3,3); hold on;
for i=1:size(R,1), plot(R(i,:),hor_diff_pred(i,:),'Color',cmap(i,:)); end
xlabel('Target distance (cm)'); ylabel('Vergence (deg)');

%% visual angle subtended by a circular target
targ_radius = 20; %cm

yle_pred_right = atan2d(X + delta + targ_radius, sqrt(Y.^2 + z^2)); yle_pred_left = atan2d(X + delta - targ_radius, sqrt(Y.^2 + z^2));
yre_pred_right = atan2d(X - delta + targ_radius, sqrt(Y.^2 + z^2)); yre_pred_left = atan2d(X - delta - targ_radius, sqrt(Y.^2 + z^2));
yle_pred_visualangle = yle_pred_right - yle_pred_left;
yre_pred_visualangle = yre_pred_right - yre_pred_left;

zle_pred_top = atan2d(z , sqrt((Y + targ_radius).^2 + (X + delta).^2)); zle_pred_bottom = atan2d(z , sqrt((Y - targ_radius).^2 + (X + delta).^2));
zre_pred_top = atan2d(z , sqrt((Y + targ_radius).^2 + (X - delta).^2)); zre_pred_bottom = atan2d(z , sqrt((Y - targ_radius).^2 + (X - delta).^2));
zle_pred_visualangle = zle_pred_top - zle_pred_bottom;
zre_pred_visualangle = zre_pred_top - zre_pred_bottom;

ver_mean_visualangle = 0.5*(zle_pred_visualangle + zre_pred_visualangle);
hor_mean_visualangle = 0.5*(yle_pred_visualangle + yre_pred_visualangle);
mean_visualarea = (pi/4)*ver_mean_visualangle.*hor_mean_visualangle;

%% plot visual angles and area as a function of target distance
% figure; hold on;set(gcf,'Position',[75 276 700 300]);
% 
% subplot(1,2,1); hold on;
% plot(R(th==0,r>70),ver_mean_visualangle(th==0,r>70),'Color','b'); 
% plot(R(th==0,r>70),hor_mean_visualangle(th==0,r>70),'Color','r');
% set(gca,'YScale','Log'); axis([0 400 0.1 50]);
% xlabel('Target distance (cm)'); ylabel('Visual angle (deg)');
% 
% subplot(1,2,2); hold on;
% plot(R(th==0,r>70),mean_visualarea(th==0,r>70),'Color','k');
% set(gca,'YScale','Log'); axis([0 400 0.1 1000]);
% xlabel('Target distance (cm)'); ylabel('Visual area of the target (deg^2)');

% %% simulate correlation coefficients as a funciton of noise (inversely proportional to mean_visualarea)
% % generate target locations
% ntrls = 1000;
% r_sim = 400*sqrt(rand(1,ntrls)); 
% th_sim = 80*rand(1,ntrls) - 40;
% y_sim = r_sim./sqrt(1 + tand(th_sim).^2);
% x_sim = y_sim.*tand(th_sim);
% keepindx = y_sim>70; x_sim = x_sim(keepindx); y_sim = y_sim(keepindx);
% 
% % generate ground truth predictions for eye positions
% yle_pred = atan2d(x_sim + delta, sqrt(y_sim.^2 + z^2));
% yre_pred = atan2d(x_sim - delta, sqrt(y_sim.^2 + z^2));
% zle_pred = atan2d(z , sqrt(y_sim.^2 + (x_sim + delta).^2));
% zre_pred = atan2d(z , sqrt(y_sim.^2 + (x_sim - delta).^2));
% ver_pred = 0.5*(zle_pred + zre_pred); 
% hor_pred = 0.5*(yle_pred + yre_pred);
% 
% % generate noise veriance as the inverse of the visual area of target
% hor_pred_right = atan2d(x_sim + targ_radius, sqrt(y_sim.^2 + z^2)); hor_pred_left = atan2d(x_sim - targ_radius, sqrt(y_sim.^2 + z^2));
% hor_pred_visualangle = hor_pred_right - hor_pred_left;
% ver_pred_top = atan2d(z , sqrt((y_sim + targ_radius).^2 + (x_sim).^2)); ver_pred_bottom = atan2d(z , sqrt((y_sim - targ_radius).^2 + (x_sim).^2));
% ver_pred_visualangle = ver_pred_top - ver_pred_bottom;
% pred_visualarea = (pi/4)*ver_pred_visualangle.*hor_pred_visualangle;
% ver_noise_variance = 1./pred_visualarea; 
% hor_noise_variance = 1./pred_visualarea;
% 
% % add random noise of different magnitudes
% clear rho pval
% lambda = (0:.7:7).^2;
% for k=1:100
%     for i=1:length(lambda)
%         ver_noise = normrnd(0,lambda(i)*ver_noise_variance);
%         hor_noise = normrnd(0,lambda(i)*hor_noise_variance);
%         ver_obs = ver_pred + ver_noise;
%         hor_obs = hor_pred + hor_noise;
%         rho.hor(i,k) = corr(hor_pred(:),hor_obs(:));
%         rho.ver(i,k) = corr(ver_pred(:),ver_obs(:));
%     end
% end
% figure; h = errorbar(lambda,mean(rho.hor,2),std(rho.hor,[],2),'-b'); h.CapSize = 0;
% hold on; h = errorbar(lambda,mean(rho.ver,2),std(rho.ver,[],2),'-r'); h.CapSize = 0;
% xlabel('Noise level (a.u)'); ylabel('Simulated correlation coefficient');
% 
% ver_noise = normrnd(0,3*ver_noise_variance);
% hor_noise = normrnd(0,3*hor_noise_variance);
% ver_obs = ver_pred + ver_noise;
% hor_obs = hor_pred + hor_noise;
% figure; plot(hor_pred,hor_obs,'.b'); axis([-50 50 -50 50]); hline(0,'k'); vline(0,'k'); box off;
% xlabel('Prediction without noise'); ylabel('Prediction with noise');
% figure; plot(ver_pred,ver_obs,'.r'); axis([-10 1 -10 5]); hline(0,'k'); vline(0,'k'); box off; set(gca,'XAxisLocation','top','YAxisLocation','right');
% xlabel('Prediction without noise'); ylabel('Prediction with noise');
% 
% %% compare simulated and theoretical variances
% dx = 20; dy = 20; varx = 400; vary = 400;
% x = dx-10:dx:dx*20-10; nx = length(x);
% y = -20*dy+10:dy:20*dy-10; y(abs(y)<20) = []; ny = length(y);
% nsamples = 10000;
% for i=1:nx
%     fprintf(['... i = ' num2str(i) '\n']);
%     for j=1:ny
%         % theoretical variance in eye position
%         dEyeVer__dx_sqrd = ((z^2)*(x(i)^2))/(((x(i)^2 + y(j)^2 + z^2)^2)*(x(i)^2 + y(j)^2));
%         dEyeVer__dy_sqrd = ((z^2)*(y(j)^2))/(((x(i)^2 + y(j)^2 + z^2)^2)*(x(i)^2 + y(j)^2));        
%         dEyeHor__dx_sqrd = ((y(j)^2 + z^2))/(((x(i)^2 + y(j)^2 + z^2)^2));
%         dEyeHor__dy_sqrd = ((y(j)^2)*(x(i)^2))/(((x(i)^2 + y(j)^2 + z^2).^2)*(y(j)^2 + z^2));
%         var_eyever.theory(i,j) = (dEyeVer__dx_sqrd*varx + dEyeVer__dy_sqrd*vary);
%         var_eyehor.theory(i,j) = (dEyeHor__dx_sqrd*varx + dEyeHor__dy_sqrd*vary);
%         % simulated variance in eye position
%         xsim = normrnd(x(i),sqrt(varx),[1 nsamples]);
%         ysim = normrnd(y(j),sqrt(vary),[1 nsamples]);
%         zsim = repmat(z,[1 nsamples]);
%         EyeVer = atan2(zsim , sqrt(ysim.^2 + xsim.^2));
%         EyeHor = atan2(xsim, sqrt(ysim.^2 + zsim.^2));
%         var_eyever.simulate(i,j) = var(EyeVer);
%         var_eyehor.simulate(i,j) = var(EyeHor);
%     end
% end
% 
% % plot horizontal variance
% cmap = gray(size(var_eyehor.simulate,1));
% figure; hold on; 
% subplot(2,4,1); hold on; yyaxis right; imagesc(y,x,log10(sqrt(var_eyehor.simulate))); axis([-400 400 0 400]); colormap(hot);
% subplot(2,4,2); hold on; set(gca, 'ColorOrder', cmap); plot(x,sqrt(var_eyehor.simulate(:,1:20))); set(gca,'YScale','Log'); ylim([1e-2 5e-1]);
% subplot(2,4,3); hold on; set(gca, 'ColorOrder', cmap); plot(y,sqrt(var_eyehor.simulate)'); set(gca,'YScale','Log'); ylim([1e-2 5e-1]);
% subplot(2,4,4); hold on; for i=1:20, plot(sqrt(var_eyehor.theory(i,:)),sqrt(var_eyehor.simulate(i,:)),'.k'); end 
% xmax = get(gca,'xlim'); xmax = max(xmax); plot(0:0.01:xmax,0:0.01:xmax,'r'); set(gca,'XScale','Log','YScale','Log');
% subplot(2,4,5); hold on; yyaxis right; imagesc(y,x,log10(sqrt(var_eyehor.theory))); axis([-400 400 0 400]); colormap(hot);
% subplot(2,4,6); hold on; set(gca, 'ColorOrder', cmap); plot(x,sqrt(var_eyehor.theory(:,1:20)),'--'); set(gca,'YScale','Log'); ylim([1e-2 5e-1]);
% subplot(2,4,7); hold on; set(gca, 'ColorOrder', cmap); plot(y,sqrt(var_eyehor.theory)','--'); set(gca,'YScale','Log'); ylim([1e-2 5e-1]);
% 
% % plot vertical variance
% cmap = gray(size(var_eyever.simulate,1));
% figure; hold on; 
% subplot(2,4,1); hold on; yyaxis right; imagesc(y,x,log10(sqrt(var_eyever.simulate))); axis([-400 400 0 400]); colormap(hot);
% subplot(2,4,2); hold on; set(gca, 'ColorOrder', cmap); plot(x,sqrt(var_eyever.simulate(:,1:20))); set(gca,'YScale','Log'); ylim([2e-4 5e-1]);
% subplot(2,4,3); hold on; set(gca, 'ColorOrder', cmap); plot(y,sqrt(var_eyever.simulate)'); set(gca,'YScale','Log'); ylim([2e-4 5e-1]);
% subplot(2,4,4); hold on; for i=1:20, plot(sqrt(var_eyever.theory(i,:)),sqrt(var_eyever.simulate(i,:)),'.k'); end 
% xmax = get(gca,'xlim'); xmax = max(xmax); plot(0:1e-4:xmax,0:1e-4:xmax,'r'); set(gca,'XScale','Log','YScale','Log');
% subplot(2,4,5); hold on; yyaxis right; imagesc(y,x,log10(sqrt(var_eyever.theory))); axis([-400 400 0 400]); colormap(hot);
% subplot(2,4,6); hold on; set(gca, 'ColorOrder', cmap); plot(x,sqrt(var_eyever.theory(:,1:20)),'--'); set(gca,'YScale','Log'); ylim([2e-4 5e-1]);
% subplot(2,4,7); hold on; set(gca, 'ColorOrder', cmap); plot(y,sqrt(var_eyever.theory)','--'); set(gca,'YScale','Log'); ylim([2e-4 5e-1]);