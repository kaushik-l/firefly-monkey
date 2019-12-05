function trl = AddSMRData(data,prs)

%% check channel headers
nch = length(data);
ch_title = cell(1,nch);
hdr = {data.hdr};
for i=1:nch
    if ~isempty(hdr{i})
        ch_title{i} = hdr{i}.title;
    else
        ch_title{i} = 'nan';
    end
end

%% channel titles
chno.mrk = find(strcmp(ch_title,'marker'));
chno.yle = find(strcmp(ch_title,'LDy')); chno.zle = find(strcmp(ch_title,'LDz'));
chno.yre = find(strcmp(ch_title,'RDy')); chno.zre = find(strcmp(ch_title,'RDz'));
chno.xfp = find(strcmp(ch_title,'FireflyX')); chno.yfp = find(strcmp(ch_title,'FireflyY'));
chno.xmp = find(strcmp(ch_title,'MonkeyX')); chno.ymp = find(strcmp(ch_title,'MonkeyY'));
chno.v = find(strcmp(ch_title,'ForwardV')); chno.w = find(strcmp(ch_title,'AngularV'));
if ~isempty(find(strcmp(ch_title,'Pulse'), 1)), chno.microstim = find(strcmp(ch_title,'Pulse')); end

%% scale
scaling.t = data(chno.mrk).hdr.tim.Scale*data(chno.mrk).hdr.tim.Units;
scaling.yle = data(chno.yle).hdr.adc.Scale; offset.yle = data(chno.yle).hdr.adc.DC;
scaling.yre = data(chno.yre).hdr.adc.Scale; offset.yre = data(chno.yre).hdr.adc.DC; 
scaling.zle = data(chno.zle).hdr.adc.Scale; offset.zle = data(chno.zle).hdr.adc.DC; 
scaling.zre = data(chno.zre).hdr.adc.Scale; offset.zre = data(chno.zre).hdr.adc.DC;
scaling.xfp = data(chno.xfp).hdr.adc.Scale; offset.xfp = data(chno.xfp).hdr.adc.DC;
scaling.yfp = -data(chno.yfp).hdr.adc.Scale; offset.yfp = -data(chno.yfp).hdr.adc.DC;
scaling.xmp = data(chno.xmp).hdr.adc.Scale; offset.xmp = data(chno.xmp).hdr.adc.DC;
scaling.ymp = -data(chno.ymp).hdr.adc.Scale; offset.ymp = -data(chno.ymp).hdr.adc.DC;
scaling.v = data(chno.v).hdr.adc.Scale; offset.v = data(chno.v).hdr.adc.DC;
scaling.w = data(chno.w).hdr.adc.Scale; offset.w = data(chno.w).hdr.adc.DC;
if isfield(chno,'microstim'), scaling.microstim = data(chno.microstim).hdr.adc.Scale; offset.microstim = data(chno.microstim).hdr.adc.DC; end

%% event markers
markers = data(chno.mrk).imp.mrk(:,1);
%% event times
t.events = double(data(chno.mrk).imp.tim)*scaling.t;
t.beg = t.events(markers ==2); 
t.end = t.events(markers ==3); 
t.reward = t.events(markers ==4);
t.beg = t.beg(1:length(t.end));
t.ptb = t.events(markers==5 | markers==8);
t.microstim = t.events(markers==32);

%% define filter
sig = prs.filtwidth; %filter width
sz = prs.filtsize; %filter size
t2 = linspace(-sz/2, sz/2, sz);
h = exp(-t2.^2/(2*sig^2));
h = h/sum(h); % normalise filter to ensure area under the graph of the data is not altered

%% load relevant channels
chnames = fieldnames(chno); MAX_LENGTH = inf; dt = [];
for i=1:length(chnames)
    if ~any(strcmp(chnames{i},'mrk'))
        ch.(chnames{i}) = double(data(chno.(chnames{i})).imp.adc)*scaling.(chnames{i}) + offset.(chnames{i});
        dt = [dt prod(data(chno.(chnames{i})).hdr.adc.SampleInterval)];
        MAX_LENGTH = min(length(ch.(chnames{i})),MAX_LENGTH);
    end
end
if any(strcmp(chnames,'microstim')), dt_microstim = dt(end); dt(end) = dt(1); end
if length(unique(dt))==1
    dt = dt(1);
else
   error('channels must all have identical sampling rates');
end

%% filter position and velocity channels
for i=1:length(chnames)
    if ~any(strcmp(chnames{i},{'mrk','yle','yre','zle','zre','microstim'}))
        ch.(chnames{i}) = conv(ch.(chnames{i})(1:MAX_LENGTH),h,'same');
%         ch.(chnames{i}) = ch.(chnames{i})(sz/2+1:end);
    end
