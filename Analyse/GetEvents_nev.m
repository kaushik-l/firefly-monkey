function [t_events,prs] = GetEvents_nev(fname,prs)
% get begin, reward, and end times from plx file

load(fname);
t_events.t_start = events.TimeStampSec(events.UnparsedData==1);
t_events.t_rew = events.TimeStampSec(events.UnparsedData==4);

% remove extra "beg" events - these usually occur when the experiment is
% stopped causing trials to be aborted before they "end".
t_beg = events.TimeStampSec(events.UnparsedData==2);
t_end = events.TimeStampSec(events.UnparsedData==3);
t_end = [0 t_end]; % add dummy entry
for i=2:length(t_end)
    t_beg2 = t_beg(t_beg>t_end(i-1) & t_beg<t_end(i));
    if length(t_beg2)>1
        t_beg2(end) = [];
        for j=1:length(t_beg2)
            t_beg(t_beg==t_beg2(j)) = [];
        end
    end
end
t_end(1) = []; % remove dummy entry
if t_beg(end)>t_end(end), t_beg(end) = []; end % remove last incomplete trial
t_events.t_beg = t_beg;
t_events.t_end = t_end;

prs.fs = MetaTags.TimeRes; % sampling rate