function weights = ComputeWeights(trials_spks,trials_behv,stats_behv,prs)

%% parameters
binSize = double(median(diff(trials_behv(1).ts))); % binwidth
fly_ONduration = prs.fly_ONduration;
velkrnlwidth = prs.velkrnlwidth;
distkrnlwidth = prs.distkrnlwidth;
eyekrnlwidth = prs.eyekrnlwidth;
targetkrnlwidth = prs.targetkrnlwidth;
use_dist2fly = prs.use_dist2fly;
use_dist2stop = prs.use_dist2stop;

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
    starttime = trials_behv(i).ts(1);
    endtime = trials_behv(i).ts(end);
%     trial(i).duration = double(endtime - starttime); % fix neuroGLM code instead of commenting this out?
    trial(i).duration = numel(trials_behv(i).v)*binSize;
    trial(i).eyepos = double([trials_behv(i).yle trials_behv(i).zle]);
    trial(i).linvel = double(trials_behv(i).v);
    trial(i).angvel = double(trials_behv(i).w);
    trial(i).dist2fly = dist2fly{i}; 
    trial(i).dist2fly(isnan(trial(i).dist2fly)) = trial(i).dist2fly(find(~isnan(trial(i).dist2fly),1)); % replace nans
    trial(i).dist2stop = dist2stop{i}; 
    trial(i).dist2stop(isnan(trial(i).dist2stop)) = trial(i).dist2stop(find(~isnan(trial(i).dist2stop),1)); % replace nans
    trial(i).flyon = -trials_behv(i).ts(1) + 0.2; % target appears roughly 0.2s after t_beg (change to actual onset time)
    if trials_behv(i).firefly_fullON==1
        trial(i).flyoff = trial(i).duration;
    else
        trial(i).flyoff = trial(i).flyon + fly_ONduration;
    end
    trial(i).den = double(trials_behv(i).floordensity);
    % specify spike times relative to starttime
    trial(i).sptrain = trials_spks(i).tspk(trials_spks(i).tspk>starttime & trials_spks(i).tspk<endtime) - starttime;
end

%% register variables
expt = buildGLM.initExperiment('s', binSize, 'firefly-monkey', prs);
expt = buildGLM.registerContinuous(expt, 'eyepos', 'Eye Position', 2); % 2 dimensional observation
expt = buildGLM.registerContinuous(expt, 'linvel', 'Linear Velocity', 1); % linear velocity
expt = buildGLM.registerContinuous(expt, 'angvel', 'Angular Velocity', 1); % angular velocity
expt = buildGLM.registerContinuous(expt, 'dist2fly', 'Distance to target', 1); % Distance to target
expt = buildGLM.registerContinuous(expt, 'dist2stop', 'Distance to stop', 1); % Distance to stop (= distance to reward for correct trials)
expt = buildGLM.registerTiming(expt, 'flyon', 'Firefly ON'); % events that happen 0 or more times per trial (sparse)
expt = buildGLM.registerTiming(expt, 'flyoff', 'Firefly OFF'); % events that happen 0 or more times per trial (sparse)
expt = buildGLM.registerSpikeTrain(expt, 'sptrain', 'Neuronal Spike Train'); % Spike train

%% Convert the raw data into the experiment structure
expt.trial = trial;

%% Build 'designSpec' which specifies how to generate the design matrix
dspec = buildGLM.initDesignSpec(expt);
binfun = expt.binfun;

%% add covariates

% eye position
bs = basisFactory.makeSmoothTemporalBasis('raised cosine', eyekrnlwidth, 10, binfun);
dspec = buildGLM.addCovariateRaw(dspec, 'eyepos', 'Effect of eye position',bs);

% velocity
bs = basisFactory.makeSmoothTemporalBasis('raised cosine', velkrnlwidth, 10, binfun);
dspec = buildGLM.addCovariateRaw(dspec, 'linvel', 'Effect of linear velocity',bs);
dspec = buildGLM.addCovariateRaw(dspec, 'angvel', 'Effect of angular velocity',bs);

% distance to target
if use_dist2fly
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', distkrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateRaw(dspec, 'dist2fly', 'Effect of distance-to-target',bs);
end

% distance to stop
if use_dist2stop
    bs = basisFactory.makeSmoothTemporalBasis('raised cosine', distkrnlwidth, 10, binfun);
    dspec = buildGLM.addCovariateRaw(dspec, 'dist2stop', 'Effect of distance-to-stop',bs);
end

