function eye_distr(experiments,sess)

% function to plot the eye vel distribution for all trials in a session.
monk_id = experiments.sessions(sess).monk_id;
ntrials = 1:length(experiments.sessions(sess).behaviours.trials);
%     h_vel = []; ts_eye = []; v_vel = [];
for i =1:length(ntrials)
    hre = experiments.sessions(sess).behaviours.trials(i).continuous.yre; if isnan(hre), hre=0;end
    hle = experiments.sessions(sess).behaviours.trials(i).continuous.yle; if isnan(hle), hle=0;end
    vre = experiments.sessions(sess).behaviours.trials(i).continuous.zre; if isnan(vre), vre=0;end
    vle = experiments.sessions(sess).behaviours.trials(i).continuous.zle; if isnan(vle), vle=0;end
    
    % get ye = horizontal eye position, ze = vertical eye position.

    dt = median(diff(experiments.sessions(sess).behaviours.trials(i).continuous.ts)); % sampling rate of smr file
    ts = experiments.sessions(sess).behaviours.trials(i).continuous.ts(1:end-1); % remove last sample as when taking diff on position, you lose one sample
    % use the eye with a working eye coil
    if (var(vle) > var(vre))
        v_eye = diff(vle);
        h_eye = diff(hle);
    else
        v_eye = diff(vre);
        h_eye = diff(hre);
    end
    
    % Divide by sec/samp to get eye vel
    he_vel = h_eye/dt;
    ve_vel = v_eye/dt;
    % Extract eye vel for each trial
    t_targ = experiments.sessions(sess).behaviours.trials(i).events.t_targ;
    t_targ_dur = 0.3;
    t_stop = experiments.sessions(sess).behaviours.trials(i).events.t_stop;
    
    if ~isempty(ve_vel)
        h_vel{i,:} = he_vel(ts > (t_targ + t_targ_dur) & ts < t_stop);
        ts_eye{i,:} = ts(ts > (t_targ + t_targ_dur) & ts < t_stop);
        v_vel{i,:} = ve_vel(ts > (t_targ + t_targ_dur) & ts < t_stop);
    end
end

% plot distribution
h_vel_all = []; v_vel_all= [];
for j = 1:length(v_vel)
    h_vel_all = [h_vel_all; h_vel{j}];
    v_vel_all = [v_vel_all; v_vel{j}];
end

% plot
figure; histogram(h_vel_all,10000);
set(gca,'xlim', [-50 50],'TickDir', 'out', 'FontSize', 18);
xlabel('horizontal vel (deg/s)'); title(['Monk ' num2str(monk_id) ' sess ' num2str(sess)])
box off; l=vline(0, '--r'); set(l,'LineWidth',2);

figure; histogram(v_vel_all,10000);
set(gca,'xlim', [-50 50],'TickDir', 'out', 'FontSize', 18);
xlabel('vertical vel (deg/s)'); title(['Monk ' num2str(monk_id) ' sess ' num2str(sess)])
box off; l=vline(0, '--r'); set(l,'LineWidth',2);
end


