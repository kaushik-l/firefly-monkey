function weights = ComputeWeights(exp_name,trials_spks,trials_behv,prs)

%% parameters
binSize = double(median(diff(trials_behv(1).ts)));
nTrials = length(trials_spks); % total number of trials
% preallocate structure in memory
trial = struct();
trial(nTrials).duration = 0; % preallocate

for i = 1:nTrials
    trial(i).duration = double(trials_behv(i).ts(end));
    trial(i).eyepos = double([trials_behv(i).yle trials_behv(i).zle]);
    trial(i).linvel = double(trials_behv(i).v);
    trial(i).angvel = double(trials_behv(i).w);
    trial(i).flyon = 1;
    if trials_behv(i).firefly_fullON
        trial(i).flyoff = trial(i).duration;
    else
        trial(i).flyoff = 0.3;
    end
    trial(i).den = double(trials_behv(i).floordensity);
    trial(i).sptrain = trials_spks(i).tspk;
end

%% register variables
expt = buildGLM.initExperiment('s', binSize, exp_name, prs);
expt = buildGLM.registerContinuous(expt, 'eyepos', 'Eye Position', 2); % 2 dimensional observation
expt = buildGLM.registerContinuous(expt, 'linvel', 'Linear Velocity', 1); % linear velocity
expt = buildGLM.registerContinuous(expt, 'angvel', 'Angular Velocity', 1); % angular velocity
expt = buildGLM.registerTiming(expt, 'flyon', 'Firefly ON'); % events that happen 0 or more times per trial (sparse)
expt = buildGLM.registerTiming(expt, 'flyoff', 'Firefly OFF'); % events that happen 0 or more times per trial (sparse)
expt = buildGLM.registerSpikeTrain(expt, 'sptrain', 'Neuronal Spike Train'); % Spike train
expt = buildGLM.registerValue(expt, 'den', 'Floor density'); % information on the trial, but not associated with time

%% Convert the raw data into the experiment structure
expt.trial = trial;

%% Build 'designSpec' which specifies how to generate the design matrix
dspec = buildGLM.initDesignSpec(expt);
binfun = expt.binfun;

% add covariates
dspec = buildGLM.addCovariateRaw(dspec, 'eyepos', 'Effect of eye position');
dspec = buildGLM.addCovariateRaw(dspec, 'linvel', 'Effect of linear velocity');
dspec = buildGLM.addCovariateRaw(dspec, 'angvel', 'Effect of angular velocity');
dspec = buildGLM.addCovariateBoxcar(dspec, 'firefly', 'flyon', 'flyoff', 'Firefly Duration');
dspec = buildGLM.addCovariateSpiketrain(dspec, 'hist', 'sptrain', 'History filter');
% a box car that depends on the density value
bs = basisFactory.makeSmoothTemporalBasis('boxcar', binSize*20, 10, binfun);
stimHandle = @(trial, expt) trial.den * basisFactory.boxcarStim(binfun(trial.flyon), binfun(trial.flyoff), binfun(trial.duration));
dspec = buildGLM.addCovariate(dspec, 'denKer', 'density of ground plane', stimHandle,bs);

%% compile design matrix
trialIndices = 1:nTrials; % use all trials except the last one
dm = buildGLM.compileSparseDesignMatrix(dspec, trialIndices);

%% Get the spike trains back to regress against
y = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', dm.trialIndices);

%% Do some processing on the design matrix
dm = buildGLM.removeConstantCols(dm);
dm = buildGLM.addBiasColumn(dm); % comment if using glmfit

%% Least squares for initialization
tic
wInit = dm.X \ y;
toc


%% Use matRegress for Poisson regression
% it requires `fminunc` from MATLAB's optimization toolbox
addpath('matRegress')

fnlin = @nlfuns.exp; % inverse link function (a.k.a. nonlinearity)
lfunc = @(w)(glms.neglog.poisson(w, dm.X, y, fnlin)); % cost/loss function

opts = optimoptions(@fminunc, 'Algorithm', 'trust-region', ...
    'GradObj', 'on', 'Hessian','on');

[wml, nlogli, exitflag, ostruct, grad, hessian] = fminunc(lfunc, wInit, opts);
wvar = diag(inv(hessian));

%% Visualize
ws = buildGLM.combineWeights(dm, wml);
wvar = buildGLM.combineWeights(dm, wvar);

fig = figure(2913); clf;
nCovar = numel(dspec.covar);
for kCov = 1:nCovar
    label = dspec.covar(kCov).label;
    subplot(nCovar, 1, kCov);
    errorbar(ws.(label).tr, ws.(label).data, sqrt(wvar.(label).data));
    title(label);
end

%% Simulate from model for test data
testTrialIndices = nTrials; % test it on the last trial
dmTest = buildGLM.compileSparseDesignMatrix(dspec, testTrialIndices);

yPred = generatePrediction(w, model, dmTest);
ySamp = simulateModel(w, model, dmTest);