function x = DeconcatenateTrials(xt,ts,timewindow,duration_zeropad,duration_nanpad)

% this function inverts the Concatenation performed by ConcatenateTrials
% x and ts are cell arrays of length N
% x{i}: time-series of stimulus in trial i
% ts{i}: vector of time points in the ith trial
% timewindow: Nx2 array - the columns corresponds to start and end of analysis window
% e.g. to analyse all datapoints, timeindow(i,:) = [ts{i}(1) ts{i}(end)]

if nargin<4, duration_zeropad = []; duration_nanpad = []; end
ntrls = length(ts);
twin = mat2cell(timewindow,ones(1,ntrls));

t2 = cellfun(@(x) x(2:end-1),ts,'UniformOutput',false);
nt = (cellfun(@(x) numel(x), t2));

% deconcatenate stimulus
x = [];
if ~isempty(xt)
    for i=1:length(nt)
        x{i} = xt(1:nt(i)); x{i} = [x{i}(1) ; x{i} ; x{i}(end)];
        xt(1:nt(i)) = [];
    end
end