% target-on-screen
bs = basisFactory.makeSmoothTemporalBasis('raised cosine', targetkrnlwidth, 10, binfun);
dspec = buildGLM.addCovariateBoxcar(dspec, 'firefly', 'flyon', 'flyoff', 'Firefly Duration',bs);

% post-spike
dspec = buildGLM.addCovariateSpiketrain(dspec, 'hist', 'sptrain', 'History filter');

% ground plane density
% stimHandle = @(trial, expt) trial.den * basisFactory.boxcarStim(binfun(trial.flyon), binfun(trial.duration), binfun(trial.duration));
% dspec = buildGLM.addCovariate(dspec, 'denKer', 'density of ground plane', stimHandle,bs);

%% compile design matrix
trialIndices = 1:nTrials; % use all trials
dm = buildGLM.compileSparseDesignMatrix(dspec, trialIndices);

%% Get the spike trains back to regress against
y = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', dm.trialIndices);

%% Do some processing on the design matrix
dm = buildGLM.removeConstantCols(dm);
dm = buildGLM.addBiasColumn(dm); % comment if using glmfit

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

% fig = figure(2913); clf;
% nCovar = numel(dspec.covar);
% for kCov = 1:nCovar
%     label = dspec.covar(kCov).label;
%     subplot(nCovar, 1, kCov);
%     plot(weights.mu.(label).tr, weights.mu.(label).data);
% %     errorbar(weights.mu.(label).tr, weights.mu.(label).data, sqrt(weights.var.(label).data));
%     title(label);
% end

%% predict
% for i = 1:nTrials
%     r_eyev = conv(trial(i).eyepos(:,1),weights.mu.eyepos.data(:,1),'same');
%     r_eyeh = conv(trial(i).eyepos(:,2),weights.mu.eyepos.data(:,2),'same');
%     r_linvel = conv(trial(i).linvel,weights.mu.linvel.data,'same');
%     r_angvel = conv(trial(i).linvel,weights.mu.angvel.data,'same');
%     if length(r_fly) < length(r_linvel)
%         r_fly = [conv(ones(round(0.3/binSize),1),weights.mu.firefly.data) ; ones(1,length(r_linvel) - length(conv(ones(round(0.3/binSize),1),weights.mu.firefly.data)))'];
%     else
%         r_fly = r_fly(1:length(r_linvel));
%     end
%     r_fly = -0.2*r_fly;
%     r_time = weights.mu.time.data(1:min(length(weights.mu.time.data),length(trial(i).linvel)));
%     if length(r_time)<length(r_linvel), r_time = [r_time ; zeros(length(r_linvel) - length(r_time),1)]; end
%     trial(i).r_predicted = r_eyev + r_eyeh + r_linvel + r_angvel + r_fly;
% end
% 
% % plot
% ntrls_all = length(trial);
% ns = zeros(1,ntrls_all);
% for i=1:ntrls_all
%     ns(i) = length(trial(i).r_predicted);
% end
% ns_max = max(ns);
% % convolve
% for i = 1:ntrls_all
%     sig = prs.spkkrnlwidth; %filter width
%     sz = prs.spkkrnlsize; %filter size
%     t2 = linspace(-sz/2, sz/2, sz);
%     h = exp(-t2.^2/(2*sig^2));
%     h = h/sum(h);
%     r_predicted_smooth = conv(trial(i).r_predicted,h,'same');
%     trial(i).r_predicted_smooth = r_predicted_smooth; % smoothed spike train
% end
% % store responses in a matrix (Trial x Time)
% nspk = nan(ntrls_all,ns_max);
% angvel = nan(ntrls_all,ns_max);
% for i=1:ntrls_all
%     nspk(i,1:ns(i)) = trial(i).r_predicted_smooth;
%     angvel(i,1:ns(i)) = trial(i).angvel;
% end
% nspk = exp(nspk(indx,:));
% % smooth across trials
% trlkrnl = ones(50,1)/50;
% nspk = conv2nan(nspk, trlkrnl);
% % sort order
% [~,indx] = sort(ns);
% figure; imagesc(nspk);
% cmap=cbrewer('seq','Greys',256); colormap(cmap);
% set(gca,'Ydir','normal');

%% Simulate from model for test data
% testTrialIndices = nTrials; % test it on the last trial
% dmTest = buildGLM.compileSparseDesignMatrix(dspec, testTrialIndices);
% 
% yPred = generatePrediction(w, model, dmTest);
% ySamp = simulateModel(w, model, dmTest);