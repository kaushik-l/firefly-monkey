function [ch,trl] = AddSMRData(data,prs)

%% check channel headers
nch = length(data);
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

%% filter position and speed channels
for i=1:length(chnames)
    if ~any(strcmp(chnames{i},{'mrk','yle','yre','zle','zre'}))
        ch.(chnames{i}) = conv(ch.(chnames{i})(1:MAX_LENGTH),h,'same');
%         ch.(chnames{i}) = ch.(chnames{i})(sz/2+1:end);
    end
end
ts = dt:dt:length(ch.(chnames{end}))*dt;

%% extract trials
dt = dt*prs.factor_downsample;
for j=1:length(t.end)
    for i=1:length(chnames)
        if ~any(strcmp(chnames{i},'mrk'))
            trl(j).(chnames{i}) = ch.(chnames{i})(ts>t.beg(j) & ts<t.end(j));
            trl(j).(chnames{i}) = downsample(trl(j).(chnames{i}),prs.factor_downsample);
        end
    end
    trl(j).ts = (dt:dt:length(trl(j).(chnames{2}))*dt)';
    trl(j).t_beg = t.beg(j);
    trl(j).t_end = t.end(j);
    if any(t.reward>t.beg(j) & t.reward<t.end(j))
        trl(j).reward = true;
        trl(j).t_rew = t.reward(t.reward>t.beg(j) & t.reward<t.end(j));
    else
        trl(j).reward = false;
        trl(j).t_rew = nan;
    end
end

exp_beg = t.events(find(markers==1,1,'first'));
exp_end = t.events(find(markers==3,1,'last'));
%% timestamps referenced relative to exp_beg
for i=1:length(trl)
    trl(i).t_beg = trl(i).t_beg - exp_beg;
    trl(i).t_end = trl(i).t_end - exp_beg;
    trl(i).t_rew = trl(i).t_rew - exp_beg;
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