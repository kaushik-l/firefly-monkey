function prs = default_prs(monk_id,session_id)

if nargin<2, session_id = 1; end

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
prs.binwidth = 1/(prs.fs_smr/prs.factor_downsample); % binwidth for neural data analysis (s)
prs.spkkrnlwidth = 0.05; % width of the gaussian kernel convolved with spike trains (s)
prs.spkkrnlwidth = prs.spkkrnlwidth/prs.binwidth; % width in samples
prs.spkkrnlsize = round(10*prs.spkkrnlwidth);
prs.corr_lag = 1; % timescale of correlograms (s)
prs.corr_lag = round(prs.corr_lag/prs.binwidth); % lag in samples
prs.bootstrap_trl = 100; % number of bootstraps for trial-shuffled estimates
prs.saccade_thresh = 120; % deg/s
prs.ncorrbins = 100; % 100 bins of data in each trial
prs.pretrial = 0.25; % (s)
prs.posttrial = 0.25; % (s)

%% plotting parameters
prs.binwidth_abs = prs.binwidth; % use same width as for the analysis
prs.binwidth_warp = 0.01;
prs.trlkrnlwidth = 100; % width of the gaussian kernel for trial averaging (number of trials)
prs.maxtrls = 5000; % maximum #trials to plot at once.
prs.rewardwin = 65; % size of reward window
prs.maxrewardwin = 400; % maximum reward window for ROC analysis

%% temporary testing
prs.goodunits = [6 8 13 16 18 19 20 21 23 24 25 26 27 29 30 32 39 41 43 44 45 47 49 51 53 55 ...
    57 59 60 63 67 68 70 71 73 75 76 77 78 81 83 86 87 88 89 90 91 92 93 94 96];
% prs.goodorder = [51 55 8 90 77 70 23 59 44 43 25 26 57 96 27 81 18 21 92 30 91 76 93 94 29 ...
%     88 20 16 13 75 45 6];
nsua = 51;
prs.goodorder = [5 6 9 10 18 23 25 26 31 33 34 37 38 40 43 47 nsua+([9 21 27 36 38 50 57 66]) 48 nsua+([59 62]) ...
    nsua+([43 31 41 42 40]) 1 28 22 nsua+([18 61 65 55]) 27 42 ...
    nsua+19 41 14 25 46 nsua+([28 64]) nsua+([29 44]) 35 36 8 ...
    nsua+44 24 32 nsua+45 49 4 2 3 ...
    50 51 19 30 nsua+([10 14 15 16 67]) 12 15 16 19 14 20 21 39 45 nsua+([2 4 6 7 13 17 20 22 33 37 52 53])];
prs.units = [59 77];