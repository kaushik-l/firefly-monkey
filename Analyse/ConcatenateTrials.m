function [xt,zt,yt,xt_pad,zt_pad,yt_pad] = ConcatenateTrials(x,z,tspk,ts,timewindow,duration_zeropad,duration_nanpad)

% x, ts, and tspk are cell arrays of length N
% x{i}: time-series of stimulus in trial i
% z{i}: time of event in trial i
% tspk{i}: vector of spike times in trial i
% ts{i}: vector of time points in the ith trial
% timewindow: Nx2 array - the columns corresponds to start and end of analysis window
% e.g. to analyse all datapoints, timeindow(i,:) = [ts{i}(1) ts{i}(end)]

if nargin<6, duration_zeropad = []; duration_nanpad = []; end
ntrls = length(ts);
twin = mat2cell(timewindow,ones(1,ntrls));

%% concatenate data from different trials
% concatenate spikes
if ~(length(tspk{1}) == length(ts{1})) % data as  spike times
    y = cellfun(@(x,y) hist(x,y),tspk,ts,'UniformOutput',false);
else % data already in spike counts
    y = tspk;
end
t2 = cellfun(@(x) x(2:end-1),ts,'UniformOutput',false);
y2 = cellfun(@(x) x(2:end-1)',y,'UniformOutput',false); 
y2 = cellfun(@(x) x(:),y2,'UniformOutput',false); % transpose is to reshape to column vector
yt = cellfun(@(x,y,z) x(y>z(1) & y<z(2)),y2(:),t2(:),twin(:),'UniformOutput',false);

% concatenate stimulus
xt = [];
if ~isempty(x)
    x2 = cellfun(@(x) x(2:end-1),x,'UniformOutput',false);
    xt = cellfun(@(x,y,z) x(y>z(1) & y<z(2)),x2(:),t2(:),twin(:),'UniformOutput',false);
end

% concatenate events
zt = [];
if ~isempty(z)
    z2 = cellfun(@(x,y) [diff(y>x) ; 0],z(:),t2(:),'UniformOutput',false); % transpose is to reshape to column vector
    zt = cellfun(@(x,y,z) x(y>z(1) & y<z(2)),z2(:),t2(:),twin(:),'UniformOutput',false);
end

% pad each trial with zeros if needed
if ~isempty(duration_zeropad)
    dt = median(diff(ts{1}));
    padding = zeros(round(duration_zeropad/dt),1);
    if ~isempty(xt), xt_pad = cell2mat(cellfun(@(x) [padding(:) ; x(:)],xt(:),'UniformOutput',false)); else, xt_pad = []; end % zero-pad for cross-correlations
    if ~isempty(zt), zt_pad = cell2mat(cellfun(@(x) [padding(:) ; x(:)],zt(:),'UniformOutput',false)); else, zt_pad = []; end
    yt_pad = cell2mat(cellfun(@(x) [padding(:) ; x(:)],yt(:),'UniformOutput',false));
elseif ~isempty(duration_nanpad)
    dt = median(diff(ts{1}));
    padding = nan(round(duration_nanpad/dt),1);
    if ~isempty(xt), xt_pad = cell2mat(cellfun(@(x) [padding(:) ; x(:)],xt(:),'UniformOutput',false)); xt_pad = [xt_pad ; padding(:)]; else, xt_pad = []; end % zero-pad for cross-correlations
    if ~isempty(zt), zt_pad = cell2mat(cellfun(@(x) [padding(:) ; x(:)],zt(:),'UniformOutput',false)); zt_pad = [zt_pad ; padding(:)]; else, zt_pad = []; end
    yt_pad = cell2mat(cellfun(@(x) [padding(:) ; x(:)],yt(:),'UniformOutput',false)); yt_pad = [yt_pad ; padding(:)];
else
    xt_pad = [];
    zt_pad = [];
    yt_pad = [];
end

if ~isempty(xt), xt = cell2mat(xt); end
if ~isempty(zt), zt = cell2mat(zt); end
yt = cell2mat(yt);