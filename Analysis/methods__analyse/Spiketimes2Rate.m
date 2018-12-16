function [nspk,timepoints] = Spiketimes2Rate(trials,timepoints,binwidth)

ntrls = length(trials);
timepoints = [timepoints(1)-binwidth timepoints timepoints(end)+binwidth];

% compute psth
[nspk,~] = hist(cell2mat({trials.tspk}'),timepoints);

% throw away histogram edges
nspk = nspk(2:end-1); 
timepoints = timepoints(2:end-1);

% trial-average firing rates in units of spikes/s
nspk = nspk/(ntrls*binwidth);