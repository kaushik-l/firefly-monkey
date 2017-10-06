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

%% static stimulus parameters
prs.monk_startpos = [0 -30];
prs.fly_ONduration = 0.3;
prs.saccadeduration = 0.05; % saccades last ~50ms

%% data analysis parameters
prs.binwidth = 1/(prs.fs_smr/prs.factor_downsample); % binwidth for neural data analysis (s)
prs.spkkrnlwidth = 0.05; % width of the gaussian kernel convolved with spike trains (s)
prs.spkkrnlwidth = prs.spkkrnlwidth/prs.binwidth; % width in samples
prs.spkkrnlsize = round(10*prs.spkkrnlwidth);
prs.corr_lag = 1; % timescale of correlograms (s)
prs.corr_lag = round(prs.corr_lag/prs.binwidth); % lag in samples
prs.bootstrap_trl = 100; % number of bootstraps for trial-shuffled estimates
prs.saccade_thresh = 120; % deg/s
prs.v_thresh = 5; % cm/s
prs.v_time2thresh = 0.05; % (s) approx time to go from zero to threshold or vice-versa
prs.ncorrbins = 100; % 100 bins of data in each trial
prs.pretrial = 0; % (s)
prs.posttrial = 0; % (s)
prs.min_intersaccade = 0.1; % (s) minimum inter-saccade interval

%% GLM fitting parameters
prs.sackrnlwidth = 0.5; %seconds
prs.eyekrnlwidth = 0.5; %seconds
prs.velkrnlwidth = 0.5;
prs.distkrnlwidth = 0.5;
prs.targetkrnlwidth = 0.5;
prs.spikehistkrnlwidth = 0.5;
prs.vars = {'linacc','angacc','firefly','saccade'};%,'angacc','horeye','veryeye','dist2stop'};
prs.nsim = 100; % number of simulations for predicting
prs.nTrials = 900;

% hash table to map variable names used in behaviour structure to the
% ones used in the GLM model (why don't we use the same names??? you won't understand)
prs.varlookup = containers.Map;
prs.varlookup('saccade') = 't_sac';
prs.varlookup('horeye') = 'yle';
prs.varlookup('vereye') = 'zle';
prs.varlookup('linvel') = 'v';
prs.varlookup('angvel') = 'w';
prs.varlookup('linacc') = 'v';
prs.varlookup('angacc') = 'w';
prs.varlookup('firefly') = 'firefly';
prs.varlookup('dist2fly') = 'r_fly';
prs.varlookup('dist2stop') = 'r_stop';

%% plotting parameters
prs.binwidth_abs = prs.binwidth; % use same width as for the analysis
prs.binwidth_warp = 0.01;
prs.trlkrnlwidth = 50; % width of the gaussian kernel for trial averaging (number of trials)
prs.maxtrls = 5000; % maximum #trials to plot at once.
prs.rewardwin = 65; % size of reward window (cm)
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