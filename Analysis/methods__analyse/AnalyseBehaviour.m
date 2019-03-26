function stats = AnalyseBehaviour(trials,prs)

fprintf('******Behavioural analysis****** \n');
mintrialsforstats = prs.mintrialsforstats;
maxrewardwin = prs.maxrewardwin;
npermutations = prs.npermutations;

%% preallocate for speed
ntrls = length(trials);
v_monk = zeros(1,ntrls); w_monk = zeros(1,ntrls); % velocity at t_end (v_monk, w_monk)
x_fly = zeros(1,ntrls); y_fly = zeros(1,ntrls); % target location (x_fly, y_fly)
x0_monk = zeros(1,ntrls); y0_monk = zeros(1,ntrls); % monkey - starting location (x0_monk, y0_monk)
xf_monk = zeros(1,ntrls); yf_monk = zeros(1,ntrls); % monkey - stopping location (xf_monk, yf_monk)

%% compute
continuous = cell2mat({trials.continuous}); % extract continuous channels
events = cell2mat({trials.events}); % extract event channels
logical = cell2mat({trials.logical}); % extract logical channels
trialparams = cell2mat({trials.prs});
for i=1:ntrls
    %% final velocity
    indx_end = find(continuous(i).ts > events(i).t_end, 1); % sample number of end-of-trial timestamp (t_end)
    v_monk(i) = (continuous(i).v(indx_end)); w_monk(i) = (continuous(i).w(indx_end));
    %% initial & final position - cartesian
    indx_beg = find(continuous(i).ts > events(i).t_targ, 1); % sample number of target onset time
    indx_stop = find(continuous(i).ts > events(i).t_stop, 1); % sample number of stopping time    
    x_fly(i) = nanmedian(continuous(i).xfp(indx_beg:indx_stop)); y_fly(i) = nanmedian(continuous(i).yfp(indx_beg:indx_stop));
    x0_monk(i) = continuous(i).xmp(indx_beg+1); y0_monk(i) = continuous(i).ymp(indx_beg+1);
    xf_monk(i) = continuous(i).xmp(indx_stop); yf_monk(i) = continuous(i).ymp(indx_stop);
    %% eye position relative to monkey - cartesian
    continuous(i).yrep = prs.height./tand(-continuous(i).zre); continuous(i).yrep(continuous(i).yrep<0) = nan;
    continuous(i).ylep = prs.height./tand(-continuous(i).zle); continuous(i).ylep(continuous(i).ylep<0) = nan;
    continuous(i).xrep = continuous(i).yrep.*tand(continuous(i).yre);
    continuous(i).xlep = continuous(i).ylep.*tand(continuous(i).yle);
    %% fly position relative to monkey - cartesian
    continuous(i).xfp_rel = x_fly(i) - continuous(i).xmp;
    continuous(i).yfp_rel = y_fly(i) - continuous(i).ymp;
    continuous(i).r_fly_rel = sqrt(continuous(i).xfp_rel.^2 + continuous(i).yfp_rel.^2);
    continuous(i).theta_fly_rel = atan2d(continuous(i).xfp_rel,continuous(i).yfp_rel);
    %% final stopping position relative to monkey
    continuous(i).xsp_rel = xf_monk(i) - continuous(i).xmp;
    continuous(i).ysp_rel = yf_monk(i) - continuous(i).ymp;
    continuous(i).r_stop_rel = sqrt(continuous(i).xsp_rel.^2 + continuous(i).ysp_rel.^2);
    continuous(i).theta_stop_rel = atan2d(continuous(i).xsp_rel,continuous(i).ysp_rel);
    %% believed target position - r and theta
    [r_belief,theta_belief] = eyepos2flypos(continuous(i).zle,continuous(i).zre,continuous(i).yle,continuous(i).yre,prs.height);
    continuous(i).r_belief = r_belief;
    continuous(i).theta_belief = theta_belief;
end

%% trial-by-trial error
trlerrors = cellfun(@min,{continuous.r_fly_rel});

%% position - polar
rf_monk = sqrt((xf_monk - x0_monk).^2 + (yf_monk - y0_monk).^2);
r_fly = sqrt((x_fly - x0_monk).^2 + (y_fly - y0_monk).^2);
thetaf_monk = atan2d((xf_monk - x0_monk),(yf_monk - y0_monk));
theta_fly = atan2d((x_fly - x0_monk),(y_fly - y0_monk));