end
ch.yle = ch.yle(1:MAX_LENGTH);
ch.yre = ch.yre(1:MAX_LENGTH);
ch.zle = ch.zle(1:MAX_LENGTH);
ch.zre = ch.zre(1:MAX_LENGTH);
ts = dt:dt:length(ch.(chnames{end-1}))*dt;
if any(strcmp(chnames,'microstim'))
    ts2 = dt_microstim:dt_microstim:length(ch.microstim)*dt_microstim; ch.microstim = interp1(ts2,ch.microstim,ts); 
    ch.microstim = ch.microstim(:);
end

%% import hand position
% [ch.h1, ch.h2, isavailable] = ImportHandPosition(ch.v,ch.w,dt,prs);
% if isavailable, chnames(end+1:end+2) = {'h1','h2'}; end % append two more channels

%% replace the signal from the untracked eye (if any) with NaNs
if prs.eyechannels(1) == 0
    ch.zle(:) = nan;
    ch.yle(:) = nan;
end
if prs.eyechannels(2) == 0
    ch.zre(:) = nan;
    ch.yre(:) = nan;
end
if all(prs.eyechannels == 0), warning('No eye signal for this dataset'); end

%% if using eye tracker, remove eye blinks and smooth
if any(prs.eyechannels == 2)
    X = [ch.zle ch.zre ch.yle ch.yre];
    X = ReplaceWithNans(X, prs.blink_thresh, prs.nanpadding);
    ch.zle = X(:,1); ch.zre = X(:,2); ch.yle = X(:,3); ch.yre = X(:,4);
    sig = 10*prs.filtwidth; %filter width
    sz = 10*prs.filtsize; %filter size
    t2 = linspace(-sz/2, sz/2, sz);
    h = exp(-t2.^2/(2*sig^2));
    h = h/sum(h); % normalise filter to ensure area under the graph of the data is not altered
    ch.zle = conv(ch.zle,h,'same'); ch.zre = conv(ch.zre,h,'same');
    ch.yle = conv(ch.yle,h,'same'); ch.yre = conv(ch.yre,h,'same');
end

%% detect saccade times
% take derivative of eye position = eye velocity
if all(prs.eyechannels ~= 0)
    dze = diff(0.5*(ch.zle + ch.zre));
    dye = diff(0.5*(ch.yle + ch.yre));
elseif prs.eyechannels(1) ~= 0
    dze = diff(ch.zle);
    dye = diff(ch.yle);
else
    dze = diff(ch.zre);
    dye = diff(ch.yre);
end

%%
v_eye_vel = dze/dt; 
h_eye_vel = dye/dt;
de = sqrt(dze.^2 + dye.^2); % speed of eye movement
de_smooth = conv(de,h,'same')/dt;

% apply threshold on eye speed
saccade_thresh = prs.saccade_thresh;
indx_thresh = de_smooth>saccade_thresh;
dindx_thresh = diff(indx_thresh);
t_saccade = find(dindx_thresh>0)*dt;

% remove duplicates by applying a saccade refractory period
min_isi = prs.min_intersaccade;
t_saccade(diff(t_saccade)<min_isi) = [];
t.saccade = t_saccade;

%% interpolate nans
if any(prs.eyechannels == 2) % conditional statement not necessary perhaps
    nanx = isnan(ch.zle); t1 = 1:numel(ch.zle); ch.zle(nanx) = interp1(t1(~nanx), ch.zle(~nanx), t1(nanx), 'pchip');
    nanx = isnan(ch.zre); t1 = 1:numel(ch.zle); ch.zre(nanx) = interp1(t1(~nanx), ch.zre(~nanx), t1(nanx), 'pchip');
    nanx = isnan(ch.yle); t1 = 1:numel(ch.yle); ch.yle(nanx) = interp1(t1(~nanx), ch.yle(~nanx), t1(nanx), 'pchip');
    nanx = isnan(ch.yre); t1 = 1:numel(ch.yre); ch.yre(nanx) = interp1(t1(~nanx), ch.yre(~nanx), t1(nanx), 'pchip');
end

%% detect time points of fixation onsets
fixateduration = prs.fixateduration; fixate_thresh = prctile(de_smooth,90); % set thresh to 90th prctile
fixateduration_samples = round(fixateduration/dt);
fixateindx = false(1,numel(ts) - round(2*fixateduration/dt));
for i=1:(numel(ts) - round(2*fixateduration/dt))
    if mean(de_smooth(i:i+fixateduration_samples)) < fixate_thresh && max(de_smooth(i:i+fixateduration_samples)) < 1.5*fixate_thresh, fixateindx(i) = true; end
end
fixation_switch = diff(fixateindx);
t.fix = ts(fixation_switch>0);

