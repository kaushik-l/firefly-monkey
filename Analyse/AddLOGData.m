function trials = AddLOGData(file)

count = 0;
fid = fopen(file, 'r');
eof=0; newline = 'nothingnew'; count=0;
while newline ~= -1
    %% get ground plane density
    while ~strcmp(newline(1:9),'Floor Den')
        newline = fgetl(fid);
        if newline == -1, break; end
    end
    if newline == -1, break; end
    count = count+1;
    trials(count).floordensity = str2num(newline(27:34));
    %% get landmark status, ptb velocities and ptb delay
    newline = fgetl(fid);
    if newline == -1, break; end
    if strcmp(newline(1:9),'Enable Di')
        trials(count).landmark_distance = str2num(newline(26)); % 1=distance landmark was ON
        newline = fgetl(fid);
        trials(count).landmark_angle = str2num(newline(25)); % 1=angular landmark was ON
        newline = fgetl(fid);
        trials(count).ptb_linear = str2num(newline(35:end)); % amplitude of linear velocity ptb (cm/s)
        newline = fgetl(fid);
        trials(count).ptb_angular = str2num(newline(37:end)); % amplitude of angular velocity ptb (deg/s)
        newline = fgetl(fid);
        trials(count).ptb_delay = str2num(newline(31:end)); % time after trial onset at which to begin ptb
    else
        trials(count).landmark_distance = nan;
        trials(count).landmark_angle = nan;
        trials(count).ptb_linear = nan;
        trials(count).ptb_angular = nan;
        trials(count).ptb_delay = nan;
    end
    %% get inter-trial interval, firefly status and stopping duration for reward
    newline = fgetl(fid);
    if newline == -1, break; end
    if strcmp(newline(1:9),'Inter-tri')
        trials(count).intertrial_interval = str2num(newline(27:end)); % time between end of this trial and beg of next trial (s)
        newline = fgetl(fid);
        trials(count).firefly_fullON = str2num(newline(18)); % 1=firefly was ON throughout the trial
        newline = fgetl(fid);
        trials(count).stop_duration = str2num(newline(34:end)); % wait duration after stopping before monkey is given feedback (ms)
    else
        trials(count).intertrial_interval = nan;
        trials(count).firefly_fullON = nan;
        trials(count).stop_duration = nan;
    end
end