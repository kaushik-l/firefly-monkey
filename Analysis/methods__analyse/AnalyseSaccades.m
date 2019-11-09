function eye_saccade = AnalyseSaccades(x_fly,y_fly,zle,yle,zre,yre,t_sac,t_stop,ts,trlerrors,prs)

%% prs
delta = prs.interoculardist/2;
zt = -prs.height;
saccade_duration = prs.saccade_duration;
fly_ONduration = prs.fly_ONduration;
Nboots = prs.bootstrap_trl;
factor_downsample = 1; %prs.factor_downsample; % downsampling factor for storage
ntrls = length(x_fly);
pretrial = prs.pretrial;
posttrial = prs.posttrial;
presaccade = prs.presaccade;
postsaccade = prs.postsaccade;

%% sort trials by error
[~,errorindx] = sort(trlerrors);

%% eye position immediately after the first saccade following target onset
for i=1:ntrls
    % identify time of target fixation
    sacstart = []; sacend = []; sacampli = [];
    t_sac2 = t_sac{i};
    sac_indx = t_sac{i}>0 & t_sac{i}<2*fly_ONduration;
    if any(sac_indx)
        t_sacs = t_sac{i}(sac_indx);
        for j=1:length(t_sacs)
            sacstart(j) = find(ts{i}>(t_sacs(j)), 1);
            sacend(j) = find(ts{i}>(t_sacs(j) + saccade_duration), 1);
            sacampli(j) = nanmean([sum(abs(zle{i}(sacstart(j)) - zle{i}(sacend(j)))^2 + abs(yle{i}(sacstart(j)) - yle{i}(sacend(j)))^2) ...
                sum(abs(zre{i}(sacstart(j)) - zre{i}(sacend(j)))^2 + abs(yre{i}(sacstart(j)) - yre{i}(sacend(j)))^2)]);
        end
        t_fix(i) = t_sacs(sacampli == max(sacampli)) + saccade_duration/2;
    else, t_fix(i) = 0 + saccade_duration/2; 
    end % if no saccade detected, assume monkey was already fixating on target
    
    pretrial = 0; posttrial = 0;
    % select data between target fixation and end of movement
    timeindx = find(ts{i}>(t_fix(i)-pretrial) & ts{i}<(t_stop(i)+posttrial));
    
    % target position
    xt{i} = x_fly{i}; yt{i} = y_fly{i};
    indx = find(~isnan(xt{i}),1);
    if ~isempty(indx), xt{i}(isnan(xt{i})) = xt{i}(indx); yt{i}(isnan(yt{i})) = yt{i}(indx); end

    % eye position
    yle{i} = yle{i}; yre{i} = yre{i};
    zle{i} = zle{i}; zre{i} = zre{i};    

    % ground truth prediction for eye position (if the monkey really followed the target)
    yle_pred{i} = atan2d(xt{i} + delta, sqrt(yt{i}.^2 + zt^2));
    yre_pred{i} = atan2d(xt{i} - delta, sqrt(yt{i}.^2 + zt^2));
    zle_pred{i} = atan2d(zt , sqrt(yt{i}.^2 + (xt{i} + delta).^2));
    zre_pred{i} = atan2d(zt , sqrt(yt{i}.^2 + (xt{i} - delta).^2));
    ver_mean_pred{i} = nanmean([zle_pred{i} , zre_pred{i}],2); % mean vertical eye position (of the two eyes)
    hor_mean_pred{i} = nanmean([yle_pred{i} , yre_pred{i}],2); % mean horizontal eye position
    ver_diff_pred{i} = 0.5*(zle_pred{i} - zre_pred{i}); % 0.5*difference between vertical eye positions (of the two eyes)
    hor_diff_pred{i} = 0.5*(yle_pred{i} - yre_pred{i}); % 0.5*difference between horizontal eye positions
    
    % actual eye position
    ver_mean{i} = nanmean([zle{i} , zre{i}],2); % mean vertical eye position (of the two eyes)
    hor_mean{i} = nanmean([yle{i} , yre{i}],2); % mean horizontal eye position
    ver_diff{i} = 0.5*(zle{i} - zre{i}); % 0.5*difference between vertical eye positions (of the two eyes)
    hor_diff{i} = 0.5*(yle{i} - yre{i}); % 0.5*difference between horizontal eye positions
    
    % fly position
    rt{i} = sqrt(xt{i}.^2 + yt{i}.^2);
    thetat{i} = atan2d(xt{i},yt{i});
    
    % saccade direction
    corrective.sacxy{i} = []; corrective.sacxy_pred{i} = []; corrective.sacdir{i} = []; corrective.sacdir_pred{i} = []; corrective.sac_time{i} = []; 
    acquisitive.sacxy{i} = []; acquisitive.sacdir{i} = []; acquisitive.sac_time{i} = []; 
    explorative.sacxy{i} = []; explorative.sacdir{i} = []; explorative.sac_time{i} = []; 
    if ~isempty(timeindx)
        for j=1:length(t_sac2)
            sacstartindx = max(find(ts{i}>(t_sac2(j) - saccade_duration/2), 1) - 2 , 1);
            sacendindx = min(find(ts{i}>(t_sac2(j) + saccade_duration/2), 1) + 2 , numel(ts{i}));
            if sacstartindx>timeindx(1) && sacendindx<=(timeindx(end)-50) % only consider saccades 300ms (= 50 samples) before stopping
                corrective.sacxy{i} = [corrective.sacxy{i} [ver_mean{i}(sacendindx) - ver_mean{i}(sacstartindx); hor_mean{i}(sacendindx) - hor_mean{i}(sacstartindx)]];
                corrective.sacdir{i} = [corrective.sacdir{i} atan2d(corrective.sacxy{i}(1,end),corrective.sacxy{i}(2,end))];
                corrective.sacxy_pred{i} = [corrective.sacxy_pred{i} [ver_mean_pred{i}(sacstartindx) - ver_mean{i}(sacstartindx); hor_mean_pred{i}(sacstartindx) - hor_mean{i}(sacstartindx)]];
                corrective.sacdir_pred{i} = [corrective.sacdir_pred{i} atan2d(corrective.sacxy_pred{i}(1,end),corrective.sacxy_pred{i}(2,end))];
                corrective.sac_time{i} = [corrective.sac_time{i} t_sac2(j)]; % time since target fixation
            elseif t_sac2(j) == (t_fix(i) - saccade_duration/2)
                acquisitive.sacxy{i} = [ver_mean{i}(sacendindx) - ver_mean{i}(sacstartindx); hor_mean{i}(sacendindx) - hor_mean{i}(sacstartindx)];
                acquisitive.sacdir{i} = atan2d(acquisitive.sacxy{i}(1,end),acquisitive.sacxy{i}(2,end));
                acquisitive.sac_time{i} = t_sac2(j); % time since target onset
            else
                explorative.sacxy{i} = [explorative.sacxy{i} [ver_mean{i}(sacendindx) - ver_mean{i}(sacstartindx); hor_mean{i}(sacendindx) - hor_mean{i}(sacstartindx)]];
                explorative.sacdir{i} = [explorative.sacdir{i} atan2d(explorative.sacxy{i}(1,end),explorative.sacxy{i}(2,end))];
                explorative.sac_time{i} = [explorative.sac_time{i} t_sac2(j)]; % time since target fixation
            end
        end
    end
    
    trackingerror.hor{i} = []; trackingerror.ver{i} = []; trackingerror.mag{i} = []; trackingerror.dir{i} = []; trackingerror.bearing{i} = [];
    trackingerror.ver_pred{i} = []; trackingerror.hor_pred{i} = [];
    Nt = floor((presaccade + postsaccade)/prs.dt);
    if ~isempty(timeindx)
        for j=1:length(t_sac2)
            if any(t_sac2(j) == corrective.sac_time{i})
                timewinaroundsaccade = find((ts{i} > (t_sac2(j) - presaccade)) & (ts{i} < (t_sac2(j) + postsaccade)));
                timewinaroundsaccade = timewinaroundsaccade(1:Nt);
                err_ver = ver_mean_pred{i}(timewinaroundsaccade) - ver_mean{i}(timewinaroundsaccade);
                err_hor = hor_mean_pred{i}(timewinaroundsaccade) - hor_mean{i}(timewinaroundsaccade);
                ver_pred = ver_mean_pred{i}(timewinaroundsaccade);
                hor_pred = hor_mean_pred{i}(timewinaroundsaccade);
                err_mag = sqrt(err_hor.^2 + err_ver.^2);
                err_dir = atan2d(err_ver,err_hor);
                
                bearing_true = atan2d(ver_mean{i}(timewinaroundsaccade),hor_mean{i}(timewinaroundsaccade));
                bearing_pred = atan2d(ver_mean_pred{i}(timewinaroundsaccade),hor_mean_pred{i}(timewinaroundsaccade));
                err_bearing = bearing_pred - bearing_true; % this is bearing error, not the direction of error
                
                trackingerror.hor{i}{end+1} = err_hor;
                trackingerror.ver{i}{end+1} = err_ver;
                trackingerror.mag{i}{end+1} = err_mag;
                trackingerror.dir{i}{end+1} = err_dir;
                trackingerror.ver_pred{i}{end+1} = ver_pred;
                trackingerror.hor_pred{i}{end+1} = hor_pred;
                
                trackingerror.bearing{i}{end+1} = err_bearing;
            end
        end
    end
    
    % temporary block for debugging
