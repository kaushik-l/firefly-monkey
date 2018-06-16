function weights = FitGLM(trials_spks,trials_behv,stats_behv,prs)

%% parameters
vars = prs.vars;

% select correct trials
correct = stats_behv.trlindx.correct; % use only correct trials for fitting
nTrials = sum(correct); % total number of trials
trials_spks = trials_spks(correct);
trials_behv = trials_behv(correct);

% preallocate structure in memory
trial = struct();
trial(nTrials).duration = 0; % preallocate

for i = 1:nTrials
    ts = trials_behv(i).ts;
    starttime = ts(1);
    endtime = ts(end);
%     trial(i).duration = double(endtime - starttime); % fix neuroGLM code instead of commenting this out?
    trial(i).ts = ts;
    trial(i).duration = numel(trials_behv(i).v)*binSize;
    trial(i).flyon = -starttime + 0.2; % target appears roughly 0.2s after t_beg (change to actual onset time)
    if trials_behv(i).firefly_fullON==1
        trial(i).flyoff = trial(i).duration;
    else
        trial(i).flyoff = trial(i).flyon + fly_ONduration;
    end
    trial(i).firefly = double(trials_behv(i).firefly);
    trial(i).saccade = zeros(length(ts),1);
    t_sac = trials_behv(i).t_sac;
    for j=1:length(t_sac)
        trial(i).saccade(ts>t_sac(j) & ts<t_sac(j)+saccadeduration) = 1;
    end
    trial(i).den = double(trials_behv(i).floordensity);
    % specify spike times relative to starttime
    trial(i).sptrain = trials_spks(i).tspk(trials_spks(i).tspk>starttime & trials_spks(i).tspk<endtime) - starttime;
%     trial(i).sptrain = SimulateSpikes(trial(i),prs,vars) - starttime;
end

%% register variables
expt = buildGLM.initExperiment('s', binSize, 'firefly-monkey', prs);
if any(strcmp(vars,'firefly'))
    expt = buildGLM.registerTiming(expt, 'flyon', 'Firefly ON'); % events that happen 0 or more times per trial (sparse)
    expt = buildGLM.registerTiming(expt, 'flyoff', 'Firefly OFF'); % events that happen 0 or more times per trial (sparse)
end
expt = buildGLM.registerSpikeTrain(expt, 'sptrain', 'Neuronal Spike Train'); % Spike train

%% Convert the raw data into the experiment structure
expt.trial = trial;

%% Build 'designSpec' which specifies how to generate the design matrix
dspec = buildGLM.initDesignSpec(expt);
binfun = expt.binfun;

%% add covariates

% saccade
if any(strcmp(vars,'saccade'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', sackrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateRaw(dspec, 'saccade', 'Saccade',bs);
end

% target-on-screen
if any(strcmp(vars,'firefly'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', targetkrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateBoxcar(dspec, 'firefly', 'flyon', 'flyoff', 'Firefly Duration',bs);
end

%% compile design matrix
trialIndices = 1:nTrials; % use all trials
dm = buildGLM.compileSparseDesignMatrix(dspec, trialIndices);

%% Get the spike trains back to regress against
y = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', dm.trialIndices);

%% Do some processing on the design matrix
dm = buildGLM.removeConstantCols(dm);
dm = buildGLM.addBiasColumn(dm); % comment if using glmfit % KL - toy model only works with bias column enabled

%% Least squares for initialization
wInit = dm.X \ y;

%% Use matRegress for Poisson regression
% it requires `fminunc` from MATLAB's optimization toolbox
% addpath('matRegress')

fnlin = @nlfuns.exp; % inverse link function (a.k.a. nonlinearity)
lfunc = @(w)(glms.neglog.poisson(w, dm.X, y, fnlin)); % cost/loss function

opts = optimoptions(@fminunc, 'Algorithm', 'trust-region', ...
    'GradObj', 'on', 'Hessian','on');

[wml, nlogli, exitflag, ostruct, grad, hessian] = fminunc(lfunc, wInit, opts);
wvar = diag(inv(hessian));

%% Visualize
weights.mu = buildGLM.combineWeights(dm, wml);
weights.var = buildGLM.combineWeights(dm, wvar);

%% Simulate from model for test data
% testTrialIndices = nTrials; % test it on the last trial
% dmTest = buildGLM.compileSparseDesignMatrix(dspec, testTrialIndices);
% 
% yPred = generatePrediction(w, model, dmTest);
% ySamp = simulateModel(w, model, dmTest);