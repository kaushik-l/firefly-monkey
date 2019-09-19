function prs = default_prs(monk_id,session_id)

if nargin<2, session_id = 1; end
getnthcell = @(x,n) x{n};

%% session specific parameters
monkeyInfoFile_joysticktask;
monkeyInfo = monkeyInfo([monkeyInfo.session_id]==session_id & [monkeyInfo.monk_id]==monk_id);
prs.filepath_behv = ['C:\Users\eao5\Documents\temp_data\' monkeyInfo.folder '\behavioural data\'];
prs.filepath_neur = ['C:\Users\eao5\Documents\temp_data\' monkeyInfo.folder '\neural data\'];
prs.filepath_neuralnet = 'C:\Users\jkl9\Documents\GitHub\spykesML\MLencoding\';
prs.sess_date = datestr(datenum(getnthcell(split(monkeyInfo.folder,'\'),3)));
prs.coord = monkeyInfo.coord;
prs.units = monkeyInfo.units;
prs.electrode_type = monkeyInfo.electrode_type;
prs.area = monkeyInfo.area;
prs.comments = monkeyInfo.comments;
prs.eyechannels = monkeyInfo.eyechannels;

%% data acquisition parameters
prs.fs_smr = 5000/6; % sampling rate of smr file
prs.fs_lfp = 500; % sampling rate of smr file
prs.filtwidth = 2; % width in samples (10 samples @ fs_smr = 10x0.0012 = 12 ms)
prs.filtsize = 2*prs.filtwidth; % size in samples
prs.factor_downsample = 5; % select every nth sample
prs.dt = prs.factor_downsample/(prs.fs_smr);
prs.screendist = 32.5; %cm
prs.height = 10; %cm
prs.interoculardist = 3.5; %cm
prs.framerate = 60; %(sec)^-1
prs.x0 = 0; % x-position at trial onset (cm)
prs.y0 = -32.5; %y-position at trial onset (cm)
prs.jitter_marker = 0.25; % variability in marker time relative to actual event time (s)
prs.mintrialduration = 0.5; % to detect bad trials (s)
prs.electrodespacing = 0.4; %distance (mm) between electrode sites on the array

%% electrode parameters
prs.linearprobe.types = {'linearprobe16','linearprobe24','linearprobe32'};
prs.linearprobe.channelcount = [16 24 32];
prs.utaharray.types = {'utah96','utah2x48'};
prs.utaharray.channelcount = [96 96];
prs.MapDualArray2BrainArea = @(x,y) char((y<=48)*x{1} + (y>48)*x{2});

%% static stimulus parameters
prs.monk_startpos = [0 -30];
prs.fly_ONduration = 0.3;
prs.saccadeduration = 0.05; % saccades last ~50ms

%% data analysis parameters
% behavioural analysis
prs.mintrialsforstats = 50; % need at least 100 trials for stats to be meaningful
prs.npermutations = 50; % number of permutations for trial shuffled estimates
prs.saccade_thresh = 50; % deg/s
prs.saccade_duration = 0.15; %seconds
prs.v_thresh = 5; % cm/s
prs.w_thresh = 3; % cm/s
prs.v_time2thresh = 0.05; % (s) approx time to go from zero to threshold or vice-versa
prs.ncorrbins = 100; % 100 bins of data in each trial
prs.pretrial = 0.5; % (s) // duration to extract before target onset or movement onset, whichever is earlier
prs.posttrial = 0.5; % (s) // duration to extract following end-of-trial timestamp
prs.min_intersaccade = 0.1; % (s) minimum inter-saccade interval
prs.maxtrialduration = 4; % (s) more than this is abnormal
prs.minpeakprominence.monkpos = 10; % expected magnitude of change in monkey position during teleportation (cm)
prs.minpeakprominence.flypos = 1; % expected magnitude of change in fly position in consecutive trials (cm)
prs.fixateduration = 0.75; % length of fixation epochs (s)
prs.fixate_thresh = 4; % max eye velocity during fixation (deg/s)
prs.ptb_sigma = 1/6; % width of the gaussian func for ptb (s)
prs.ptb_duration = 1; % duration fo ptb (s)
prs.blink_thresh = 50; % threshold to remove eye blinks
prs.nanpadding = 5; % 

% lfp
prs.lfp_filtorder = 4;
prs.lfp_freqmin = 0.5; % min frequency (Hz)
prs.lfp_freqmax = 75; % max frequency (Hz)
prs.spectrum_tapers = [1 1]; % [time-bandwidth-product number-of-tapers]
prs.spectrum_trialave = 1; % 1 = trial-average
prs.spectrum_movingwin = [1.5 1.5]; % [window-size step-size] to compute frequency spectrum (s)
prs.min_stationary = 0.5; % mimimum duration of stationary period for LFP analysis (s)
prs.min_mobile = 0.5; % mimimum duration of mobile period for LFP analysis (s)
prs.lfp_theta = [6 12]; prs.lfp_theta_peak = 8.5;
prs.lfp_beta = [12 20]; prs.lfp_beta_peak = 18.5;
prs.sta_window = [-1 1]; % time-window of STA
prs.duration_nanpad = 1; % nans to pad to end of trial before concatenating (s)
prs.phase_slidingwindow = 0.05:0.05:2; % time-lags for computing time-varying spike phase (s)
prs.num_phasebins = 25; % divide phase into these many bins

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
prs.minpeakprominence.neural = 2; % minimum height of peak response relative to closest valley (spk/s)

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
prs.tuning.nbins1d_binning = 20; % bin edges for tuning curves by 'binning' method
prs.tuning.nbins2d_binning = [20;20]; % define bin edges for 2-D tuning curves by 'binning' method
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
prs.tuning.use_binrange = true;

% range of stimulus values [min max]
prs.binrange.v = [0 ; 200]; %cm/s
prs.binrange.w = [-90 ; 90]; %deg/s
prs.binrange.r_targ = [0 ; 400]; %cm
prs.binrange.theta_targ = [-60 ; 60]; %cm
prs.binrange.d = [0 ; 400]; %cm
prs.binrange.phi = [-90 ; 90]; %deg
prs.binrange.h1 = [-0.36 ; 0.36]; %s
prs.binrange.h2 = [-0.36 ; 0.36]; %s
prs.binrange.eye_ver = [-25 ; 0]; %deg
prs.binrange.eye_hor = [-40 ; 40]; %deg
prs.binrange.veye_vel = [-15 ; 5]; %deg
prs.binrange.heye_vel = [-30 ; 30]; %deg
prs.binrange.phase = [-pi ; pi]; %rad
prs.binrange.target_ON = [-0.24 ; 0.48]; %s
prs.binrange.target_OFF = [-0.36 ; 0.36]; %s
prs.binrange.move = [-0.36 ; 0.36]; %s
prs.binrange.stop = [-0.36 ; 0.36]; %s
prs.binrange.reward = [-0.36 ; 0.36]; %s
prs.binrange.spikehist = [0.012 ; 0.252]; %s

% fitting models to neural data
prs.neuralfiltwidth = 10;
prs.nfolds = 5; % number of folds for cross-validation

% decoder - parameters
prs.decodertype = 'lineardecoder'; % name of model to fit: linear regression == 'LR'
prs.lineardecoder_fitkernelwidth = false;
prs.lineardecoder_subsample = false;
prs.N_neurons = 2.^(0:9); % number of neurons to sample
prs.N_neuralsamples = 20; % number of times to resample neurons

%% hash table to map layman terms to variable names
prs.varlookup = containers.Map;
prs.varlookup('target_ON') = 't_targ';
prs.varlookup('target_OFF') = 't_targ';
prs.varlookup('move') = 't_move';
prs.varlookup('stop') = 't_stop';
prs.varlookup('reward') = 't_rew';
prs.varlookup('v') = 'lin vel';
prs.varlookup('w') = 'ang vel';
prs.varlookup('d') = 'dist moved';
prs.varlookup('phi') = 'ang turned';
prs.varlookup('h1') = 'hand vel PC1';
prs.varlookup('h2') = 'hand vel PC2';
prs.varlookup('r_targ') = 'targ dist';
prs.varlookup('theta_targ') = 'targ ang';
prs.varlookup('phase') = 'lfp phase';
prs.varlookup('spikehist') = 'spike history';

%% has table to specify units of measurement
prs.unitlookup = containers.Map;
prs.unitlookup('target_ON') = 's';
prs.unitlookup('target_OFF') = 's';
prs.unitlookup('move') = 's';
prs.unitlookup('stop') = 's';
prs.unitlookup('reward') = 's';
prs.unitlookup('v') = 'cm/s';
prs.unitlookup('w') = 'deg/s';
prs.unitlookup('d') = 'cm';
prs.unitlookup('phi') = 'deg';
prs.unitlookup('h1') = 'pixels/s';
prs.unitlookup('h2') = 'pixels/s';
prs.unitlookup('r_targ') = 'cm';
prs.unitlookup('theta_targ') = 'deg';
prs.unitlookup('phase') = 'rad';
prs.unitlookup('spikehist') = 's';

%% plotting parameters
prs.binwidth_abs = prs.temporal_binwidth; % use same width as for the analysis
prs.binwidth_warp = 0.01;
prs.trlkrnlwidth = 50; % width of the gaussian kernel for trial averaging (number of trials)
prs.maxtrls = 5000; % maximum #trials to plot at once.
prs.rewardwin = 65; % size of reward window (cm)
prs.maxrewardwin = 400; % maximum reward window for ROC analysis
prs.bootstrap_trl = 50; % number of trials to bootstrap

%% list of analyses to perform
% *specify methods and variables for analyses (fewer => faster obvisously)*
%% traditional methods
prs.hand_features = {'Finger1','Finger2','Finger3','Finger4','Wrist-down','Wrist-up','Hand-down','Hand-up'};
prs.tuning_events = {'move','target','stop','reward'}; % discrete events - choose from elements of event_vars (above)
prs.tuning_continuous = {'v','w','r_targ','theta_targ','d','phi','eye_ver','eye_hor','phase'}; % continuous variables - choose from elements of continuous_vars (above)
prs.tuning_method = 'binning'; % choose from (increasing computational complexity): 'binning', 'k-nearest', 'nadaraya-watson', 'local-linear'
%% GAM fitting
prs.GAM_varname = {'v','w','d','phi','h1','h2','phase','move','target_OFF','stop','reward','spikehist'}; % list of variable names to include in the generalised additive model
prs.GAM_vartype = {'1D','1D','1D','1D','event','event','1Dcirc','event','event','event','event','event'}; % type of variable: '1d', '1dcirc', 'event'
prs.GAM_basistype = {'boxcar','boxcar','boxcar','boxcar','raisedcosine','raisedcosine',...
    'boxcar','raisedcosine','raisedcosine','raisedcosine','raisedcosine','nlraisedcosine'}; % type of variable: 'boxcar', 'raisedcosine', 'nlraisedcosine'
prs.GAM_linkfunc = 'log'; % choice of link function: 'log','identity','logit'
prs.GAM_nbins = {10,10,10,10,20,20,10,20,20,20,20,20}; % number of bins for each variable
prs.GAM_lambda = {5e1,5e1,5e1,5e1,5e1,5e1,5e1,5e1,5e1,5e1,5e1,5e1}; % hyperparameter to penalise rough weight profiles
prs.GAM_alpha = 0.05; % significance level for model comparison
prs.GAM_varchoose = [1,1,1,1,1,1,1,1,1,1,1,1]; % set to 1 to always include a variable, 0 to make it optional
prs.GAM_method = 'Backward'; % use ('Backward') backward elimination or ('Forward') forward-selection method
%% NNM fitting
prs.NNM_varname = prs.GAM_varname;
prs.NNM_vartype = prs.GAM_vartype;
prs.NNM_nbins = prs.GAM_nbins;
prs.NNM_method = 'feedforward_nn'; % choose from 'feedforward_nn', 'random_forest' or 'xgboost'
%% population analysis
prs.canoncorr_varname = {'v','w','d','phi','dv','dw'}; % list of variables to include in the task variable matrix
prs.simulate_varname = {'v','w','d','phi','dv','dw'}; % list of variables to use as inputs in simulation
prs.simulate_vartype = {'1D','1D','1D','1D','1D','1D','1D','1D'};
% prs.readout_varname = {'v','w','d','phi','r_targ','theta_targ','dv','dw','eye_ver','eye_hor'};
prs.readout_varname = {'v','w','d','phi','r_targ','theta_targ'}; %,'dv','dw','eye_ver','eye_hor'};

%% ****which analyses to do****
%% behavioural
prs.split_trials = true; % split trials into different stimulus conditions
prs.regress_behv = false; % regress response against target position
prs.regress_eye = false; % regress eye position against target position

%% spikes
% traditional methods
prs.evaluate_peaks = false; % evaluate significance of event-locked responses
prs.compute_tuning = false; % compute tuning functions
%% GAM fitting
prs.fitGAM_tuning = false; % fit generalised additive models to single neuron responses using both task variables + events as predictors
prs.GAM_varexp = false; % compute variance explained by each predictor using GAM
prs.fitGAM_coupled = true; % fit generalised additive models to single neuron responses with cross-neuronal coupling
%% NNM fitting
prs.fitNNM = false;
%% population analysis
prs.compute_canoncorr = false; % compute cannonical correlation between population response and task variables
prs.regress_popreadout = false; % regress population activity against individual task variables
prs.simulate_population = false; % simulate population activity by running the encoding models
prs.corr_neuronbehverr = false;

%% LFP
prs.event_potential = false;
prs.compute_spectrum = false;
prs.analyse_theta = false;
prs.analyse_beta = false;
prs.compute_coherencyLFP = false;

%% Spike-LFP
prs.analyse_spikeLFPrelation = false;
prs.analyse_spikeLFPrelation_allLFPs = false; % spike-LFP for LFPs from all electrodes
prs.analyse_temporalphase = false;