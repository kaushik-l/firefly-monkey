function [x, y] = ComputePtbDisplacement(linvel_max,angvel_max,sigma,duration)

t = linspace(0,duration,100);
angvel = angvel_max(:)*exp(-((t - duration/2).^2)/(2*(sigma)^2));
linvel = linvel_max(:)*exp(-((t - duration/2).^2)/(2*(sigma)^2));
for i=1:size(angvel,1), [~, ~, x(i), y(i)] = gen_traj(angvel(i,:), linvel(i,:), t); end