function [sua, mua] = GetUnits_phy(f_spiketimes, f_spikeclusters, f_clustergroups)%, f_clusterlocations)

spiketimes = readNPY(f_spiketimes);
cluster_ids = readNPY(f_spikeclusters);
clusters = readCSV(f_clustergroups);
% cluster_locs = readtable(f_clusterlocations);

sua_indx = find(strcmp({clusters.label},'good'));
for i = 1:length(sua_indx)
    sua(i).tspk = spiketimes(cluster_ids == str2double(clusters(sua_indx(i)).id));
    sua(i).cluster_id = str2double(clusters(sua_indx(i)).id);
%     sua(i).channel_id = table2array(cluster_locs(str2double({clusters.id}) == str2double(clusters(sua_indx(i)).id),'Ch_num'));
end

mua_indx = find(strcmp({clusters.label},'mua'));
for i = 1:length(mua_indx)
    mua(i).tspk = spiketimes(cluster_ids == str2double(clusters(mua_indx(i)).id));
    mua(i).cluster_id = str2double(clusters(mua_indx(i)).id);
%     mua(i).channel_id = table2array(cluster_locs(str2double({clusters.id}) == str2double(clusters(mua_indx(i)).id),'Ch_num'));
end