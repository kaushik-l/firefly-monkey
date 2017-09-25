function X_mat = struct2mat(X_struct,field,alignpos)

% 'X_struct' is a structure array of observations
% 'field' is a field of X_struct with dim 1 x Time
% 'X_mat' is a matrix with dim Observation x Time

% alignpos can take two values 'start' or 'end' - use 'start' to align 
% observations to the start of each row of X_mat with nans in the end 
% use 'end' to align observations to the end of each row

%% initialise
nrows = length(X_struct);
% find longest observation
ns = zeros(1,nrows);
for i=1:nrows
    ns(i) = length(X_struct(i).(field));
end
ns_max = max(ns);
% store data in a matrix (Observation x Time)
X_mat = nan(nrows,ns_max);

%% align
if strcmp(alignpos,'start')
    for i=1:nrows
        X_mat(i,1:ns(i)) = X_struct(i).(field);
    end
elseif strcmp(alignpos,'end')
    for i=1:nrows
        X_mat(i,end-ns(i)+1:end) = X_struct(i).(field);
    end
end