function [sua, mua] = GetUnits_phy(f_spiketimes, f_spikeclusters, f_clustergroups, f_clusterlocations, electrode_type)

sua = []; mua = [];

cluster_locs = [];
[~,electrode_id] = MapChannel2Electrode(electrode_type);
spiketimes = readNPY(f_spiketimes);
cluster_ids = readNPY(f_spikeclusters);
if exist(f_clustergroups,'file'), clusters = readCSV(f_clustergroups); 
elseif exist('cluster_group.tsv','file')
    data = tdfread('cluster_info.tsv');
    clusters = struct('id', arrayfun(@(x) num2str(x), data.id, 'UniformOutput', false),...
        'label', cellfun(@(x) strtrim(x), mat2cell(data.group,ones(size(data.group,1),1),size(data.group,2)),'UniformOutput', false));
end
if exist(f_clusterlocations,'file') % remove if clause once we have these files for all recording sessions
    cluster_locs = readtable(f_clusterlocations);
    load('waveForms.mat')
elseif exist('cluster_info.tsv','file')
    data = tdfread('cluster_info.tsv');
    cluster_locs = array2table([data.id data.channel+1],'VariableNames',{'Cluster_ID','Ch_num'}); % +1 because of 0-based indexing
    load('waveForms.mat');
    if exist('waveFormsMean'), waveForms(:,1,:) = waveFormsMean; end
end

sua_indx = find(strcmp({clusters.label},'good'));
for i = 1:length(sua_indx)
    sua(i).tspk = spiketimes(cluster_ids == str2double(clusters(sua_indx(i)).id));
    sua(i).cluster_id = str2double(clusters(sua_indx(i)).id);
    if ~isempty(cluster_locs)
        sua(i).channel_id = table2array(cluster_locs(str2double({clusters.id}) == str2double(clusters(sua_indx(i)).id),'Ch_num'));
        sua(i).electrode_id = electrode_id(sua(i).channel_id);
        sua(i).electrode_type = electrode_type;
        sua(i).spkwf = squeeze(mean(waveForms(str2double({clusters.id}) == str2double(clusters(sua_indx(i)).id),:,:),2));
    else
        sua(i).channel_id = [];
        sua(i).electrode_id = [];
        sua(i).electrode_type = electrode_type;
        sua(i).spkwf = [];
    end
end

mua_indx = find(strcmp({clusters.label},'mua'));
for i = 1:length(mua_indx)
    mua(i).tspk = spiketimes(cluster_ids == str2double(clusters(mua_indx(i)).id));
    mua(i).cluster_id = str2double(clusters(mua_indx(i)).id);
    if ~isempty(cluster_locs)
        mua(i).channel_id = table2array(cluster_locs(str2double({clusters.id}) == str2double(clusters(mua_indx(i)).id),'Ch_num'));
        mua(i).electrode_id = electrode_id(mua(i).channel_id);
        mua(i).electrode_type = electrode_type;
        mua(i).spkwf = squeeze(mean(waveForms(str2double({clusters.id}) == str2double(clusters(mua_indx(i)).id),:,:),2));
    else
        mua(i).channel_id = [];
        mua(i).electrode_id = [];
        mua(i).electrode_type = electrode_type;
        mua(i).spkwf = [];
    end
end