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
prs.dt = 10/(prs.fs_smr);
prs.screendist = 32.5;
prs.height = 10;
prs.framerate = 60;
prs.x0 = 0; % x-position at trial onset (cm)
prs.y0 = -32.5; %y-position at trial onset (cm)

%% static stimulus parameters
prs.monk_startpos = [0 -30];
prs.fly_ONduration = 0.3;
prs.saccadeduration = 0.05; % saccades last ~50ms

%% data analysis parameters
% behavioural analysis
prs.mintrialsforstats = 50; % need at least 100 trials for stats to be meaningful
prs.npermutations = 50; % number of permutations for trial shuffled estimates
prs.saccade_thresh = 120; % deg/s
prs.v_thresh = 5; % cm/s
prs.v_time2thresh = 0.05; % (s) approx time to go from zero to threshold or vice-versa
prs.ncorrbins = 100; % 100 bins of data in each trial
prs.pretrial = 0.25; % (s)
prs.posttrial = 0.25; % (s)
prs.min_intersaccade = 0.1; % (s) minimum inter-saccade interval

% time window for psth of event aligned responses
prs.temporal_binwidth = 0.02; % time binwidth for neural data analysis (s)
prs.spkkrnlwidth = 0.05; % width of the gaussian kernel convolved with spike trains (s)
prs.spkkrnlwidth = prs.spkkrnlwidth/prs.temporal_binwidth; % width in samples
prs.spkkrnlsize = round(10*prs.spkkrnlwidth);
prs.ts.move = -0.5:prs.temporal_binwidth:3.5;
prs.ts.target = -0.5:prs.temporal_binwidth:3.5;
prs.ts.stop = -3.5:prs.temporal_binwidth:0.5;
prs.ts.reward = -3.5:prs.temporal_binwidth:0.5;
prs.peaktimewindow = [-0.5 0.5]; % time-window around the events within which to look for peak response
prs.minpeakprominence = 2; % minimum height of peak response relative to closest valley (spk/s)

% time-rescaling analysis
prs.ts_shortesttrialgroup.move = -0.5:prs.temporal_binwidth:1.5;
prs.ts_shortesttrialgroup.target = -0.5:prs.temporal_binwidth:1.5;
prs.ts_shortesttrialgroup.stop = -1.5:prs.temporal_binwidth:0.5;
prs.ts_shortesttrialgroup.reward = -1.5:prs.temporal_binwidth:0.5;
prs.ntrialgroups = 5; % number of groups based on trial duration

% correlograms
prs.duration_zeropad = 0.05; % zeros to pad to end of trial before concatenating (s)
prs.corr_lag = 1; % timescale of correlograms +/-(s)

% computing standard errors
prs.nbootstraps = 100; % number of bootstraps for estimating standard errors

% define no. of bins for tuning curves by binning method
prs.tuning.nbins1d_binning = 10; % bin edges for tuning curves by 'binning' method
prs.tuning.nbins2d_binning = [10;10]; % define bin edges for 2-D tuning curves by 'binning' method
% define no. of nearest neighbors for tuning curves by k-nearest neighbors method
prs.tuning.k_knn = @(x) round(sqrt(x)); % k=sqrt(N) where N is the total no. of observations
prs.tuning.nbins1d_knn = 100; prs.tuning.nbins2d_knn = [100 ; 100];
% define kernel type for tuning curves by Nadayara-Watson kernel regression
prs.tuning.kernel_nw = 'Gaussian'; % choose from 'Uniform', 'Epanechnikov', 'Biweight', 'Gaussian'
prs.tuning.bandwidth_nw = []; prs.tuning.bandwidth2d_nw = [];
prs.tuning.nbins_nw = []; prs.tuning.nbins2d_nw = [];
% define kernel type for tuning curves by local linear regression
prs.tuning.kernel_locallinear = 'Gaussian'; % choose from 'Uniform', 'Epanechnikov', 'Biweight', 'Gaussian'
prs.tuning.bandwidth_locallinear = [];

