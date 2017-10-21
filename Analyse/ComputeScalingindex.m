function [scalingindex,lockingindex] = ComputeScalingindex(trials,events,timepoints,binwidth,ntrialgroups)

%% define time boundaries for temporal rescaling
timewindow.trialduration = [[events.t_targ]' [events.t_end]'];
timewindow.pathduration = [[events.t_targ]' [events.t_stop]'];
timewindow.movementduration = [[events.t_move]' [events.t_stop]'];
timewindow.fullduration = [[events.t_move]' [events.t_end]'];
period = fields(timewindow);

for i=1:length(period)
    %% determine duration
    t1 = timewindow.(period{i})(:,1);
    t2 = timewindow.(period{i})(:,2);
    Td = t2 - t1;
    %% sort trials by duration
    binedges = prctile(Td,linspace(0,100,ntrialgroups+1));
    %% actual response for each trialgroup
    ts = cell(ntrialgroups,1);
    nspk = cell(ntrialgroups,1);
    for j=1:ntrialgroups
        trialindx = Td>binedges(j) & Td<binedges(j+1);
        trials_temp = ShiftSpikes(trials(trialindx),t1(trialindx));
        ts{j} = 0:binwidth:binedges(j+1);
        nspk{j} = Spiketimes2Rate(trials_temp,ts{j},binwidth);
    end
    %% time-rescaled prediction & scaling index
    nspk_pred = cell(ntrialgroups);
    rsquared = zeros(ntrialgroups);
    for j=1:ntrialgroups
        for k=1:ntrialgroups
            ts2 = linspace(ts{j}(1),ts{j}(end),numel(ts{k}));
            nspk_pred{j,k} = interp1(ts{j},nspk{j},ts2); % rescaled response in trialgroup k predicted from trialgroup j
            rsquared(j,k) = 1-sum((nspk{k}-nspk_pred{j,k}).^2)/sum(nspk{k}.^2); % quality of prediction
        end
    end
    rsquared = rsquared + diag(nan(ntrialgroups,1));
    scalingindex.(period{i}) = nanmean(rsquared(:));
end

%% determine trialduration
t1 = timewindow.fullduration(:,1);
t2 = timewindow.fullduration(:,2);
Td = t2 - t1;
%% sort trials by trialduration
binedges = prctile(Td,linspace(0,100,ntrialgroups+1));
%% identify timepoints of aligning events
alignevents.move = [events.t_move]';
alignevents.target = [events.t_targ]';
alignevents.stop = [events.t_stop]';
%% actual event-aligned response for each trialgroup
period = fields(alignevents);
for i=1:length(period)
    t1 = alignevents.(period{i});
    nspk = cell(ntrialgroups,1);
    for j=1:ntrialgroups
        trialindx = Td>binedges(j) & Td<binedges(j+1);
        trials_temp = ShiftSpikes(trials(trialindx),t1(trialindx));
        nspk{j} = Spiketimes2Rate(trials_temp,timepoints.(period{i}),binwidth);
    end
    %% locking index
    rsquared = zeros(ntrialgroups);
    for j=1:ntrialgroups
        for k=1:ntrialgroups
            rsquared(j,k) = 1-sum((nspk{k}-nspk{j}).^2)/sum(nspk{k}.^2); % quality of prediction
        end
    end
    rsquared = rsquared + diag(nan(ntrialgroups,1));
    lockingindex.(period{i}) = nanmean(rsquared(:));
end