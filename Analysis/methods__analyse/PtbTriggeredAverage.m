function [v_out, w_out] = PtbTriggeredAverage(v_in, w_in, t_in, vmax_ptb, wmax_ptb, t_ptb)

ntrls = length(t_ptb); dt = diff(t_in{1}); dt = median(dt); t_max = 2;
count_lin1 = 0; count_lin2 = 0; count_ang1 = 0; count_ang2 = 0;
%% 
for i=1:ntrls
    %% linear
    v = v_in{i}(t_in{i} > t_ptb(i));
    v = v - v(1); % offset so that v(1) = 0
    v = [v ; nan(round(t_max/dt),1)]; % pad 2 secs
    v = v(1:round(t_max/dt));
    if vmax_ptb(i)<0
        count_lin1 = count_lin1 + 1;
        v_ptb1(count_lin1,:) = v;
    elseif vmax_ptb(i)>0
        count_lin2 = count_lin2 + 1;
        v_ptb2(count_lin2,:) = v;
    end
    %% angular
    w = w_in{i}(t_in{i} > t_ptb(i));
    w = w - w(1); % offset so that v(1) = 0
    w = [w ; nan(round(t_max/dt),1)]; % pad 2 secs
    w = w(1:round(t_max/dt));
    if wmax_ptb(i)<0
        count_ang1 = count_ang1 + 1;
        w_ptb1(count_ang1,:) = w;
    elseif wmax_ptb(i)>0
        count_ang2 = count_ang2 + 1;
        w_ptb2(count_ang2,:) = w;
    end
end

%% store mean and std
t_out = dt:dt:t_max;

v_out.posptb.mu = nanmean(v_ptb1);                          % mean across trials with v_ptb>0
v_out.posptb.sem = nanstd(v_ptb1)/sqrt(size(v_ptb1,1));     % std across trials with v_ptb>0
v_out.posptb.t = t_out;
v_out.negptb.mu = nanmean(v_ptb2);                          % mean across trials with v_ptb<0
v_out.negptb.sem = nanstd(v_ptb2)/sqrt(size(v_ptb2,1));     % std across trials with v_ptb<0
v_out.negptb.t = t_out;

w_out.posptb.mu = nanmean(w_ptb1);                          % mean across trials with w_ptb>0
w_out.posptb.sem = nanstd(w_ptb1)/sqrt(size(w_ptb1,1));     % std across trials with w_ptb>0
w_out.posptb.t = t_out;
w_out.negptb.mu = nanmean(w_ptb2);                          % mean across trials with w_ptb<0
w_out.negptb.sem = nanstd(w_ptb2)/sqrt(size(w_ptb2,1));     % std across trials with w_ptb<0
w_out.negptb.t = t_out;