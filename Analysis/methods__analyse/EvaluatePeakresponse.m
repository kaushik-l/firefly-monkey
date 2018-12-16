function peakresp = EvaluatePeakresponse(trials,timepoints,binwidth,peaktimewindow,minpeakprominence,nbootstraps,mintrialsforstats)

preevent_nanflag = false;
postevent_nanflag = false;
ntrls = length(trials);
if ntrls<mintrialsforstats % not enough trials for stats
    preevent_nanflag = true;
    postevent_nanflag = true;
else
    nt = numel(timepoints);
    nspk = zeros(nbootstraps,nt);
    
    %% obtain bootstrapped estimate of spike rates
    for i=1:nbootstraps
        trlindx = randsample(1:ntrls,ntrls,true); % sample with replacement
        trials2 = trials(trlindx);
        nspk(i,:) = Spiketimes2Rate(trials2,timepoints,binwidth);
    end
    nspk_mu = mean(nspk);
    
    %% detect peaks
    [peakVals,peakLocs]=findpeaks(nspk_mu,'MinPeakProminence',minpeakprominence,'SortStr','descend'); % peaks > nearest_valley + minpeakprominence
    if length(peakLocs)>4 % consider only the four most prominent peaks
        peakVals = peakVals(1:4);
        peakLocs = peakLocs(1:4);
    end
    
    %% assess significance of peak response
    % define time-window to select peaks
    [~,preeventLoc] = min(abs(timepoints-peaktimewindow(1)));
    [~,eventLoc] = min(abs(timepoints-0));
    [~,posteventLoc] = min(abs(timepoints-peaktimewindow(2)));
    % evaluate the largest pre-event peak
    preeventpeakLocs = peakLocs(peakLocs>=preeventLoc & peakLocs<eventLoc);
    preeventpeakVals = peakVals(peakLocs>=preeventLoc & peakLocs<eventLoc);
    if ~isempty(preeventpeakLocs)
        [~,indx] = sort(preeventpeakVals,'descend');
        preevent.rate = preeventpeakVals(indx(1));
        preevent.time = timepoints(preeventpeakLocs(indx(1)));
        [~,preevent.pval] = ttest2(nspk(:),nspk(:,preeventpeakLocs(indx(1)))); % is P(r|t=t_preeventpeakindx) different from P(r)? need not be true!
    else
        preevent_nanflag = true; % not significant
    end
    % evaluate the largest post-event peak
    posteventpeakLocs = peakLocs(peakLocs>=eventLoc & peakLocs<posteventLoc);
    posteventpeakVals = peakVals(peakLocs>=eventLoc & peakLocs<posteventLoc);
    if ~isempty(posteventpeakLocs)
        [~,indx] = sort(posteventpeakVals,'descend');
        postevent.rate = posteventpeakVals(indx(1));
        postevent.time = timepoints(posteventpeakLocs(indx(1)));
        [~,postevent.pval] = ttest2(nspk(:),nspk(:,posteventpeakLocs(indx(1)))); % is P(r|t=t_posteventpeakindx) different from P(r)? need not be true!
    else
        postevent_nanflag = true; % not significant
    end
end

%% fill with nans if not significant
if preevent_nanflag
    preevent.pval = nan;
    preevent.rate = nan;
    preevent.time = nan;
end
if postevent_nanflag
    postevent.pval = nan;
    postevent.rate = nan;
    postevent.time = nan;
end

%% return result
peakresp.preevent = preevent;
peakresp.postevent = postevent;