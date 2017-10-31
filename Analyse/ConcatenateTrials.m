function [xt,yt,xt_pad,yt_pad] = ConcatenateTrials(x,ts,tspk,timewindow,duration_zeropad)

% x, ts, and tspk are cell arrays of length N
% x{i}: time-series of stimulus in trial i
% t{i}: vector of time points in the ith trial
% tspk{i}: vector of spike times in trial i
% timewindow: Nx2 array - the columns corresponds to start and end of analysis window
% e.g. to analyse all datapoints, timeindow(i,:) = [ts{i}(1) ts{i}(end)]

if nargin<5, duration_zeropad = []; end
ntrls = length(x);

%% concatenate data from different trials
y = cellfun(@(x,y) hist(x,y),tspk,ts,'UniformOutput',false);
t2 = cellfun(@(x) x(2:end-1),ts,'UniformOutput',false);
x2 = cellfun(@(x) x(2:end-1),x,'UniformOutput',false);
y2 = cellfun(@(x) x(2:end-1)',y,'UniformOutput',false); 
y2 = cellfun(@(x) x(:),y2,'UniformOutput',false); % transpose is to reshape to column vector

twin = mat2cell(timewindow,ones(1,ntrls));
xt = cellfun(@(x,y,z) x(y>z(1) & y<z(2)),x2(:),t2(:),twin(:),'UniformOutput',false);
yt = cellfun(@(x,y,z) x(y>z(1) & y<z(2)),y2(:),t2(:),twin(:),'UniformOutput',false);
% pad each trial with zeros if needed
if ~isempty(duration_zeropad)
    temporal_binwidth = median(diff(ts{1}));
    padding = zeros(round(duration_zeropad/temporal_binwidth),1);
    xt_pad = cell2mat(cellfun(@(x) [padding(:) ; x(:)],x2(:),'UniformOutput',false)); % zero-pad for cross-correlations
    yt_pad = cell2mat(cellfun(@(x) [padding(:) ; x(:)],y2(:),'UniformOutput',false));
else
    xt_pad = [];
    yt_pad = [];
end

xt = cell2mat(xt);
yt = cell2mat(yt);