%% refine t.beg to ensure it corresponds to target onset
jitter = prs.jitter_marker;
dPm__dt = [0 ; sqrt(diff(ch.ymp).^2 + diff(ch.xmp).^2)]; % derivative of monkey position
[~,t_teleport] = findpeaks(dPm__dt,dt*(1:length(dPm__dt)),'MinPeakHeight',prs.minpeakprominence.monkpos); % detect peaks
dPf__dt = [0 ; sqrt(diff(ch.yfp).^2 + diff(ch.xfp).^2)]; % derivative of firefly position
[~,t_flyON] = findpeaks(dPf__dt,dt*(1:length(dPf__dt)),'MinPeakHeight',prs.minpeakprominence.flypos); % detect peaks
t_teleport_trl = nan(length(t.beg),1); t_flyON_trl = nan(length(t.beg),1);
for i=1:length(t.beg)
    t_teleport_temp = t_teleport(t_teleport > (t.beg(i) - jitter) &  t_teleport < (t.beg(i) + jitter));
    if ~isempty(t_teleport_temp), t_teleport_trl(i) = t_teleport_temp(end); end
    t_flyON_temp = t_flyON(t_flyON > (t.beg(i) - jitter) &  (t_flyON < t.beg(i) + jitter));
    if ~isempty(t_flyON_temp), t_flyON_trl(i) = t_flyON_temp(end); end
end
tflyON_minus_teleport = nanmedian(t_flyON_trl - t_teleport_trl);
% set trial begin time equal to target onset
t_beg_original = t.beg;
for i=1:length(t.beg)
    if ~isnan(t_flyON_trl(i)), t.beg(i) = t_flyON_trl(i);
    elseif ~isnan(t_teleport_trl(i)), t.beg(i) = t_teleport_trl(i) + tflyON_minus_teleport;
    end
end
t_beg_correction = t.beg - t_beg_original;


%% detect start-of-movement and end-of-movement times for each trial
v_thresh = prs.v_thresh; w_thresh = prs.w_thresh;
v_time2thresh = prs.v_time2thresh;
v = ch.v; w = ch.w;
for j=1:length(t.end)
   % start-of-movement
   if j==1, t.move(j) = t.beg(j); % first trial is special because there is no pre-trial period
   else
       indx = find(v(ts>t.end(j-1) & ts<t.end(j)) > v_thresh,1); % first upward threshold-crossing
       if ~isempty(indx), t.move(j) = t.end(j-1) + indx*dt;
       else, t.move(j) = t.beg(j); end % if monkey never moved, set movement onset = target onset
   end
   % end-of-movement
   indx = find(abs(v(ts>t.move(j) & ts<t.end(j))) < v_thresh & abs(w(ts>t.move(j) & ts<t.end(j))) < w_thresh,1); % first downward threshold-crossing
   if ~isempty(indx), t.stop(j) = t.move(j) + indx*dt;
   else, t.stop(j) = t.end(j); end % if monkey never stopped, set movement end = trial end
   % if monkey stopped prematurely, set movement end = trial end
   if (t.stop(j)<t.beg(j) || (t.stop(j)-t.move(j))<prs.mintrialduration)
       % second attempt to locate t_stop (added 12-04-2019)
       indx = find(abs(v(ts>t.beg(j) & ts<t.end(j))) > v_thresh | abs(w(ts>t.beg(j) & ts<t.end(j))) > w_thresh,1,'last');
       if ~isempty(indx), t.stop(j) = t.beg(j) + indx*dt;
       else, t.stop(j) = t.end(j); end
   end
end

