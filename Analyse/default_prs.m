function prs = default_prs(monk_id,session_id)

monkeyInfoFile_joysticktask;
monkeyInfo = monkeyInfo([monkeyInfo.session_id]==session_id & [monkeyInfo.monk_id]==monk_id);
prs.filepath_behv = ['C:\Users\jklakshm\Documents\Data\firefly-monkey\' monkeyInfo.folder '\behavioural data\'];
prs.filepath_neur = ['C:\Users\jklakshm\Documents\Data\firefly-monkey\' monkeyInfo.folder '\neural data\'];
prs.maxchannels = max(monkeyInfo.channels);
prs.coord = monkeyInfo.coord;
prs.units = monkeyInfo.units;
prs.comments = monkeyInfo.comments;

prs.fs_smr = 5000/6; % sampling rate of smr file
prs.filtwidth = 10; % width in samples (10 samples @ fs_smr = 12ms)
prs.filtsize = 100; % size in samples
prs.factor_downsample = 10; % select every nth sample
prs.screendist = 32.5;
prs.height = 10;
prs.framerate = 60;
prs.pretrial = 1; %1s pre-trial
prs.posttrial = 1; %1s post-trial