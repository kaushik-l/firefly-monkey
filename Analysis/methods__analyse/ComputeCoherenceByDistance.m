function [coher,phase,dists] = ComputeCoherenceByDistance(coherMat,phaseMat,electrode_ids,electrode_type)

nfreq = size(coherMat,1);
switch electrode_type
    case 'linearprobe16'
        [xloc,yloc,zloc] = map_linearprobe([],electrode_type);
    case 'linearprobe24'
        [xloc,yloc,zloc] = map_linearprobe([],electrode_type);
    case 'linearprobe32'
        [xloc,yloc,zloc] = map_linearprobe([],electrode_type);
end

% compute pairwise distance
distMat = permute(repmat(zloc(:) - zloc(:)',[1 1 nfreq]),[3 1 2]);
distMat = (coherMat>0).*distMat; % retain only lower triangle
distMat = squeeze(distMat(1,:,:));
dists = unique(distMat(:));
for i=1:numel(dists)
    %             [rowindx,colindx] = ind2sub(size(distMat),find(distMat == dists(i+1)));
    coher(:,i) = median(coherMat(:,distMat == dists(i)),2);
    phase(:,i) = median(coherMat(:,distMat == dists(i)),2);
end