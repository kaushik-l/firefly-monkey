function units = GetUnits_plx(fname,getall,getch,electrode_type)

nunits=0;
tscounts = plx_info(fname,1);                                               % changed from fullread=1 to 0 on 051815
[~,ncol] = size(tscounts);
nrow = find(all(tscounts'==0)==0,1,'last');
if getall==1, k=1; else k=2; end
if nargin<3, getch=[]; end

if isempty(getch)
    for i=1:ncol
        for j=k:nrow
            if tscounts(j,i)>0
                nunits = nunits+1;
                units{nunits}.nspk = tscounts(j,i);
                [~,~,units(nunits).tspk,units(nunits).spkwf] = plx_waves(fname,i-1,j-1);
                units(nunits).spkwf = mean(units(nunits).spkwf);
                units(nunits).channel_id = i-1;
                units(nunits).electrode_id = i-1;
                units(nunits).cluster_id = j-1;
                units(nunits).electrode_type = electrode_type;
            end
        end
    end
else
    for j=k:nrow
        if tscounts(j,getch+1)>0
            nunits = nunits+1;
            units(nunits).nspk = tscounts(j,getch+1);
            [~,~,units(nunits).tspk,units(nunits).spkwf] = plx_waves(fname,getch,j-1);
            units(nunits).spkwf = mean(units(nunits).spkwf);
            units(nunits).channel_id = getch;
            units(nunits).electrode_id = getch;
            units(nunits).cluster_id = j-1;
            units(nunits).electrode_type = electrode_type;
        end
    end
end