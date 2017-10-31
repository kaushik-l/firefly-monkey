function prs = default_prs(monk_id,session_id)

%% session specific parameters
monkeyInfoFile_joysticktask;
monkeyInfo = monkeyInfo([monkeyInfo.session_id]==session_id & [monkeyInfo.monk_id]==monk_id);
prs.filepath_behv = ['C:\Users\erico\Documents\GitHub\DataToAnalyze\' monkeyInfo.folder '\behavioral data\'];
prs.filepath_neur = ['C:\Users\erico\Documents\GitHub\DataToAnalyze\' monkeyInfo.folder '\neural data\'];
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
prs.postrewardtime = 0.5; % time beyond t_rew from which to extract neural and behavioural variables

%% data analysis parameters
prs.binwidth = 1/(prs.fs_smr/prs.factor_downsample); % binwidth for neural data analysis (s)
prs.spkkrnlwidth = 0.05; % width of the gaussian kernel convolved with spike trains (s)
prs.spkkrnlwidth = prs.spkkrnlwidth/prs.binwidth; % width in samples
prs.spkkrnlsize = round(10*prs.spkkrnlwidth);
prs.corr_lag = 1; % timescale of correlograms (s)
prs.corr_lag = round(prs.corr_lag/prs.binwidth); % lag in samples

%% plotting parameters
prs.binwidth_abs = prs.binwidth; % use same width as for the analysis
prs.binwidth_warp = 0.01;
prs.trlkrnlwidth = 150; % width of the gaussian kernel for trial averaging (number of trials)

%% temporary
prs.goodunits = [6 8 13 16 18 19 20 21 23 24 25 26 27 29 30 32 39 41 43 44 45 47 49 51 53 55 ...
    57 59 60 63 67 68 70 71 73 75 76 77 78 81 83 86 87 88 89 90 91 92 93 94 96];
prs.goodorder = [51 55 8 90 77 70 23 59 44 43 25 26 57 96 27 81 18 21 92 30 91 76 93 94 29 ...
    88 20 16 13 75 45 6];
prs.units = [59 77];