% range of stimulus values [min max]
prs.binrange.v = [0 ; 200]; %cm/s
prs.binrange.w = [-90 ; 90]; %deg/s
prs.binrange.r_targ = [0 ; 400]; %cm
prs.binrange.d = [0 ; 400]; %cm
prs.binrange.phi = [-90 ; 90]; %deg

% fitting models to neural data
prs.neuralfiltwidth = 15;
prs.nfolds = 10; % number of folds for cross-validation

% Generalised additive model - parameters
prs.GAM_nbins = {10,10,10,10}; % number of bins for each variable
prs.GAM_lambda = {5e1,5e1,5e1,5e1}; % hyperparameter to penalise rough weight profiles
prs.GAM_alpha = 0.05; % significance level for model comparison

% Gradient descent - parameters
prs.GD_alpha = 1;
prs.GD_niters = 1000;
prs.GD_featurescale = false;
prs.GD_modelname = 'LR'; % name of model to fit: linear regression == 'LR'

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
prs.binwidth_abs = prs.temporal_binwidth; % use same width as for the analysis
prs.binwidth_warp = 0.01;
prs.trlkrnlwidth = 50; % width of the gaussian kernel for trial averaging (number of trials)
prs.maxtrls = 5000; % maximum #trials to plot at once.
prs.rewardwin = 65; % size of reward window (cm)
prs.maxrewardwin = 400; % maximum reward window for ROC analysis

%% list of analyses to perform
% specify methods and variables for analyses (fewer => faster obvisously)
prs.tuning_events = {'move','target','stop','reward'}; % discrete events - choose from elements of event_vars (above)
prs.tuning_continuous = {'v','w','d','phi'}; % continuous variables - choose from elements of continuous_vars (above)
prs.tuning_method = 'binning'; % choose from (increasing computational complexity): 'binning', 'k-nearest', 'nadaraya-watson', 'local-linear'
prs.GAM_varname = {'v','w','d','phi'}; % list of variable names to include in the generalised additive model
prs.GAM_vartype = {'1D','1D','1D','1D'}; % type of variable: '1d', '1dcirc'
prs.GAM_linkfunc = 'log'; % choice of link function: 'log','identity','logit'
prs.canoncorr_vars = {'v','w','d','phi'}; % list of variables to include in the task variable matrix
prs.popreadout_continuous = {'v','w','d','phi'};

% which analyses to do
prs.split_trials = true; % split trials into different stimulus conditions
prs.regress_behv = false; % regress response against target position
prs.evaluate_peaks = false; % evaluate significance of event-locked responses
prs.compute_tuning = false; % compute tuning functions
prs.fit_GAM = false; % fit generalised additive models to single neuron responses
prs.fit_GAMcoupled = false; % fit generalised additive models to single neuron responses with cross-neuronal coupling
prs.compute_canoncorr = true; % compute cannonical correlation between population response and task variables
prs.regress_popreadout = false; % regress population activity against individual task variables

%% temporary testing
% prs.goodunits = [6 8 13 16 18 19 20 21 23 24 25 26 27 29 30 32 39 41 43 44 45 47 49 51 53 55 ...
%     57 59 60 63 67 68 70 71 73 75 76 77 78 81 83 86 87 88 89 90 91 92 93 94 96];
% % prs.goodorder = [51 55 8 90 77 70 23 59 44 43 25 26 57 96 27 81 18 21 92 30 91 76 93 94 29 ...
% %     88 20 16 13 75 45 6];
% nsua = 51;
% prs.goodorder = [5 6 9 10 18 23 25 26 31 33 34 37 38 40 43 47 nsua+([9 21 27 36 38 50 57 66]) 48 nsua+([59 62]) ...
%     nsua+([43 31 41 42 40]) 1 28 22 nsua+([18 61 65 55]) 27 42 ...
%     nsua+19 41 14 25 46 nsua+([28 64]) nsua+([29 44]) 35 36 8 ...
%     nsua+44 24 32 nsua+45 49 4 2 3 ...
%     50 51 19 30 nsua+([10 14 15 16 67]) 12 15 16 19 14 20 21 39 45 nsua+([2 4 6 7 13 17 20 22 33 37 52 53])];
% prs.units = [59 77];