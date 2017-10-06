function weights = FitGLM(trials_spks,trials_behv,stats_behv,prs)

%% parameters
binSize = double(median(diff(trials_behv(1).ts))); % binwidth
fly_ONduration = prs.fly_ONduration;
velkrnlwidth = prs.velkrnlwidth;
distkrnlwidth = prs.distkrnlwidth;
eyekrnlwidth = prs.eyekrnlwidth;
sackrnlwidth = prs.sackrnlwidth;
saccadeduration = prs.saccadeduration;
targetkrnlwidth = prs.targetkrnlwidth;
vars = prs.vars;

% select correct trials
correct = stats_behv.trlindx.correct; % use only correct trials for fitting
nTrials = sum(correct); % total number of trials
trials_spks = trials_spks(correct);
trials_behv = trials_behv(correct);
dist2fly = stats_behv.pos_rel.r_fly(correct);
dist2stop = stats_behv.pos_rel.r_stop(correct);

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
    trial(i).horeye = double(trials_behv(i).yle);
    trial(i).vereye = double(trials_behv(i).zle);
    trial(i).linvel = double(trials_behv(i).v);
    trial(i).angvel = double(trials_behv(i).w);
    trial(i).linacc = [0; diff(trial(i).linvel)];
    trial(i).angacc = [0; diff(trial(i).angvel)];
    trial(i).dist2fly = dist2fly{i}; 
    trial(i).dist2fly(isnan(trial(i).dist2fly)) = trial(i).dist2fly(find(~isnan(trial(i).dist2fly),1)); % replace nans
    trial(i).dist2stop = dist2stop{i}; 
    trial(i).dist2stop(isnan(trial(i).dist2stop)) = trial(i).dist2stop(find(~isnan(trial(i).dist2stop),1)); % replace nans
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
if any(strcmp(vars,'saccade')), expt = buildGLM.registerContinuous(expt, 'saccade', 'Saccade onset', 1); end % saccade onset 
if any(strcmp(vars,'horeye')), expt = buildGLM.registerContinuous(expt, 'horeye', 'Horizontal Eye Position', 1); end
if any(strcmp(vars,'vereye')), expt = buildGLM.registerContinuous(expt, 'vereye', 'Vertical Eye Position', 1); end
if any(strcmp(vars,'linvel')), expt = buildGLM.registerContinuous(expt, 'linvel', 'Linear Velocity', 1); end % linear velocity
if any(strcmp(vars,'angvel')), expt = buildGLM.registerContinuous(expt, 'angvel', 'Angular Velocity', 1); end % angular velocity
if any(strcmp(vars,'linacc')), expt = buildGLM.registerContinuous(expt, 'linacc', 'Linear Accelaration', 1); end % linear accelaration
if any(strcmp(vars,'angacc')), expt = buildGLM.registerContinuous(expt, 'angacc', 'Angular Accelaration', 1); end % angular accelaration
if any(strcmp(vars,'dist2fly')), expt = buildGLM.registerContinuous(expt, 'dist2fly', 'Distance to target', 1); end % Distance to target
if any(strcmp(vars,'dist2stop')), expt = buildGLM.registerContinuous(expt, 'dist2stop', 'Distance to stop', 1); end % Distance to stop (= distance to reward for correct trials)
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

% eye position
if any(strcmp(vars,'horeye'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', eyekrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateRaw(dspec, 'horeye', 'Effect of horizontal eye position',bs);
end
if any(strcmp(vars,'vereye'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', eyekrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateRaw(dspec, 'vereye', 'Effect of vertical eye position',bs);
end

% velocity
if any(strcmp(vars,'linvel'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', velkrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateRaw(dspec, 'linvel', 'Effect of linear velocity',bs);
end
if any(strcmp(vars,'angvel'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', velkrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateRaw(dspec, 'angvel', 'Effect of angular velocity',bs);
end

% accelaration
% velocity
if any(strcmp(vars,'linacc'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', velkrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateRaw(dspec, 'linacc', 'Effect of linear accelaration',bs);
end
if any(strcmp(vars,'angacc'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', velkrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateRaw(dspec, 'angacc', 'Effect of angular accelaration',bs);
end

% distance to target
if any(strcmp(vars,'dist2fly'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', distkrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateRaw(dspec, 'dist2fly', 'Effect of distance-to-target',bs);
end

% distance to stop
if any(strcmp(vars,'dist2stop'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', distkrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateRaw(dspec, 'dist2stop', 'Effect of distance-to-stop',bs);
end

% target-on-screen
if any(strcmp(vars,'firefly'))
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', targetkrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateBoxcar(dspec, 'firefly', 'flyon', 'flyoff', 'Firefly Duration',bs);
end

% post-spike
if any(strcmp(vars,'spikehist'))
    dspec = buildGLM.addCovariateSpiketrain(dspec, 'spikehist', 'sptrain', 'History filter');
end

% ground plane density
if any(strcmp(vars,'floorden'))
    stimHandle = @(trial, expt) trial.den * basisFactory.boxcarStim(binfun(trial.flyon), binfun(trial.duration), binfun(trial.duration));
    dspec = buildGLM.addCovariate(dspec, 'denKer', 'density of ground plane', stimHandle,bs);
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