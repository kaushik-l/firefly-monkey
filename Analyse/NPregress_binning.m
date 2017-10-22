function [x,y,pval] = NPregress_binning(xt,yt,binedges,nbootstraps,dt)

% performs nonparametric regression of yt onto xt by binning values in xt 
% into bins defined by binedges.
if nargin<4, nbootstraps = []; dt = 1;
elseif nargin<5, dt = 1; end
if ~isempty(nbootstraps), compute_sem = 1; end
nbins = length(binedges);

%% test statistical significance of tuning
xval = cell(nbins-1,1);
xgroup = cell(nbins-1,1);
yval = cell(nbins-1,1);
for i=1:nbins-1
    indx = xt>binedges(i) & xt<binedges(i+1);
    yval{i} = yt(indx)/dt;
    xval{i} = xt(indx);
    xgroup{i} = cell(length(xval{i}),1); xgroup{i}(:) = {num2str(i)};
end
pval = anova1(cell2mat(yval),vertcat(xgroup{:}),'off'); % one-way unbalanced anova

%% determine tuning function
if ~compute_sem % just return the means
    x.mu = cellfun(@mean,xval);
    y.mu = cellfun(@mean,yval);
else % obtain both mean and sem by bootstrapping (slow)
    x_mu = zeros(nbootstraps,nbins-1);
    y_mu = zeros(nbootstraps,nbins-1);
    for i=1:nbins-1
        indx = find(xt>binedges(i) & xt<binedges(i+1));
        for j=1:nbootstraps
            sampindx = randsample(indx,length(indx),true); % sample with replacement
            x_mu(j,i) = mean(xt(sampindx));
            y_mu(j,i) = mean(yt(sampindx)/dt);
        end
    end
end
y.mu = mean(y_mu); % mean
y.sem = std(y_mu); % standard error of the mean
x.mu = mean(x_mu);
x.sem = std(x_mu);