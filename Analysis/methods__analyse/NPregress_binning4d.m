function [x,f] = NPregress_binning4d(xt,yt,dt,nbins)

% NPREGRESS_BINNING Performs nonparametric regression by binning
%   [x,f,pval] = NPregress_binning(xt,yt,binedges,nbootstraps,dt) performs 
% nonparametric regression of 'yt' onto 'xt' by grouping values in 'xt' 
% into bins specified by 'binedges'.
%
% 'nbootstraps' specifies the number of bootstrap repetitions used to 
% compute standard error of the mean of the estimator.
if nargin<4, nbins = []; end
if nargin<3, dt = []; end

if isempty(dt), dt = 1; end
if isempty(nbins), nbins = [10; 10]; end
nbins1 = nbins(1); nbins2 = nbins(2); nbins3 = nbins(3); nbins4 = nbins(4);
xt1 = xt(:,1); xt2 = xt(:,2); xt3 = xt(:,3); xt4 = xt(:,4);
binedges1 = linspace(min(xt1),max(xt1),nbins1+1);
binedges2 = linspace(min(xt2),max(xt2),nbins2+1);
binedges3 = linspace(min(xt3),max(xt3),nbins3+1);
binedges4 = linspace(min(xt4),max(xt4),nbins4+1);
bincntrs1 = 0.5*(binedges1(1:end-1) + binedges1(2:end));
bincntrs2 = 0.5*(binedges2(1:end-1) + binedges2(2:end));
bincntrs3 = 0.5*(binedges3(1:end-1) + binedges3(2:end));
bincntrs4 = 0.5*(binedges4(1:end-1) + binedges4(2:end));

%% determine tuning function
fval = cell(nbins1,nbins2,nbins3,nbins4);
for i=1:nbins1
    for j=1:nbins2
        for k=1:nbins3
            for m=nbins4
                indx = xt1>binedges1(i) & xt1<binedges1(i+1) & xt2>binedges2(j) & xt2<binedges2(j+1) & xt3>binedges3(k) & xt3<binedges3(k+1) & xt4>binedges4(m) & xt4<binedges4(m+1) ;
                fval{i,j,k,m} = yt(indx)/dt;
            end
        end
    end
end
x.mu = [bincntrs1 ; bincntrs2 ; bincntrs3 ; bincntrs4];
f.mu = cellfun(@mean,fval);