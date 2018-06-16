% function Plot_Multifirefly

[ts, x_monk, y_monk, X_fly, Y_fly, I_fly, fly_sts] = AddTXTData('m44s728.txt');
files = dir('*.smr');

%% load smr
data = ImportSMR(files(1).name);

%% check channel headers
nch = length(data);
ch_title = cell(1,nch);
hdr = {data.hdr};
for i=1:nch
    if ~isempty(hdr{i})
        ch_title{i} = hdr{i}.title;
    else
        ch_title{i} = 'nan';
    end
end
chno.v = find(strcmp(ch_title,'ForwardV')); chno.w = find(strcmp(ch_title,'AngularV'));
scaling.v = data(chno.v).hdr.adc.Scale; offset.v = data(chno.v).hdr.adc.DC;
scaling.w = data(chno.w).hdr.adc.Scale; offset.w = data(chno.w).hdr.adc.DC;
v = double(data(chno.v).imp.adc)*scaling.v + offset.v;
w = double(data(chno.w).imp.adc)*scaling.w + offset.w;
dt = prod(data(chno.v).hdr.adc.SampleInterval); t_smr = dt:dt:length(v)*dt;

%%
T_exp = ts(end);
R = 1000;
Nbootstrap = 100;
filtwidth = 3600; % sigma = 3600 frames = 120s
t = linspace(-2*filtwidth,2*filtwidth,4*filtwidth + 1);
h = exp(-t.^2/(2*filtwidth^2));
h = h/sum(h);

%% monkey trajectory and firefly locations - full experiment
figure; hold on;
subplot(2,1,1); hold on;
plot(x_monk, y_monk, '.','MarkerSize',0.5,'Color',[0.5 0.5 0.5]);
x = linspace(-R,R,1000); plot(x,sqrt(R^2 - x.^2),'k'); plot(x,-sqrt(R^2 - x.^2),'k'); % arena boundary
axis equal; axis([-1000 1000 -1000 1000]); axis off; 
title('Foraging trajectory');
subplot(2,1,2); hold on;
for i=1:length(fly_sts)
    t_catch = [0 fly_sts(i).t_catch];
    for j=1:length(fly_sts(i).x)
        plot(fly_sts(i).x(j),fly_sts(i).y(j),'.r','markers',sqrt(round(100*(T_exp - t_catch(j))/T_exp)));
    end
end
x = linspace(-R,R,1000); plot(x,sqrt(R^2 - x.^2),'k'); plot(x,-sqrt(R^2 - x.^2),'k'); % arena boundary
axis equal; axis([-1000 1000 -1000 1000]); axis off; 
title('Reward locations');

%% occupancy maps of monkey and firefly (overlap + baseline overlap by rotating the trajectory map)
Tstart = 0; Tend = 3600; T = (Tend-Tstart);
ts2 = ts(ts>Tstart & ts<Tend);
x_monk2 = x_monk(ts>Tstart & ts<Tend); X_fly2 = X_fly(ts>Tstart & ts<Tend,:);
y_monk2 = y_monk(ts>Tstart & ts<Tend); Y_fly2 = Y_fly(ts>Tstart & ts<Tend,:);
x_fly2 = []; y_fly2 = []; T_fly2 = [];
for i=1:length(fly_sts)
    indx=find(fly_sts(i).t_catch>Tstart,1);
    if ~isempty(indx)
        x_fly2 = [x_fly2 fly_sts(i).x(indx)];
        y_fly2 = [y_fly2 fly_sts(i).y(indx)];
        T_fly2 = [T_fly2 0];
    end
    indx=find(fly_sts(i).t_catch>Tstart);
    if length(indx)>1
        indx2 = find(fly_sts(i).t_catch>Tstart & fly_sts(i).t_catch<Tend, 1);
        if ~isempty(indx2)
            x_fly2 = [x_fly2 fly_sts(i).x(indx(2))];
            y_fly2 = [y_fly2 fly_sts(i).y(indx(2))];
            T_fly2 = [T_fly2 fly_sts(i).t_catch(indx2)];
        end
    end
