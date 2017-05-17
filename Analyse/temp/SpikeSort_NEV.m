%% Manual spike-sorting m44s1249.nev ; May 14 2017

%% channel 3
openNEV('report', 'uV', 'nomat', 'nosave','c:3');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf)<-60 & max(wf)<50 & max(wf(10:20,:))>0;
wf = wf(:,indx); 
% plot(wf); % inspect
tspk = tspk(indx);

%% channel 5
openNEV('report', 'uV', 'nomat', 'nosave','c:5');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-50 & max(wf)<300 & max(wf(25:30,:))>50;
wf = wf(:,indx); 
% plot(wf); % inspect
tspk = tspk(indx);

%% channel 6
openNEV('report', 'uV', 'nomat', 'nosave','c:6');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(12:17,:))<-100 & max(wf)<300 & max(wf(20:24,:))>100;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 8
openNEV('report', 'uV', 'nomat', 'nosave','c:8');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(12:17,:))<-150 & max(wf)<300 & max(wf(20:25,:))>100;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 11
openNEV('report', 'uV', 'nomat', 'nosave','c:11');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(12:16,:))<-50 & max(wf)<300 & max(wf(20:25,:))>25;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 12
openNEV('report', 'uV', 'nomat', 'nosave','c:12');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(12:16,:))<-75 & max(wf)<300 & max(wf(17:25,:))>75;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 16
openNEV('report', 'uV', 'nomat', 'nosave','c:16');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(12:16,:))<-75 & max(wf)<300 & max(wf(20:25,:))>75;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 18
openNEV('report', 'uV', 'nomat', 'nosave','c:18');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(14:17,:))<-60 & max(wf)<300 & max(wf(20:25,:))>50;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 19
openNEV('report', 'uV', 'nomat', 'nosave','c:19');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(12:16,:))<-50 & max(wf)<300 & max(wf(25:30,:))>40;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 21
openNEV('report', 'uV', 'nomat', 'nosave','c:21');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(14:17,:))<-50 & max(wf)<300 & max(wf(20:25,:))>40;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 22
openNEV('report', 'uV', 'nomat', 'nosave','c:22');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:16,:))<-100 & max(wf)<300 & max(wf(18:22,:))>100;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 23
openNEV('report', 'uV', 'nomat', 'nosave','c:23');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:16,:))<-50 & max(wf)<300 & max(wf(20:25,:))>40;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 24
openNEV('report', 'uV', 'nomat', 'nosave','c:24');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:18,:))<-75 & max(wf)<300 & max(wf(20:25,:))>50;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 25
openNEV('report', 'uV', 'nomat', 'nosave','c:25');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-50 & max(wf)<300 & max(wf(23:27,:))>50;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 26
openNEV('report', 'uV', 'nomat', 'nosave','c:26');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-60 & max(wf)<300 & max(wf(20:25,:))>40;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 27
openNEV('report', 'uV', 'nomat', 'nosave','c:27');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(12:16,:))<-60 & max(wf)<450 & max(wf(16:20,:))>100;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 29
openNEV('report', 'uV', 'nomat', 'nosave','c:29');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-75 & max(wf)<300 & max(wf(20:25,:))>25;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 30
openNEV('report', 'uV', 'nomat', 'nosave','c:30');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-50 & max(wf)<300 & max(wf(25:30,:))>40;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 41
openNEV('report', 'uV', 'nomat', 'nosave','c:41');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-50 & max(wf)<300 & max(wf(25:30,:))>10;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 43
openNEV('report', 'uV', 'nomat', 'nosave','c:43');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-100 & max(wf)<300 & max(wf(25:30,:))>50;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 44
openNEV('report', 'uV', 'nomat', 'nosave','c:44');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-50 & max(wf)<300 & max(wf(25:30,:))>40;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 45
openNEV('report', 'uV', 'nomat', 'nosave','c:45');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-50 & max(wf)<300 & max(wf(20:25,:))>50;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 47
openNEV('report', 'uV', 'nomat', 'nosave','c:47');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-50 & max(wf)<300 & max(wf(25:30,:))>40;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 49
openNEV('report', 'uV', 'nomat', 'nosave','c:49');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-50 & max(wf)<300 & max(wf(15:20,:))>40;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 51
openNEV('report', 'uV', 'nomat', 'nosave','c:51');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-60 & max(wf)<300 & max(wf(22:27,:))>50;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 53
openNEV('report', 'uV', 'nomat', 'nosave','c:53');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-75 & max(wf)<300 & max(wf(22:27,:))>75;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 55
openNEV('report', 'uV', 'nomat', 'nosave','c:55');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-75 & max(wf)<300 & max(wf(20:25,:))>0 & all(wf(20:end,:)>-200);
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 57
openNEV('report', 'uV', 'nomat', 'nosave','c:57');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-100 & max(wf)<300 & max(wf(22:27,:))>50;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 59
openNEV('report', 'uV', 'nomat', 'nosave','c:59');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(12:17,:))<-50 & max(wf)<300 & max(wf(20:25,:))>25;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 68
openNEV('report', 'uV', 'nomat', 'nosave','c:68');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(12:15,:))<-50 & max(wf)<300 & max(wf(24:26,:))>40;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 69
openNEV('report', 'uV', 'nomat', 'nosave','c:69');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(12:15,:))<-50 & max(wf)<300 & max(wf(24:26,:))>40;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 71
openNEV('report', 'uV', 'nomat', 'nosave','c:71');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:15,:))<-75 & max(wf)<300 & max(wf(21:23,:))>50;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 73
openNEV('report', 'uV', 'nomat', 'nosave','c:73');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(14:16,:))<-100 & max(wf)<300 & max(wf(21:24,:))>75;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 75
openNEV('report', 'uV', 'nomat', 'nosave','c:75');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:15,:))<-100 & max(wf)<300 & max(wf(18:20,:))>100;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 76
openNEV('report', 'uV', 'nomat', 'nosave','c:76');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:15,:))<-125 & max(wf)<300 & max(wf(23:25,:))>100;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 77
openNEV('report', 'uV', 'nomat', 'nosave','c:77');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:15,:))<-75 & max(wf)<300 & max(wf(16:18,:))>75;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 83
openNEV('report', 'uV', 'nomat', 'nosave','c:83');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-75 & max(wf)<300 & max(wf(19:22,:))>50;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 85
openNEV('report', 'uV', 'nomat', 'nosave','c:85');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:17,:))<-50 & max(wf)<300 & max(wf(20:24,:))>0;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 86
openNEV('report', 'uV', 'nomat', 'nosave','c:86');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:16,:))<-100 & max(wf)<300 & max(wf(17:22,:))>100;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 87
openNEV('report', 'uV', 'nomat', 'nosave','c:87');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:16,:))<-100 & max(wf)<300 & max(wf(17:20,:))>75;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 90
openNEV('report', 'uV', 'nomat', 'nosave','c:90');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(13:16,:))<-50 & max(wf)<300 & max(wf(24:26,:))>50;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 93
openNEV('report', 'uV', 'nomat', 'nosave','c:93');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(14:16,:))<-100 & max(wf)<300 & max(wf(22:24,:))>150;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% channel 94
openNEV('report', 'uV', 'nomat', 'nosave','c:94');
tspk = NEV.Data.Spikes.TimeStamp;
wf = NEV.Data.Spikes.Waveform;
indx = min(wf(14:16,:))<-125 & max(wf)<300 & max(wf(17:18,:))>100;
wf = wf(:,indx); 
plot(wf); % inspect
tspk = tspk(indx);

%% combine files
units = [];
flist = dir('*.mat');
for i=1:length(flist)
    fprintf(['loading ' flist(i).name '\n']);
    load(flist(i).name);
    units(i).tspk = tspk;
    units(i).wf = wf;
    units(i).chno = str2num(flist(i).name(5:6));
    clear tspk wf;
end