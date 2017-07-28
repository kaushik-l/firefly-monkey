function [sua, mua] = GetUnits_phy(f_spiketimes, f_spikeclusters, f_clustergroups)

spiketimes = readNPY(f_spiketimes);
cluster_ids = readNPY(f_spikeclusters);
clusters = readCSV(f_clustergroups);

sua_indx = find(strcmp({clusters.label},'good'));
for i = 1:length(sua_indx)
    sua(i).tspk = find(cluster_ids == str2double(clusters(sua_indx(i)).id));
end

mua_indx = find(strcmp({clusters.label},'mua'));
for i = 1:length(mua_indx)
    mua(i).tspk = find(cluster_ids == str2double(clusters(mua_indx(i)).id));
end