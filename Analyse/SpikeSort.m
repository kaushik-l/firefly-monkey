function SpikeSort(fname,useGPU)

%% load config file
fpath = pwd; 
ops = config_utaharray(fname,fpath,useGPU);
map_utaharray(fpath);

%% Run the normal Kilosort processing
[rez, DATA, uproj] = preprocessData(ops);   % preprocess data and extract spikes for initialization
rez = fitTemplates(rez, DATA, uproj);   % fit templates iteratively
rez = fullMPMU(rez, DATA);  % extract final spike times (overlapping extraction)

%% auto-merge
% rez = merge_posthoc2(rez);
save('rez.mat','rez');
% save python results file for Phy
rezToPhy(rez, fpath);

%% for debugging PCs (visualization in phy)
% load rez.mat;

% clus_id = 15;
% PC_1 = rez.cProjPC(rez.st3(:,2)==clus_id,1,1);
% PC_2 = rez.cProjPC(rez.st3(:,2)==clus_id,2,1);
% indx = randperm(length(PC_1)); indx = indx(1:1000); % pick 1000 spikes at random
% plot(PC_1(indx),PC_2(indx),'.');
% axis([-50 50 -50 50]); hline(0,'--k'); vline(0,'--k');
% 
% clus_id = 16;
% PC_1 = rez.cProjPC(rez.st3(:,2)==clus_id,1,1);
% PC_2 = rez.cProjPC(rez.st3(:,2)==clus_id,2,1);
% indx = randperm(length(PC_1)); indx = indx(1:1000); % pick 1000 spikes at random
% hold on; plot(PC_1(indx),PC_2(indx),'.r');