function prs = default_prs(monk_id,session_id)

%% session specific parameters
monkeyInfoFile_joysticktask;
monkeyInfo = monkeyInfo([monkeyInfo.session_id]==session_id & [monkeyInfo.monk_id]==monk_id);
prs.filepath_behv = ['C:\Users\jklakshm\Documents\Data\firefly-monkey\' monkeyInfo.folder '\behavioural data\'];
prs.filepath_neur = ['C:\Users\jklakshm\Documents\Data\firefly-monkey\' monkeyInfo.folder '\neural data\'];
prs.maxchannels = max(monkeyInfo.channels);
prs.coord = monkeyInfo.coord;
prs.units = monkeyInfo.units;
prs.comments = monkeyInfo.comments;

%% data acquisition parameters
prs.fs_smr = 5000/6; % sampling rate of smr file
prs.filtwidth = 10; % width in samples (10 samples @ fs_smr = 10x0.0012 = 12 ms)
prs.filtsize = 10*prs.filtwidth; % size in samples
prs.factor_downsample = 10; % select every nth sample
prs.screendist = 32.5;
prs.height = 10;
prs.framerate = 60;
prs.pretrial = 1; %1s pre-trial
prs.posttrial = 1; %1s post-trial

%% data analysis parameters
prs.binwidth = 1/(prs.fs_smr/prs.factor_downsample); % binwidth for neural data analysis
prs.spkkrnlwidth = 0.05; % width of the gaussian kernel convolved with spike trains (s)
prs.spkkrnlwidth = prs.spkkrnlwidth/prs.binwidth; % width in samples
prs.spkkrnlsize = round(10*prs.spkkrnlwidth);
prs.corr_lag = 1; % timescale of correlograms (s)
prs.corr_lag = round(prs.corr_lag/prs.binwidth); % lag in samples