end

% trajectory for a given time-range
figure; hold on;
plot(x_monk2,y_monk2,'.','markers',0.5,'Color',[0.5 0.5 0.5]); 
hold on; for i=1:length(x_fly2), plot(x_fly2(i),y_fly2(i),'.r','markers',sqrt(round(100*(T - T_fly2(i))/T))); end
x = linspace(-R,R,1000); plot(x,sqrt(R^2 - x.^2),'k'); plot(x,-sqrt(R^2 - x.^2),'k'); % arena boundary
axis equal; axis([-1000 1000 -1000 1000]); axis off; 
title('Foraging trajectory and reward locations');

% monkey occupancy map
sigma = 20; % width of gaussian filter for smoothing
N = 501; % resolution of the map
x = linspace(-R,R,N); y = linspace(-R,R,N);
[X,Y] = meshgrid(x,y);
P_monk = zeros(N,N); P_fly = zeros(N,N);
tic;
for i=1500:5:length(ts)
    P_monk = P_monk + exp(-((x_monk(i) - X).^2 + (y_monk(i) - Y).^2)/(2*sigma^2));
    for j=1:size(X_fly2,2)
        P_fly = P_fly + exp(-((X_fly(i,j) - X).^2 + (Y_fly(i,j) - Y).^2)/(2*sigma^2));
    end
end
toc;
P_monk = P_monk/sum(P_monk(:));
P_fly = P_fly/sum(P_fly(:));

