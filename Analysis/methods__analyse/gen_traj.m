function [mu_xt, mu_yt, mu_x, mu_y, mu_theta, mu_thetat] = gen_traj(mu_w, mu_v, ts)

% generates trajectory given w,v,x,y
% linear speed mean (mu_v)
% angular speed mean (mu_w)
% initial positions (x0/y0)
% outputs: mu_xt, mu_yt, mu_x, mu_y 

% if v<0, then sign of w needs to be inverted because of Jian.
mu_w = mu_w.*sign(mu_v);

% sampling rate
dt = median(diff(ts)); % needs to match downsampling rate

% select first dimension
sz = length(mu_v);

% initialize
mu_xt = zeros(sz,1);
mu_yt = zeros(sz,1);
mu_thetat = zeros(sz,1);
mu_xt(1) = 0;
mu_yt(1) = 0;

% construct trajectory
for j=1:sz
    vt_x = mu_v(j).*sin(mu_thetat(j));
    vt_y = mu_v(j).*cos(mu_thetat(j));
    mu_xt(j+1) = mu_xt(j) + vt_x*dt;
    mu_yt(j+1) = mu_yt(j) + vt_y*dt;
    mu_thetat(j+1) = mu_thetat(j) + (mu_w(j)*pi/180)*dt;
    mu_thetat(j+1) = (mu_thetat(j+1)>-pi & mu_thetat(j+1)<=pi).*mu_thetat(j+1) + ...
        (mu_thetat(j+1)>pi).*(mu_thetat(j+1) - 2*pi) + ...
            (mu_thetat(j+1)<=-pi).*(mu_thetat(j+1) + 2*pi);
end
mu_x = mu_xt(end); mu_y = mu_yt(end); mu_theta = mu_thetat(end);