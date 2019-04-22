function SpatialError = ComputeSpatialError(targ,resp)

%% load coordinates
r_f = targ.r; r_m = resp.r;
theta_f = targ.theta; theta_m = resp.theta;
x_f = r_f.*sind(theta_f); y_f = r_f.*cosd(theta_f); x_f = x_f(:);
x_m = r_m.*sind(theta_m); y_m = r_m.*cosd(theta_m); y_f = y_f(:);

%% calculate error vectors
x_err = x_m(:)-x_f(:);
y_err = y_m(:)-y_f(:);

%% griddify
% construct meshgrid
Nx = 200; Ny = 100;
x = linspace(-400,400,Nx);
y = linspace(0,400,Ny);
dx = diff(x); dx = dx(1);
dy = diff(y); dy = dy(1);
[xx, yy] = meshgrid(x, y); %fly positions

% assign grid location to error vectors
fprintf('.........assigning grid location \n');
for i=1:length(x)
    for j=1:length(y)
        x_ij_pre = x(i)-dx/2;  x_ij_post = x(i)+dx/2; 
        y_ij_pre = y(j) - dy/2; y_ij_post = y(j) + dy/2;
        match = (x_f>x_ij_pre & x_f<x_ij_post) & (y_f>y_ij_pre & y_f<y_ij_post);
        err.x(i,j) = sqrt(mean(x_err(match).^2)); % like std dev
        err.y(i,j) = sqrt(mean(y_err(match).^2));
    end
end

% smooth error vectors
prob_occupancy = sum(~isnan(err.x(:)))/numel(err.x(:));
fprintf('.........smoothing error vector \n');
for i=1:length(x)
    for j=1:length(y)
        % construct weight profile
        sig_x = 40; sig_y = 40;
        g = exp(-(((xx-x(i)).^2)/(2*sig_x^2)+((yy-y(j)).^2)/(2*sig_x^2)));
        g = (g/sum(g(:)))/prob_occupancy;
        % apply weights
        sum_x = g'.*err.x;
        sum_y = g'.*err.y;
        err_s.x(i,j) = nansum(sum_x(:));
        err_s.y(i,j) = nansum(sum_y(:));
    end
end

% construct mask
mask = NaN(400,800);
for i=1:400
    for j=1:800
        r(i,j) = sqrt(i^2 + (j-400)^2);
        theta(i,j) = atan2d(j-400,i);
        if r(i,j) < 400 && abs(theta(i,j)) < 40
            mask(i,j) = 1;
        else mask(i,j) = NaN;
        end
    end
end
mask = imresize(mask, [100 200],'bicubic');

%% save
SpatialError.x = x;
SpatialError.y = y;
SpatialError.x_err_smooth = err_s.x;
SpatialError.y_err_smooth = err_s.y;
SpatialError.abserr = sqrt((err_s.x).^2 + (err_s.y).^2)'.*mask;
SpatialError.x_f = x_f;
SpatialError.y_f = y_f;
SpatialError.x_err = x_err;
SpatialError.y_err = y_err;

%% plot
% figure; hold on;
% h=imagesc(x,y,sqrt((err_s.x).^2 + (err_s.y).^2)'.*mask,[0 300]); axis([-400 400 0 400]);
% set(h,'alphadata',~isnan(sqrt((err_s.x).^2 + (err_s.y).^2)'.*mask));
% set(gca,'YDir','normal');
% ntrls = length(x_f); indx = randperm(ntrls); indx = indx(1:300);
% quiver(x_f(indx),y_f(indx),x_err(indx)*0.1,y_err(indx)*0.1,0,'Color','r'); % without scaling
% cmap = colormap('autumn'); temp=colormap('hot');
% cmap(:,3) = cmap(:,2); % builds from red to white
% cmap2 = cmap(end:-1:1,:); % builds from white to red
% cmap3 = cmap; cmap3(:,3) = temp(:,3); % red to orange to yellow to white
% colormap(brewermap([],'Greys')); % bone gray hot cool autumn jet
% axis equal;