%% save position stats
% time
stats.time = {continuous.ts};
% final position - monkey and fly
stats.pos_final.r_monk = rf_monk; stats.pos_final.theta_monk = thetaf_monk;
stats.pos_final.r_targ = r_fly; stats.pos_final.theta_targ = theta_fly;
% absolute position - monkey
stats.pos_abs.x_monk = {continuous.xmp};
stats.pos_abs.y_monk = {continuous.ymp};
% relative position - fly, eye, stop
stats.pos_rel.x_targ = {continuous.xfp_rel};
stats.pos_rel.y_targ = {continuous.yfp_rel};
stats.pos_rel.r_targ = {continuous.r_fly_rel};
stats.pos_rel.theta_targ = {continuous.theta_fly_rel};
stats.pos_rel.x_leye = {continuous.xlep};
stats.pos_rel.y_leye = {continuous.ylep};
stats.pos_rel.x_reye = {continuous.xrep};
stats.pos_rel.y_reye = {continuous.yrep};
stats.pos_rel.r_belief = {continuous.r_belief};
stats.pos_rel.theta_belief = {continuous.theta_belief};
stats.pos_rel.x_stop = {continuous.xsp_rel};
stats.pos_rel.y_stop = {continuous.ysp_rel};
stats.pos_rel.r_stop = {continuous.r_stop_rel};
stats.pos_rel.theta_stop = {continuous.theta_stop_rel};

%% trial type
goodtrls = ~((yf_monk<0) | (abs(v_monk)>1) | ([events.t_stop]>4)); % remove trials in which monkey did not move at all or kept moving until the end
replaytrls = [logical.replay];
% all trials
stats.trialtype.all.trlindx  = goodtrls & ~replaytrls;
stats.trialtype.all.val = 'all';

if prs.split_trials
    % unrewarded trials
    stats.trialtype.reward(1).trlindx = ~[logical.reward] & goodtrls & ~replaytrls;
    stats.trialtype.reward(1).val = 'unrewarded';
    % rewarded trials
    stats.trialtype.reward(2).trlindx = [logical.reward] & goodtrls & ~replaytrls;
    stats.trialtype.reward(2).val = 'rewarded';
    
    % different densities
    density = [trialparams.floordensity];
    densities = unique(density);
    for i=1:length(densities)
        stats.trialtype.density(i).val = ['density = ' num2str(densities(i))];
        stats.trialtype.density(i).trlindx = (density==densities(i) & goodtrls & ~replaytrls);
    end
    
    stats.trialtype.ptb = [];
    % trials without perturbation
    trlindx = ~[logical.ptb] & goodtrls & ~replaytrls;
    if sum(trlindx)>1
        stats.trialtype.ptb(end+1).trlindx = trlindx;
        stats.trialtype.ptb(end).val = 'without perturbation';
    end
    % trials with perturbation
    trlindx = [logical.ptb] & goodtrls & ~replaytrls;
    if sum(trlindx)>1
        stats.trialtype.ptb(end+1).trlindx = trlindx;
        stats.trialtype.ptb(end).val = 'with perturbation';
    end
    
    stats.trialtype.landmark = [];
    % trials without any landmark
    trlindx = (~([logical.landmark_angle] | [logical.landmark_distance] | [logical.landmark_fixedground])) & goodtrls & ~replaytrls;
    if sum(trlindx)>1
        stats.trialtype.landmark(end+1).trlindx = trlindx;
        stats.trialtype.landmark(end).val = 'without landmark';
    end
    % trials with distance landmark only
    trlindx = ([logical.landmark_distance] & ~[logical.landmark_angle] & ~[logical.landmark_fixedground]) & goodtrls & ~replaytrls;
    if sum(trlindx)>1
        stats.trialtype.landmark(end+1).trlindx = trlindx;
        stats.trialtype.landmark(end).val = 'with distance landmark';
    end
    % trials with angular landmark only
    trlindx = ([logical.landmark_angle] & ~[logical.landmark_distance] & ~[logical.landmark_fixedground]) & goodtrls & ~replaytrls;
    if sum(trlindx)>1
        stats.trialtype.landmark(end+1).trlindx = trlindx;
        stats.trialtype.landmark(end).val = 'with angular landmark';
    end
    % trials with distance & angular landmark
    trlindx = ([logical.landmark_angle] & [logical.landmark_distance]) & goodtrls & ~replaytrls;
    if sum(trlindx)>1
        stats.trialtype.landmark(end+1).trlindx = trlindx;
        stats.trialtype.landmark(end).val = 'with distance & angular landmark';
    end
    % trials with fixed ground plane only
    trlindx = ([logical.landmark_fixedground] & ~[logical.landmark_distance] & ~[logical.landmark_angle]) & goodtrls & ~replaytrls;
    if sum(trlindx)>1
        stats.trialtype.landmark(end+1).trlindx = trlindx;
        stats.trialtype.landmark(end).val = 'with ground plane as landmark';
    end
    
    stats.trialtype.replay = [];
    % trials without replay
    trlindx  = goodtrls & ~replaytrls;
    if sum(trlindx)>1
        stats.trialtype.replay(end+1).trlindx = trlindx;
        stats.trialtype.replay(end).val = 'active behaviour';
    end
    % trials recorded during replay
    trlindx  = goodtrls & replaytrls;
    if sum(trlindx)>1
        stats.trialtype.replay(end+1).trlindx = trlindx;
        stats.trialtype.replay(end).val = 'replay behaviour';
    end