cmap = goodcolormap('wr');
figure; hold on;
subplot(2,1,1); 
imagesc(x,y,P_monk,[0 1*1e-5]);
set(gca,'YDir','normal');
colormap(cmap'); hold on;
x = linspace(-R,R,1000); plot(x,sqrt(R^2 - x.^2),'k'); plot(x,-sqrt(R^2 - x.^2),'k'); % arena boundary
axis equal; axis([-1000 1000 -1000 1000]); axis off; 
title('Occupancy map - Monkey');
subplot(2,1,2); 
imagesc(x,y,P_fly,[0 1e-5]);
set(gca,'YDir','normal');
colormap(cmap'); hold on;
x = linspace(-R,R,1000); plot(x,sqrt(R^2 - x.^2),'k'); plot(x,-sqrt(R^2 - x.^2),'k'); % arena boundary
axis equal; axis([-1000 1000 -1000 1000]); axis off; 
title('Occupancy map - Fireflies');

% compute correlation between P_monk and P_fly
P_mask = sqrt(X.^2 + Y.^2);
for i=1:N
    for j=1:N
        if P_mask(i,j)>R, P_mask(i,j) = nan;
        else P_mask(i,j) = true; end
    end
end
P_monk_masked = P_monk.*P_mask; P_fly_masked = P_fly.*P_mask;
theta = [-180 -135 -90 -45 -20 -5 0 5 20 45 90 135 180];
for i=1:length(theta)
    fprintf(['theta #' num2str(i) '\n']);
    P_monk_masked_rot = imrotate(P_monk_masked,theta(i),'crop');
    P_monk_masked_rot_temp = P_monk_masked_rot(:);
    P_fly_masked_temp = P_fly_masked(:);
    for j=1:Nbootstrap
        indx = randperm(N^2);        
        [r(j,i),p(j,i)] = nancorr(P_monk_masked_rot_temp(indx(1:round(0.5*N^2))),P_fly_masked_temp(indx(1:round(0.5*N^2))));
    end
end
r_mu = mean(r);
r_std = std(r);

%% # of fireflies caught (time histogram)
t_catch = sort([fly_sts.t_catch]);
r_catch = zeros(1,length(ts));
for i=1:length(t_catch)
    if ~isinf(t_catch(i))
        r_catch(abs(ts - t_catch(i)) == min(abs(ts - t_catch(i)))) = 1;
    end
end
r_catch = conv(r_catch,h,'same');
figure; plot(ts/60,r_catch*60,'Color',[0.5 0.5 0.5]); % x60 to convert rewards/frame to rewards/s
hline(length(t_catch)/ts(end),'--r');
axis([0 93 0 0.25]);
box off;

%% Inter-reward iterval
iri = diff(t_catch(~isinf(t_catch)));
iri = iri(iri~=0);
[p_iri,n_iri] = hist(iri,linspace(0,31,32));
p_iri = p_iri/sum(p_iri);
figure; plot(n_iri,p_iri); xlim([0 30]);
box off;

%% distribution of interval between reward and last flash
flash2rew = [];
for i=1:length(fly_sts)
    t_catch = fly_sts(i).t_catch;
    t_on = fly_sts(i).t_on;
    for j=1:length(t_catch)
        if ~isinf(t_catch(j))
            flash2rew = [flash2rew t_catch(j)-t_on(find((t_on - t_catch(j))>0,1)-1)];
        end
    end
end
flash2rew(flash2rew>10) = [];
[p,n] = hist(flash2rew,linspace(0,10,50));
figure; plot(n,p/sum(p)); xlim([0 10]);

%% expected distribution of interval between reward and last flash
for k=1:Nbootstrap
    flash2rew_sim = [];
    for i=1:length(fly_sts)
        t_catch = fly_sts(i).t_catch;
        indx = randperm(length(fly_sts)); indx = indx(1);
        t_on = fly_sts(indx).t_on;
        for j=1:length(t_catch)
            if ~isinf(t_catch(j))
                flash2rew_sim = [flash2rew_sim t_catch(j)-t_on(find((t_on - t_catch(j))>0,1)-1)];
            end
        end
    end
    flash2rew_sim(flash2rew_sim>10) = [];
    [p,n] = hist(flash2rew_sim,linspace(0,10,50));
    p_expected(k,:) = p/sum(p);
end
hold on; plot(n,mean(p_expected)); xlim([0 10]);

%% distribution of errors
indx = find(v<5); indx2 = [];
for i=2:length(indx)
    if v(indx(i)-1)>5, indx2 = [indx2 indx(i)]; end
end
t_stop = t_smr(indx2);
for i=1:length(t_stop) % detect stopping locations
    x_stop(i) = x_monk(find(ts>t_stop(i),1));
    y_stop(i) = y_monk(find(ts>t_stop(i),1));
end
X_fly_stop = []; Y_fly_stop = []; X_fly22 = []; Y_fly22 = [];
for i=2:length(t_stop) % detect nearest target
    X_fly2 = (X_fly(ts>t_stop(i-1) & ts<t_stop(i),:));
    Y_fly2 = (Y_fly(ts>t_stop(i-1) & ts<t_stop(i),:));
    [X_fly2,indx] = unique(X_fly2); Y_fly2 = Y_fly2(indx);
    [dist2fly, indx] = min(sqrt((X_fly2-x_stop(i)).^2 + (Y_fly2-y_stop(i)).^2));
    X_fly_stop = [X_fly_stop x_stop(i)-X_fly2(indx)];
    Y_fly_stop = [Y_fly_stop y_stop(i)-Y_fly2(indx)];
    X_fly22 = [X_fly22 X_fly2(indx)];
    Y_fly22 = [Y_fly22 Y_fly2(indx)];
end
figure; plot(X_fly_stop,Y_fly_stop,'.');
axis([-100 100 -100 100]);
hold on; x = linspace(-R,R,1000); plot(x,sqrt(R^2 - x.^2),'k'); plot(x,-sqrt(R^2 - x.^2),'k'); % arena boundary
figure; hold on;
for i=1:length(x_stop)-1
    quiver(X_fly22(i),Y_fly22(i),X_fly_stop(i),Y_fly_stop(i),0,'ok','markersize',2,...
        'ShowArrowhead','on','markerFaceColor','k','MaxHeadSize',2);
end
hold on; x = linspace(-R,R,1000); plot(x,sqrt(R^2 - x.^2),'k'); plot(x,-sqrt(R^2 - x.^2),'k'); % arena boundary

%
sigma = 20; % width of gaussian filter for smoothing
N = 501; % resolution of the map
x = linspace(-R,R,N); y = linspace(-R,R,N);
[X,Y] = meshgrid(x,y);
P_stop = zeros(N,N);
tic;
for i=1:length(x_stop)
    P_stop = P_stop + exp(-((x_stop(i) - X).^2 + (y_stop(i) - Y).^2)/(2*sigma^2));
end
toc;
P_stop = P_stop/sum(P_stop(:));

%% distribution of egocentric target locations conditioned on angular accelaration
[peaks,peaklocs] = findpeaks(w,'MinPeakHeight',20,'MinPeakProminence',20);
t_peak = t_smr(peaklocs);
t_peak2 = t_peak(1); peaklocs2 = peaklocs(1);
for j=2:length(t_peak)
    if (t_peak(j) - t_peak2(end))>0.3, t_peak2 = [t_peak2 t_peak(j)]; peaklocs2 = [peaklocs2 peaklocs(j)]; end
end
t_peak =t_peak2; peaklocs = peaklocs2;
w_peak = w(peaklocs);
w_ts = interp1(t_smr,w,ts);
theta = mod(cumsum(w)*dt,360); theta_ts = interp1(t_smr,theta,ts); theta_ts(1) = 0;
figure; hold on;
indx = 80000:100000;
plot(x_monk2(indx),y_monk2(indx),'.','markers',0.5,'Color',[0.5 0.5 0.5]); 
for i=indx(1:50:end)
    quiver(x_monk2(i),y_monk2(i),20*sind(theta_ts(i)),-20*cosd(theta_ts(i)),0,'ok','markersize',2,...
        'ShowArrowhead','on','markerFaceColor','k','MaxHeadSize',2);
end
hold on; x = linspace(-R,R,1000); plot(x,sqrt(R^2 - x.^2),'k'); plot(x,-sqrt(R^2 - x.^2),'k'); % arena boundary

%%
% define grid and accumulate probabilities

sigma = 20; % width of gaussian filter for smoothing
N = 101; % resolution of the map
x = linspace(-a/2,a/2,N); y = linspace(0,a,N);
[X,Y] = meshgrid(x,y); 
P_mask = double((sqrt(X.^2 + Y.^2)<400) & (abs(atand(X./Y))<40)); % show 0 to 4 m & -40 to 40 deg
P_mask(P_mask==0) = NaN;
P_fly_ccw = zeros(N,N); P_fly_cw = zeros(N,N);
% detect peak velocities
R_overlap = [];
for k=1
    theta_peak = []; x_monk_peak = []; y_monk_peak = []; t_pre = -0.8+ 0.1*(k-1); t_post = t_pre + 0.3;
    for i=1:length(t_peak)
        X_fly_temp = X_fly((ts>(t_peak(i)+t_pre) & ts<(t_peak(i)+t_post)),:);
        Y_fly_temp = Y_fly((ts>(t_peak(i)+t_pre) & ts<(t_peak(i)+t_post)),:);
        I_fly_temp = I_fly((ts>(t_peak(i)+t_pre) & ts<(t_peak(i)+t_post)),:);
        indx_flyON = find(any(I_fly_temp));
        I_fly_ONtime = sum(I_fly_temp);
        I_fly_ONtime = I_fly_ONtime(indx_flyON);
        X_fly_temp = X_fly_temp(:,indx_flyON);
        Y_fly_temp = Y_fly_temp(:,indx_flyON);
        X_flyON = []; Y_flyON = [];
        for j=1:size(X_fly_temp,2)
            X_fly_temp2 = unique(X_fly_temp(X_fly_temp(:,j)~=0,j)); X_flyON(j) = X_fly_temp2(1);
            Y_fly_temp2 = unique(Y_fly_temp(Y_fly_temp(:,j)~=0,j)); Y_flyON(j) = Y_fly_temp2(1);
        end
        % compute field-of-view (fov)
        a = 500; % a=500 cm
        theta_peak(i) = theta_ts(find(ts>(t_peak(i)+t_pre),1));
        x_monk_peak(i) = x_monk(find(ts>(t_peak(i)+t_pre),1));
        y_monk_peak(i) = y_monk(find(ts>(t_peak(i)+t_pre),1));
        R = [cosd(-theta_peak(i)) -sind(-theta_peak(i)); sind(-theta_peak(i)) cosd(-theta_peak(i))];
        Rinv = [cosd(theta_peak(i)) -sind(theta_peak(i)); sind(theta_peak(i)) cosd(theta_peak(i))];
        XY_corners = [-a/2 a/2 -a/2 a/2; ...
            0 0 a a];
        XY_corners2 = R*XY_corners; XY_corners2(2,:) = -XY_corners2(2,:); % flip y-coord
        XY_corners2(1,:) = XY_corners2(1,:) + x_monk_peak(i);
        XY_corners2(2,:) = XY_corners2(2,:) + y_monk_peak(i);
        % identify targets within fov
        indx = [];
        for j=1:length(X_flyON)
            p12m = (XY_corners2(:,2) - XY_corners2(:,1))'*([X_flyON(j);Y_flyON(j)] - XY_corners2(:,1));
            p12 = sum((XY_corners2(:,2) - XY_corners2(:,1)).^2);
            p13m = (XY_corners2(:,3) - XY_corners2(:,1))'*([X_flyON(j);Y_flyON(j)] - XY_corners2(:,1));
            p13 = sum((XY_corners2(:,3) - XY_corners2(:,1)).^2);
            if (p12m>0 && p12m<p12) && (p13m>0 && p13m<p13), indx = [indx j]; end
        end
        X_flyON = X_flyON(indx); Y_flyON = Y_flyON(indx); duration_flyON = I_fly_ONtime(indx);
        if ~isempty(X_flyON)
            tt = [X_flyON; Y_flyON] - repmat([x_monk_peak(i); y_monk_peak(i)],1,length(X_flyON));
            egopos_flyON = -R*tt;
            %
            if w_peak(i) > 0
                for j=1:size(egopos_flyON,2)
                    P_fly_cw = P_fly_cw + duration_flyON(j)*exp(-((egopos_flyON(1,j) - X).^2 + (egopos_flyON(2,j) - Y).^2)/(2*sigma^2)); % position weighted by duration
                end
            else
                for j=1:size(egopos_flyON,2)
                    P_fly_ccw = P_fly_ccw + duration_flyON(j)*exp(-((egopos_flyON(1,j) - X).^2 + (egopos_flyON(2,j) - Y).^2)/(2*sigma^2)); % position weighted by duration
                end
            end
        end
    end
    P_fly_cw = P_fly_cw/sum(P_fly_cw(:)); P_fly_ccw = P_fly_ccw/nansum(P_fly_ccw(:));
    figure; pcolor(x,y,P_fly_cw.*P_mask); set(gca,'YDir','normal'); axis([-250 250 0 400]); vline(0,'k');
    figure; pcolor(x,y,P_fly_ccw.*P_mask); set(gca,'YDir','normal'); axis([-250 250 0 400]); vline(0,'k');
    P_fly_ccw0 = P_fly_ccw - nanmean(P_fly_ccw(:));
    P_fly_cw0 = P_fly_cw - nanmean(P_fly_cw(:));
    R_overlap(k) = nansum(nansum(P_fly_ccw0.*P_fly_cw0))/sqrt(nansum(nansum(P_fly_ccw0.^2))*nansum(nansum(P_fly_cw0.^2)));
end

%% age of fireflies
for i=1:length(fly_sts)
    t_lastcatch(i) = fly_sts(i).t_catch(end);
end
t_lastcatch(isinf(t_lastcatch)) = -inf;
[P,n] =  hist(ts(end) - t_lastcatch,20); 
figure; plot(n,P/length(fly_sts))
xlabel('Firefly age (s)'); ylabel('Probability');