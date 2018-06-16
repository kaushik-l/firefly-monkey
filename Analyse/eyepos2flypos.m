function [r,theta] = eyepos2flypos(beta_l,beta_r,alpha_l,alpha_r,z)

% beta_l: left eye elevation
% beta_r: right eye elevation
% alpha_l: left eye version
% alpha_r: right eye version

beta = 0.5*(beta_l + beta_r);
alpha = 0.5*(alpha_l + alpha_r);
x_squared = z^2*[(tan(alpha).^2)./(tan(beta).^2)].*[(1 + tan(beta).^2)./(1 + tan(alpha).^2)];
y_squared = (z^2)./(tan(beta).^2) - x_squared;
r = sqrt(x_squared + y_squared);
theta = alpha;