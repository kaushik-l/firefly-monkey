function [t_events,prs] = GetEvents_nev(f_nev,prs)
% get begin, reward, and end times from plx file

NEV = openNEV(['/' f_nev], 'nosave');
events = NEV.Data.SerialDigitalIO;
prs.fs = NEV.MetaTags.TimeRes; % sampling rate

t_events.t_start = events.TimeStampSec(events.UnparsedData==1);
t_events.t_rew = events.TimeStampSec(events.UnparsedData==4);

%% remove extra "beg" events (these usually occur when the experiment is
% stopped causing trials to be aborted before they "end")
t_beg = events.TimeStampSec(events.UnparsedData==2);
t_end = events.TimeStampSec(events.UnparsedData==3);
t_end = [0 t_end]; % add dummy entry
for i=2:length(t_end)
    t_beg2 = t_beg(t_beg>t_end(i-1) & t_beg<t_end(i));
    if length(t_beg2)>1 % takes care of incomplete trials - usually happens whenever an experiment is "STOPPED"
        t_beg2(end) = []; % this is the correct t_beg
        for j=1:length(t_beg2)
            t_beg(t_beg==t_beg2(j)) = []; % remove t_beg that had no end
        end
    end
end
t_end(1) = []; % remove dummy entry
if t_beg(end)>t_end(end), t_beg(end) = []; end % remove last incomplete trial

%% remove duplicate "end" events
iti = diff(t_end);
duplicates = find(iti < 0.5); % trials cannot be less than 500ms long
t_end(duplicates + 1) = [];

%% deal with missing "beg" event for the first trial (happens when spike2 
%was started before neural recording)
if t_beg(1) > t_end(1), t_beg = [0 t_beg]; end % put the missing event at t=0

%% save events
t_events.t_beg = t_beg;
t_events.t_end = t_end;