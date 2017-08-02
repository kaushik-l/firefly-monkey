

function [isiV percentViol clusterViol] = isiViolations(resultsDirectory,pViol)
% Code to look at the ISI violations in Kilosort output files. Modified by
% EA 19/07/2017

% In:
%    resultsDirectory = Results directory (with the npy sorted files)
%    pViol = threshold in percentage of the clusters that will be included
%    in text file as output. 
% Out:
    % isiV: Estimated rate of spikes that come from another neuron besides
    % the primary one. <-- Hard to trust! So be careful.  
    
    % percentViol: Percentage of violations. 
    
    % clusterViol: Cluster IDs of neurons that violated more than the percentage stated in pViol. 
    
    % filename_ClustersToCheck = text file that will be created in resultsDirectory of the clusters that exceeded pViol. 
    
pViol = 2; % Num
cd(resultsDirectory)

% Extract the name of the csv file 
d=dir('*.csv');
d=d.name(1:14); 

%User input
% doPlot = input('Do you want to plot  Yes=1  No=0:  ');


%% Precompute the locations of files to be loaded
spikeClustersPath = fullfile(resultsDirectory,'spike_clusters.npy');
spikeTemplatesPath = fullfile(resultsDirectory,'spike_templates.npy');
spikeTimesPath= fullfile(resultsDirectory,'spike_times.npy');
paramsPath= fullfile(resultsDirectory,'params.py'); 


%% Read data from file
refDur = 0.001;
minISI = 0.001;

fprintf(1, 'loading data for ISI computation\n');
if exist(spikeClustersPath)
    spike_clusters = readNPY(spikeClustersPath);
else 
    spike_clusters = readNPY(spikeTemplatesPath);
end
% spike_clusters = spike_clusters+1; % because in Python indexes start at 0
spike_clusters = spike_clusters; % Because we found that cluster IDs did NOT match. 


spike_times = readNPY(spikeTimesPath);
params = readKSparams(paramsPath);
spike_times = double(spike_times)/params.sample_rate;

fprintf(1, 'computing ISI violations\n');

clusterIDs = unique(spike_clusters);
isiV = zeros(1,numel(clusterIDs));
counter=0;
% if doPlot
%     hFig=figure('Position', [1040 49 206 913]);
% end

%% READ from CSV file the relevant clusters (in this case = good)
startRow = 2;
filenameCSV = 'cluster_groups.csv';
fileID = fopen(filenameCSV,'r');

dataFromCSV = textscan(fileID, '%f%s%[^\n\r]', 'Delimiter', '\t', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
cluster_numbers = dataFromCSV{:, 1};
group_labels = dataFromCSV{:, 2};

%% 
for c = 1:numel(clusterIDs)
    counter = counter+1;
    [fpRate, numViolations] = ISIViolations(spike_times(spike_clusters==clusterIDs(c)), minISI, refDur);
    isiV(c) = fpRate;
    nSpikes = sum(spike_clusters==clusterIDs(c));
    percentViol(counter)= (numViolations/nSpikes)*100;
    
    %%%%%%% Plot
%     if doPlot
%         if numViolations>=1
%             spike_train = spike_times(spike_clusters==clusterIDs(c));
%             spike_diff = diff(spike_train);
%             spikeViolations = sum(diff(spike_train)<=refDur); total_spike=(numel(diff(spike_train)));
%             spike_train_viol = spike_train(spikeViolations);
%             %plot number of violations and total number of spikes
%             hb1=bar(double(clusterIDs(c)),total_spike);
%             hold on
%             hb2=bar(double(clusterIDs(c)),spikeViolations);
%             set(hb1,'FaceColor', 'none')
%             set(hb2,'FaceColor', [1 0 0])
%             labelForBar = [double(clusterIDs(c)) spikeViolations];
%             set(gca, 'TickDir', 'out', 'box', 'off')
%             boxPositionX= xlim;
%             boxPositionY=ylim;
%             text(boxPositionX(1)+0.45,total_spike+100,num2str(percentViol(counter)));
%             % Plot ISIs
%             figure; 
%             hist(spike_diff,100);
%             xlim([0 0.200]); vline(0.001, '--r');
%         else
%             fprintf(['No ISI violations for cluster:  ' num2str(clusterIDs(c))])
%         end
%         waitforbuttonpress
%         close all
%     end
    %%%%%%% END Plot
    
    fprintf(1, 'cluster %3d: %d viol (%d spikes), %.2f estimated FP rate\n', clusterIDs(c), numViolations, nSpikes, fpRate);
    fprintf(1, 'cluster %3d:  Percent of Violations %d \n',clusterIDs(c), percentViol(counter))
    if percentViol(counter)>pViol & strcmp(group_labels(counter),'good')
        clusterViol(counter) = clusterIDs(c);
        
        %Save cluster number to text file
        fid=fopen([fullfile(d), '_ClustersToCheck'], 'at');
        header1= 'Cluster ID';
        header2= 'Percent of violations';
        fprintf(fid,'\n');
        fprintf(fid, [header1 ' ' header2 '\n' ]);
        fprintf(fid, '\n%f %f\n', [clusterIDs(c) percentViol(counter)]);
        fclose(fid);
        
    end
    
    
    
    
    
end



