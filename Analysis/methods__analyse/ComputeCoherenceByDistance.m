function [coher,phase,dists] = ComputeCoherenceByDistance(coherMat,phaseMat,electrode_ids,electrode_type)

nfreq = size(coherMat,1);
switch electrode_type
    case 'linearprobe16'
        [xloc,yloc,zloc] = map_linearprobe([],electrode_type);
        % compute pairwise distance
        distMat = permute(repmat(zloc(:) - zloc(:)',[1 1 nfreq]),[3 1 2]);
        distMat = (coherMat>0).*distMat; % retain only lower triangle
        distMat = squeeze(distMat(1,:,:));
        dists = unique(distMat(:));
        for i=1:numel(dists)
            %             [rowindx,colindx] = ind2sub(size(distMat),find(distMat == dists(i+1)));
            coher(:,i) = median(coherMat(:,distMat == dists(i)),2);
            phase(:,i) = median(phaseMat(:,distMat == dists(i)),2);
        end
    case 'linearprobe24'
        [xloc,yloc,zloc] = map_linearprobe([],electrode_type);
        % compute pairwise distance
        distMat = permute(repmat(zloc(:) - zloc(:)',[1 1 nfreq]),[3 1 2]);
        distMat = (coherMat>0).*distMat; % retain only lower triangle
        distMat = squeeze(distMat(1,:,:));
        dists = unique(distMat(:));
        for i=1:numel(dists)
            %             [rowindx,colindx] = ind2sub(size(distMat),find(distMat == dists(i+1)));
            coher(:,i) = median(coherMat(:,distMat == dists(i)),2);
            phase(:,i) = median(phaseMat(:,distMat == dists(i)),2);
        end
    case 'linearprobe32'
        [xloc,yloc,zloc] = map_linearprobe([],electrode_type);
        % compute pairwise distance
        distMat = permute(repmat(zloc(:) - zloc(:)',[1 1 nfreq]),[3 1 2]);
        distMat = (coherMat>0).*distMat; % retain only lower triangle
        distMat = squeeze(distMat(1,:,:));
        dists = unique(distMat(:));
        for i=1:numel(dists)
            %             [rowindx,colindx] = ind2sub(size(distMat),find(distMat == dists(i+1)));
            coher(:,i) = median(coherMat(:,distMat == dists(i)),2);
            phase(:,i) = median(phaseMat(:,distMat == dists(i)),2);
        end
    case 'utah96'
        [xloc,yloc] = map_utaharray([],electrode_type);
        [~,electrode_id] = MapChannel2Electrode(electrode_type);
<<<<<<< HEAD
         % compute pairwise distance
         xdistMat = permute(repmat(xloc(electrode_id) - xloc(electrode_id)',[1 1 nfreq]),[3 1 2]);
         ydistMat = permute(repmat(yloc(electrode_id) - yloc(electrode_id)',[1 1 nfreq]),[3 1 2]);
         distMat = sqrt(xdistMat.^2 + ydistMat.^2);
         distMat = (coherMat>0).*distMat; % retain only lower triangle
         distMat = squeeze(distMat(1,:,:));
         dists = unique(distMat(:));
         for i=1:numel(dists)
             coher(:,i) = median(coherMat(:,distMat == dists(i)),2);
             phase(:,i) = median(phaseMat(:,distMat == dists(i)),2);
         end
    case 'utah2x48'
        [xloc,yloc] = map_utaharray([],electrode_type);
        [~,electrode_id] = MapChannel2Electrode(electrode_type);
         % compute pairwise distance
         xdistMat = permute(repmat(xloc(electrode_id) - xloc(electrode_id)',[1 1 nfreq]),[3 1 2]);
         ydistMat = permute(repmat(yloc(electrode_id) - yloc(electrode_id)',[1 1 nfreq]),[3 1 2]);
         distMat = sqrt(xdistMat.^2 + ydistMat.^2);
         distMat = (coherMat>0).*distMat; % retain only lower triangle
         distMat = squeeze(distMat(1,:,:));
         dists = unique(distMat(:));
         for i=1:numel(dists)
             coher(:,i) = median(coherMat(:,distMat == dists(i)),2);
             phase(:,i) = median(phaseMat(:,distMat == dists(i)),2);
         end
=======
        % compute pairwise distance
        xdistMat = permute(repmat(xloc(electrode_id) - xloc(electrode_id)',[1 1 nfreq]),[3 1 2]);
        ydistMat = permute(repmat(yloc(electrode_id) - yloc(electrode_id)',[1 1 nfreq]),[3 1 2]);
        distMat = sqrt(xdistMat.^2 + ydistMat.^2);
        distMat = (coherMat>0).*distMat; % retain only lower triangle
        distMat = squeeze(distMat(1,:,:));
        dists = unique(distMat(:));
        for i=1:numel(dists)
            coher(:,i) = median(coherMat(:,distMat == dists(i)),2);
            phase(:,i) = median(phaseMat(:,distMat == dists(i)),2);
        end
        
    case 'utah2x48'
        [xloc,yloc] = map_utaharray([],electrode_type);
        [~,electrode_id] = MapChannel2Electrode(electrode_type);
        % compute pairwise distance
        xdistMat = permute(repmat(xloc(electrode_id) - xloc(electrode_id)',[1 1 nfreq]),[3 1 2]);
        ydistMat = permute(repmat(yloc(electrode_id) - yloc(electrode_id)',[1 1 nfreq]),[3 1 2]);
        distMat = sqrt(xdistMat.^2 + ydistMat.^2);
        distMat = (coherMat>0).*distMat; % retain only lower triangle
        distMat = squeeze(distMat(1,:,:));
        dists = unique(distMat(:));
        for i=1:numel(dists)
            coher(:,i) = median(coherMat(:,distMat == dists(i)),2);
            phase(:,i) = median(phaseMat(:,distMat == dists(i)),2);
        end
>>>>>>> dce27c750c6b5028c5b74b9fbb0599e072f6c5b1
end

