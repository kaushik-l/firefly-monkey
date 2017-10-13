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

%% event markers
markers = data(chno.mrk).imp.mrk(:,1);
%% event times
t.events = double(data(chno.mrk).imp.tim)*scaling.t;
t.beg = t.events(markers ==2); 
t.end = t.events(markers ==3); 
t.reward = t.events(markers ==4);
t.beg = t.beg(1:length(t.end));
t.ptb = t.events(markers==5 | markers==8);

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
if length(unique(dt))==1
    dt = dt(1);
else
   error('channels must all have identical sampling rates');
end

%% filter position and velocity channels
for i=1:length(chnames)
    if ~any(strcmp(chnames{i},{'mrk','yle','yre','zle','zre'}))
        ch.(chnames{i}) = conv(ch.(chnames{i})(1:MAX_LENGTH),h,'same');
%         ch.(chnames{i}) = ch.(chnames{i})(sz/2+1:end);
    end
end
ch.yle = ch.yle(1:MAX_LENGTH);
ch.yre = ch.yre(1:MAX_LENGTH);
ch.zle = ch.zle(1:MAX_LENGTH);
ch.zre = ch.zre(1:MAX_LENGTH);
ts = dt:dt:length(ch.(chnames{end}))*dt;

%% detect saccade times
% take derivative of eye position = eye velocity
if (var(ch.zle) > var(ch.zre)) % use the eye with a working eye coil
    dze = diff(ch.zle);
    dye = diff(ch.yle);
else
    dze = diff(ch.zre);
    dye = diff(ch.yre);
end
de = sqrt(dze.^2 + dye.^2); % speed of eye movement

% apply threshold on eye speed
saccade_thresh = prs.saccade_thresh;
thresh = saccade_thresh/prs.fs_smr; % threshold in units of deg/sample
indx_thresh = de>thresh;
dindx_thresh = diff(indx_thresh);
t_saccade = find(dindx_thresh>0)/prs.fs_smr;

% remove duplicates by applying a saccade refractory period
min_isi = prs.min_intersaccade;
t_saccade(diff(t_saccade)<min_isi) = [];
t.saccade = t_saccade;

%% replace the broken eye coil (if any) with NaNs
if var(ch.zle) > 2*var(ch.zre)
    ch.zre(:) = nan;
    ch.yre(:) = nan;
elseif var(ch.zre) > 2*var(ch.zle)
    ch.zle(:) = nan;
    ch.yle(:) = nan;
end

%% detect start-of-movement and end-of-movement times for each trial
v_thresh = prs.v_thresh;
v_time2thresh = prs.v_time2thresh;
v = ch.v;
for j=1:length(t.end)
   % start-of-movement
   if j==1, t.move(j) = t.beg(j); % first trial is special because there is no pre-trial period
   else
       indx = find(v(ts>t.end(j-1) & ts<t.end(j)) > v_thresh,1); % first upward threshold-crossing
       if ~isempty(indx), t.move(j) = t.end(j-1) + indx*dt;
       else, t.move(j) = t.beg(j); end % if monkey never moved, set movement onset = target onset
   end
   % end-of-movement
   indx = find(v(ts>t.move(j) & ts<t.end(j)) < v_thresh,1); % first downward threshold-crossing
   if ~isempty(indx), t.stop(j) = t.move(j) + indx*dt;
   else, t.stop(j) = t.end(j); end % if monkey never stopped, set movement end = trial end
   % if monkey stopped prematurely, set movement end = trial end
   if (t.stop(j)<t.beg(j) || t.stop(j)-t.move(j)<0.5), t.stop(j) = t.end(j); end
end

%% extract trials and downsample for storage
dt = dt*prs.factor_downsample;
for j=1:length(t.end)
    % define pretrial period
    pretrial = max(t.beg(j) - t.move(j),0); % extract everything from movement onset or target onset - whichever is first
    for i=1:length(chnames)
        if ~any(strcmp(chnames{i},'mrk'))
            trl(j).continuous.(chnames{i}) = ch.(chnames{i})(ts>t.beg(j)-pretrial & ts<t.end(j));
            trl(j).continuous.(chnames{i}) = downsample(trl(j).continuous.(chnames{i}),prs.factor_downsample);
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
    % reward time
    if any(t.reward>t.beg(j) & t.reward<t.end(j))
        trl(j).logical.reward = true;
        trl(j).events.t_rew = t.reward(t.reward>t.beg(j) & t.reward<t.end(j));
    else
        trl(j).logical.reward = false;
        trl(j).events.t_rew = nan;
    end
    % ptb time
    if any(t.ptb>t.beg(j) & t.ptb<t.end(j))
        trl(j).logical.ptb = true;
        trl(j).events.t_ptb = t.ptb(t.ptb>t.beg(j) & t.ptb<t.end(j));
    else
        trl(j).logical.ptb = false;
        trl(j).events.t_ptb = nan;
    end
end

%% set position values prior to target onset to nan
for j=1:length(trl)
    for i=1:length(chnames)
        if any(strcmp(chnames{i},{'xfp','xmp','yfp','ymp'}))
            trl(j).continuous.(chnames{i})(trl(j).continuous.ts<0.2) = nan; % remember to change 0.2 to the actual target onset time
        end
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
    trl(i).events.t_move = trl(i).events.t_move - exp_beg - trl(i).events.t_beg;
    trl(i).events.t_stop = trl(i).events.t_stop - exp_beg - trl(i).events.t_beg;
    trl(i).events.t_ptb = trl(i).events.t_ptb - exp_beg - trl(i).events.t_beg;
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