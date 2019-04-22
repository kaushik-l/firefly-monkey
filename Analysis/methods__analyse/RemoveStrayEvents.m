function t_start = RemoveStrayEvents(t_start,T_smr)

nfiles = numel(T_smr);

for j=1:nfiles
    nevents = numel(t_start); removeevent = [];
    for i=(j+1):nevents
        if t_start(i) - t_start(j) < T_smr(j)
            removeevent = [removeevent i];
        else
            break;
        end
    end
    t_start(removeevent) = [];
end