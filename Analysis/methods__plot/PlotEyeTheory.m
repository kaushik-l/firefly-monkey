%% static parameters
delta = 3.5/2; % IOD = 2*delta
z = -10;

%% gaze location
r = linspace(15,400,93);
th = linspace(-40,40,21);
[R,TH] = meshgrid(r,th);
Y = R./sqrt(1 + tand(TH).^2);
X = Y.*tand(TH);

%% theoretical predictions for eye position
yle_pred = atan2d(X + delta, sqrt(Y.^2 + z^2));
yre_pred = atan2d(X - delta, sqrt(Y.^2 + z^2));
zle_pred = atan2d(z , sqrt(Y.^2 + (X + delta).^2));
zre_pred = atan2d(z , sqrt(Y.^2 + (X - delta).^2));
ver_mean_pred = 0.5*(zle_pred + zre_pred); % mean vertical eye position (of the two eyes)
hor_mean_pred = 0.5*(yle_pred + yre_pred); % mean horizontal eye position
ver_diff_pred = 0.5*(zle_pred - zre_pred); % 0.5*difference between vertical eye positions (of the two eyes)
hor_diff_pred = 0.5*(yle_pred - yre_pred); % 0.5*difference between horizontal eye positions

%% plot
cmap = gray(size(R,1));
figure; hold on;
for i=1:size(R,1), plot(R(i,:),ver_mean_pred(i,:),'Color',cmap(end-i+1,:)); end
xlabel('Target distance (cm)'); ylabel('Elevation (deg)');

cmap = gray(size(TH,2));
figure; hold on;
for i=1:size(TH,2), plot(TH(:,i),hor_mean_pred(:,i),'Color',cmap(i,:)); end
xlabel('Target angle (deg)'); ylabel('Lateral version (deg)');

cmap = gray(size(R,1));
figure; hold on;
for i=1:size(R,1), plot(R(i,:),hor_diff_pred(i,:),'Color',cmap(i,:)); end
xlabel('Target distance (cm)'); ylabel('Vergence (deg)');