%% extract trials and downsample for storage
dt_original = dt;
dt = dt*prs.factor_downsample;
for j=1:length(t.end)
    % define pretrial period
    pretrial = max(t.beg(j) - t.move(j),0) + prs.pretrial; % extract everything from "movement onset - pretrial" or "target onset - pretrial" - whichever is first
    posttrial = prs.posttrial; % extract everything until "t_end + posttrial"
    for i=1:length(chnames)
        if ~any(strcmp(chnames{i},'mrk'))
            trl(j).continuous.(chnames{i}) = ch.(chnames{i})(ts>t.beg(j)-pretrial & ts<t.end(j)+posttrial);
            if any(strcmp(chnames{i},{'xfp','xmp','yfp','ymp'})) % set position values prior to target onset to nan
                trl(j).continuous.(chnames{i})(1:floor(pretrial/dt_original)) = nan;
            end
            if ~strcmp(chnames{i},'microstim'), trl(j).continuous.(chnames{i}) = downsample(trl(j).continuous.(chnames{i}),prs.factor_downsample);
            else, trl(j).continuous.ts_microstim = (dt_original:dt_original:length(trl(j).continuous.microstim)*dt_original)' - pretrial; end
        end
    end
    trl(j).continuous.ts = (dt:dt:length(trl(j).continuous.(chnames{2}))*dt)' - pretrial;
    trl(j).continuous.firefly = trl(j).continuous.ts>=0 & trl(j).continuous.ts<(0+prs.fly_ONduration);
    trl(j).events.t_beg = t.beg(j);
    trl(j).events.t_end = t.end(j);
    trl(j).events.t_move = t.move(j);
    trl(j).events.t_stop = t.stop(j);
    % saccade time
    trl(j).events.t_sac = t.saccade(t.saccade>(t.beg(j)-pretrial) & t.saccade<t.end(j));
    % fixation start times
    trl(j).events.t_fix = t.fix(t.fix>(t.beg(j)-3*pretrial) & t.fix<(t.end(j)+3*posttrial)); % wider search-range because fixation might be outside trial
    t.fix(t.fix>(t.beg(j)-3*pretrial) & t.fix<(t.end(j)+3*posttrial)) = []; % remove from list
    % reward time
    if any(t.reward>t.beg(j) & t.reward<t.end(j))
        trl(j).logical.reward = true;
        trl(j).events.t_rew = t.reward(t.reward>t.beg(j) & t.reward<t.end(j));
    else
        trl(j).logical.reward = false;
        trl(j).events.t_rew = nan;
    end
    % ptb time
    if any(t.ptb>t.beg(j) & t.ptb<t.end(j)) && ~(numel(t.microstim) == numel(t.ptb)) % cannot perturb and stimulate simultaneously
        trl(j).logical.ptb = true;
        trl(j).events.t_ptb = t.ptb(t.ptb>t.beg(j) & t.ptb<t.end(j));
    else
        trl(j).logical.ptb = false;
        trl(j).events.t_ptb = nan;
    end
    % microstimulation time
    if any(t.microstim>t.beg(j) & t.microstim<t.end(j))
        trl(j).logical.microstim = true;
        trl(j).events.t_microstim = t.microstim(t.microstim>t.beg(j) & t.microstim<t.end(j));
    else
        trl(j).logical.microstim = false;
        trl(j).events.t_microstim = nan;
    end
end

%% timestamps referenced relative to exp_beg
exp_beg = t.events(find(markers==1,1,'first'));
exp_end = t.events(find(markers==3,1,'last'));

for i=1:length(trl)
    trl(i).events.t_beg = trl(i).events.t_beg - exp_beg;
    trl(i).events.t_rew = trl(i).events.t_rew - exp_beg - trl(i).events.t_beg; % who cares about absolute time?!
    trl(i).events.t_end = trl(i).events.t_end - exp_beg - trl(i).events.t_beg;    
    trl(i).events.t_sac = trl(i).events.t_sac - exp_beg - trl(i).events.t_beg;
    trl(i).events.t_fix = trl(i).events.t_fix - exp_beg - trl(i).events.t_beg;
    trl(i).events.t_move = trl(i).events.t_move - exp_beg - trl(i).events.t_beg;
    trl(i).events.t_stop = trl(i).events.t_stop - exp_beg - trl(i).events.t_beg;
    trl(i).events.t_ptb = trl(i).events.t_ptb - exp_beg - trl(i).events.t_beg;
    trl(i).events.t_microstim = trl(i).events.t_microstim - exp_beg - trl(i).events.t_beg;
    trl(i).events.t_targ = 0;
    trl(i).events.t_beg_correction = t_beg_correction(i);
    trl(i).events.t_flyON = t_flyON_trl(i) - exp_beg;
    trl(i).events.t_flyON_minus_teleport = t_flyON_trl(i) - t_teleport_trl(i);
end

%% detect trials where targets appeared again during the trial
for i=1:length(trl)
    timeindx = trl(i).continuous.ts<trl(i).events.t_end;
    dPf__dt = [0 ; sqrt(diff(trl(i).continuous.xfp(timeindx)).^2 + diff(trl(i).continuous.yfp(timeindx)).^2)];
    if findpeaks(dPf__dt,dt*(1:length(dPf__dt)),'MinPeakHeight',prs.minpeakprominence.flypos)>0 % detect peaks
        trl(i).logical.spurioustarg = true;
    else
        trl(i).logical.spurioustarg = false;
    end
end

%% downsample continuous data
for i=1:length(chnames)
    if ~any(strcmp(chnames{i},'mrk'))
        ch.(chnames{i}) = ch.(chnames{i})(ts>exp_beg & ts<exp_end);
        ch.(chnames{i}) = downsample(ch.(chnames{i}),prs.factor_downsample);
    end
end
ts = ts(ts>exp_beg & ts<exp_end) - exp_beg;
ch.ts = downsample(ts,prs.factor_downsample); ch.ts = ch.ts(:);
ch.ntrls = length(trl);