%     figure(1); plot(ts{i},yle{i}); hold on; plot(ts{i},yle_pred{i}); hold off;
%     figure(2); plot(ts{i},zle{i}); hold on; plot(ts{i},zle_pred{i}); hold off;
end

%% regression
hor_error = []; ver_error = [];
mag_error = []; dir_error = []; 
for k=1:ntrls
    ver_error = [ver_error cell2mat(trackingerror.ver{k})]; 
    hor_error = [hor_error cell2mat(trackingerror.hor{k})];     
    mag_error = [mag_error cell2mat(trackingerror.mag{k})]; 
    dir_error = [dir_error cell2mat(trackingerror.dir{k})]; 
end
sacxy = cell2mat(corrective.sacxy);
ver_sac = sacxy(1,:); hor_sac = sacxy(2,:);
mag_sac = sqrt(sum(cell2mat(corrective.sacxy).^2));
dir_sac = cell2mat(corrective.sacdir);

trackingerror.ridgeregress.ver = ridge(ver_sac(:),ver_error',5e3);
trackingerror.ridgeregress.hor = ridge(hor_sac(:),hor_error',5e3);
trackingerror.ridgeregress.mag = ridge(mag_sac(:),mag_error',5e3);
trackingerror.ridgeregress.dir = ridge(dir_sac(:),dir_error',5e3);

%% save saccadic eye movements
eye_saccade.corrective.true.val = corrective.sacxy;
eye_saccade.corrective.true.dir = corrective.sacdir;
eye_saccade.corrective.pred.val = corrective.sacxy_pred;
eye_saccade.corrective.pred.dir = corrective.sacdir_pred;
eye_saccade.corrective.time = corrective.sac_time;

eye_saccade.acquisitive.true.val = acquisitive.sacxy;
eye_saccade.acquisitive.true.dir = acquisitive.sacdir;
eye_saccade.acquisitive.time = acquisitive.sac_time;

eye_saccade.explorative.true.val = explorative.sacxy;
eye_saccade.explorative.true.dir = explorative.sacdir;
eye_saccade.explorative.time = explorative.sac_time;

eye_saccade.corrective.trackingerror = trackingerror;