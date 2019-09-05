function [h1, h2, isavailable] = ImportHandPosition(v,w,dt,prs)

isavailable = false;

%% derivative
h1 = diff(v)/dt;
h2 = diff(w)/dt;

%% define filter
sig = 10*prs.filtwidth; %filter width
sz = 10*prs.filtsize; %filter size
t2 = linspace(-sz/2, sz/2, sz);
h = exp(-t2.^2/(2*sig^2));
h = h/sum(h); % normalise filter to ensure area under the graph of the data is not altered

%% filter
h1 = conv(h1,h,'same');
h2 = conv(h2,h,'same');

%% cube-root transform
h1 = 10*nthroot(h1,3);
h2 = 10*nthroot(h2,3);

%% orthogonalize
h1 = h1; 
h2 = h2 - (mean(h1.*h2)/mean(h1.*h1))*h1;

%%
theta = 0.55;
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
h_rot = R*[h1(:)' ; h2(:)'];
h1 = [0 h_rot(1,:)]; 
h2 = [0 h_rot(2,:)];
ts = dt:dt:dt*numel(h1);

%% downsample to 30Hz
dt2 = (1/30);
ns = ceil(dt2/dt);
tsd = downsample(ts,ns);
h1d = downsample(h1,ns);
h2d = downsample(h2,ns);
h1 = interp1(tsd,h1d,ts,'nearest'); h1(isnan(h1)) = 0;
h2 = interp1(tsd,h2d,ts,'nearest'); h2(isnan(h2)) = 0;

%% save
h1 = h1(:);  h2 = h2(:);
isavailable = true;