function [rho,rho_smooth] = ComputeNoisecorr(Yt,xt,binrange,nbins)

[nt,nvars] = size(xt);
% identify state index of the ith timebin
for i = 1:nvars
    binedges = linspace(binrange{i}(1),binrange{i}(2),nbins{i}+1); xvals = 0.5*(binedges(1:end-1) + binedges(2:end));
    for j = 1:nt
        [~, indx(i,j)] = min(abs(xt(j,i)-xvals));
    end
end
indx = indx-1;

% convert n-variate indx to univariate indx
mask = repmat(max(cell2mat(nbins)).^(0:nvars-1)',[1 nt]); indx = sum(mask.*indx);

% baseline firing rate
uniqueindx = unique(indx);
for k=1:length(uniqueindx), Y0(k,:) = mean(Yt(indx == uniqueindx(k),:),1); Sigma0(k,:) = std(Yt(indx == uniqueindx(k),:),[],1); end

% z-score
Zt = zeros(size(Yt));
for j=1:nt, Zt(j,:) = (Yt(j,:) - Y0(uniqueindx == indx(j),:)); end
Zt_smooth = SmoothSpikes(Zt, 30);

% estimate correlation
rho = corr(Zt);
rho_smooth = corr(Zt_smooth);