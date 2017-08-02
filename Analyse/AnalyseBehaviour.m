function stats = AnalyseBehaviour(trials,prs)

for i=1:length(trials)
    %% final velocity
    v_monk(i) = (trials(i).v(end));
    w_monk(i) = (trials(i).w(end));
    %% initial & final position - cartesian
    x0_monk(i) = trials(i).xmp(1); y0_monk(i) = trials(i).ymp(1);
    x_monk(i) = trials(i).xmp(end); y_monk(i) = trials(i).ymp(end);
    x_fly(i) = median(trials(i).xfp(:)); y_fly(i) = median(trials(i).yfp(:));
    %% eye position relative to monkey - cartesian
    trials(i).yrep = prs.height./tand(-trials(i).zre); trials(i).yrep(trials(i).yrep<0) = nan;
    trials(i).ylep = prs.height./tand(-trials(i).zle); trials(i).ylep(trials(i).ylep<0) = nan;
    trials(i).xrep = trials(i).yrep.*tand(trials(i).yre);
    trials(i).xlep = trials(i).ylep.*tand(trials(i).yle);
    %% eye position on screen - cartesian
    trials(i).zrep_scr = prs.screendist*tand(trials(i).zre);
    trials(i).zlep_scr = prs.screendist*tand(trials(i).zle);
    trials(i).yrep_scr = prs.screendist*tand(trials(i).yre);
    trials(i).ylep_scr = prs.screendist*tand(trials(i).yle);
    %% trial type
    crazy(i)  = (y_monk(i)<0) | (abs(v_monk(i))>1); % monkey did not move at all or kept moving until the end
    correct(i) = trials(i).reward & ~crazy(i);
    incorrect(i) = ~trials(i).reward & ~crazy(i);
    %% fly position relative to monkey - cartesian
    trials(i).xfp_rel = x_fly(i) - trials(i).xmp;
    trials(i).yfp_rel = y_fly(i) - trials(i).ymp;
    trials(i).r_fly_rel = sqrt(trials(i).xfp_rel.^2 + trials(i).yfp_rel.^2);
    trials(i).theta_fly_rel = atan2d(trials(i).xfp_rel,trials(i).yfp_rel);
    %% stimulus parameters
%     floordensity(i) = trials(i).floordensity;
end

%% position - polar
rf_monk = sqrt((x_monk - x0_monk).^2 + (y_monk - y0_monk).^2);
r_fly = sqrt((x_fly - x0_monk).^2 + (y_fly - y0_monk).^2);
thetaf_monk = atan2d((x_monk - x0_monk),(y_monk - y0_monk));
theta_fly = atan2d((x_fly - x0_monk),(y_fly - y0_monk));

%% save
% trial index
stats.trlindx.correct = correct; 
stats.trlindx.incorrect = incorrect; 
stats.trlindx.crazy = crazy;

% % stimulus parameters
% behaviour.prs.floordensity = floordensity;

% final position - monkey and fly
stats.pos_final.r_monk = rf_monk; stats.pos_final.theta_monk = thetaf_monk;
stats.pos_final.r_fly = r_fly; stats.pos_final.theta_fly = theta_fly;

% absolute position - monkey
stats.pos_abs.x_monk = {trials.xmp};
stats.pos_abs.y_monk = {trials.ymp};

% absolute position - eye
stats.pos_abs.z_leye =  {trials.zlep_scr};
stats.pos_abs.y_leye =  {trials.ylep_scr};
stats.pos_abs.z_reye =  {trials.zrep_scr};
stats.pos_abs.y_reye =  {trials.yrep_scr};

% relative position - fly, eye
stats.pos_rel.x_fly = {trials.xfp_rel};
stats.pos_rel.y_fly = {trials.yfp_rel};
stats.pos_rel.r_fly = {trials.r_fly_rel};
stats.pos_rel.theta_fly = {trials.theta_fly_rel};

stats.pos_rel.x_leye = {trials.xlep};
stats.pos_rel.y_leye = {trials.ylep};
stats.pos_rel.x_reye = {trials.xrep};
stats.pos_rel.y_reye = {trials.yrep};