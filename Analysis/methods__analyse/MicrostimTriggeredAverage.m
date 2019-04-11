function [v_out, w_out] = MicrostimTriggeredAverage(v_in, w_in, t_in, t_stim)

ntrls = length(t_stim); dt = diff(t_in{1}); dt = median(dt); t_max = 2;
count_lin = 0; count_ang = 0;
%% 
for i=1:ntrls
    %% linear
    v = v_in{i}(t_in{i} > t_stim(i));
    v = v - v(1); % offset so that v(1) = 0
    v = [v ; nan(round(t_max/dt),1)]; % pad 2 secs
    v = v(1:round(t_max/dt));
    count_lin = count_lin + 1;
    v_stim(count_lin,:) = v;
    %% angular
    w = w_in{i}(t_in{i} > t_stim(i));
    w = w - w(1); % offset so that v(1) = 0
    w = [w ; nan(round(t_max/dt),1)]; % pad 2 secs
    w = w(1:round(t_max/dt));
    count_ang = count_ang + 1;
    w_stim(count_ang,:) = w;
end

%% store mean and std
t_out = dt:dt:t_max;

v_out.microstim.mu = nanmean(v_stim);                          % mean across trials with v_ptb>0
v_out.microstim.sem = nanstd(v_stim)/sqrt(size(v_stim,1));     % std across trials with v_ptb>0
v_out.microstim.t = t_out;

w_out.microstim.mu = nanmean(w_stim);                          % mean across trials with w_ptb>0
w_out.microstim.sem = nanstd(w_stim)/sqrt(size(w_stim,1));     % std across trials with w_ptb>0
w_out.microstim.t = t_out;