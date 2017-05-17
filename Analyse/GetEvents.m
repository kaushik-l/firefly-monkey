function t_events = GetEvents(fname)

[~, ts, sv] = plx_event_ts(fname, 257); count=0;
t_events.start = ts(sv==1);
ts(sv==1) = []; sv(sv==1) = [];
nevents = find(sv==3,1,'last');
for i=1:nevents
    if sv(i)==3
        count=count+1;
        t_end(count)=ts(i);
        if sv(i-1)==4
            t_rew(count)=ts(i-1);
            t_beg(count)=ts(i-2);
        elseif sv(i-1)==2
            t_rew(count)=nan;
            t_beg(count)=ts(i-1);
        elseif sv(i-1)==3
            t_rew(count)=nan;
            t_beg(count)=ts(i-1);
        else
            error('strobed unknown entity');
        end
    end
end

t_events.beg = t_beg;
t_events.rew = t_rew;
t_events.end = t_end;