end

%% analyse eye movements
if prs.regress_eye
    xfp_rel = {continuous.xfp_rel};
    yfp_rel = {continuous.yfp_rel};
    zle = {continuous.zle}; yle = {continuous.yle};
    zre = {continuous.zre}; yre = {continuous.yre};
    t_sac = {events.t_sac}; t_stop = [events.t_stop]; ts = {continuous.ts};
    trialtypes = fields(stats.trialtype);
    for i=1:length(trialtypes)
        nconds = length(stats.trialtype.(trialtypes{i}));
        for j=1:nconds
            trlindx = stats.trialtype.(trialtypes{i})(j).trlindx;
            stats.trialtype.(trialtypes{i})(j).eye_fixation = ...
                AnalyseEyefixation(xfp_rel(trlindx),yfp_rel(trlindx),zle(trlindx),yle(trlindx),zre(trlindx),yre(trlindx),t_sac(trlindx),ts(trlindx),prs);
            stats.trialtype.(trialtypes{i})(j).eye_movement = ...
                AnalyseEyemovement(xfp_rel(trlindx),yfp_rel(trlindx),zle(trlindx),yle(trlindx),zre(trlindx),yre(trlindx),t_sac(trlindx),t_stop(trlindx),ts(trlindx),trlerrors(trlindx),prs);
        end
    end
end

%% linear regression and ROC analysis
if prs.regress_behv
    trialtypes = fields(stats.trialtype);
    for i=1:length(trialtypes)
        nconds = length(stats.trialtype.(trialtypes{i}));
        if ~strcmp((trialtypes{i}),'all') && nconds==1, copystats = true; else, copystats = false; end % only one condition means variable was not manipulated
        for j=1:nconds
            if copystats % if only one condition present, no need to recompute stats --- simply copy them from 'all' trials
                stats.trialtype.(trialtypes{i})(j).pos_regress = stats.trialtype.all.pos_regress;
                stats.trialtype.(trialtypes{i})(j).pos_regress_intercept = stats.trialtype.all.pos_regress_intercept;
                stats.trialtype.(trialtypes{i})(j).accuracy = stats.trialtype.all.accuracy;
            else
                trlindx = stats.trialtype.(trialtypes{i})(j).trlindx;
                if sum(trlindx) > mintrialsforstats
                    fprintf(['.........regression & ROC analysis :: trialtype: ' stats.trialtype.(trialtypes{i})(j).val '\n']);
                    % regression without intercept
                    [pos_regress.beta_r, ~, pos_regress.betaCI_r, ~, pos_regress.corr_r] = regress_perp(r_fly(trlindx)', rf_monk(trlindx)', 0.05, 2);
                    [pos_regress.beta_theta, ~, pos_regress.betaCI_theta, ~, pos_regress.corr_theta] = regress_perp(theta_fly(trlindx)', thetaf_monk(trlindx)', 0.05, 2);
                    stats.trialtype.(trialtypes{i})(j).pos_regress = pos_regress;
                    % regression with intercept
                    [pos_regress2.beta_r, pos_regress2.alpha_r, pos_regress2.betaCI_r, pos_regress2.alphaCI_r, pos_regress2.corr_r] = regress_perp(r_fly(trlindx)', rf_monk(trlindx)', 0.05, 1);
                    [pos_regress2.beta_theta, pos_regress2.alpha_theta, pos_regress2.betaCI_theta, pos_regress2.alphaCI_theta, pos_regress2.corr_theta] = regress_perp(theta_fly(trlindx)', thetaf_monk(trlindx)', 0.05, 1);
                    stats.trialtype.(trialtypes{i})(j).pos_regress_intercept = pos_regress2;
                    % ROC
                    [accuracy.rewardwin ,accuracy.pCorrect, accuracy.pcorrect_shuffled_mu] = ComputeROCFirefly([r_fly(trlindx)' (pi/180)*theta_fly(trlindx)'],...
                        [rf_monk(trlindx)' (pi/180)*thetaf_monk(trlindx)'],maxrewardwin,npermutations);
                    stats.trialtype.(trialtypes{i})(j).accuracy = accuracy;
                else
                    stats.trialtype.(trialtypes{i})(j).pos_regress = nan;
                    stats.trialtype.(trialtypes{i})(j).pos_regress_intercept = nan;
                    stats.trialtype.(trialtypes{i})(j).accuracy = nan;
                end
            end
        end
    end
end