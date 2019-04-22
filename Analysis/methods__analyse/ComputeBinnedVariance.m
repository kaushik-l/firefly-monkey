function [mu,sig] = ComputeBinnedVariance(x_ref,x,binedges,removeoutliers)

%% remove outliers
if removeoutliers
    outlierindx = (abs(x_ref - x) > abs(x_ref));
    x_ref = x_ref(~outlierindx);
    x = x(~outlierindx);
end

%% create binedges
if nargin<3 || isempty(binedges)
    nbins = 10;
    binedges = linspace(min(x_ref),max(x_ref),nbins + 1);
else
    nbins = numel(binedges) - 1;
end

%% define bins
for i=1:nbins
    mu(i) = 0.5*(binedges(i) + binedges(i+1));
    sig(i) = std(x(x_ref>binedges(i) & x_ref<binedges(i+1)));    
end