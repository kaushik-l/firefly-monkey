function clusters = readCSV(f_clustergroups)

fid=fopen(f_clustergroups);
C = textscan(fid, '%s');
fclose(fid);

nclusters = length(C{1})/2;
i = 1;
while i < nclusters
    clusters(i).id = C{1}{2*i+1};
    clusters(i).label = C{1}{2*i+2};
    i = i + 1;
end