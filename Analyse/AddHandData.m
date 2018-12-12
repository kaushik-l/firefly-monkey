function AddHandData(file,prs)

my_features = prs.hand_features;
vals = csvread(file,3,0);
[nFrames,nTags] = size(vals);
fid = fopen(file);
title = textscan(fid,'%s',3);
features = textscan(title{:}{2},'%s',nTags,'delimiter',','); features = {features{1}{:}};
headers = textscan(title{:}{3},'%s',nTags,'delimiter',','); headers = {headers{1}{:}};
fclose(fid);

my_coords = {'x','y'};
pos_hand = nan(numel(my_features),numel(my_coords),nFrames);
for i=1:numel(my_features)
    indx = vals(:,strcmp(features,my_features{i}) & strcmp(headers,'likelihood')) > 0.99;
    for j=1:numel(my_coords)
        pos_hand(i,j,indx) = vals(indx,strcmp(features,my_features{i}) & strcmp(headers,my_coords{j}));
    end
end

figure; plot(squeeze(pos_hand(1:4,1,:))',squeeze(pos_hand(1:4,2,:))','.','MarkerSize',0.25); 
axis([0 720 0 480]); set(gca,'YDir','reverse');

fx = (squeeze(pos_hand(1,1,:)) - nanmean(squeeze(pos_hand(1,1,:)))); dfx = diff(fx);
fy = (squeeze(pos_hand(1,2,:)) - nanmean(squeeze(pos_hand(1,2,:)))); dfy = diff(fy);
df = sqrt(dfx.^2 + dfy.^2);
[~ , locs] = findpeaks(-dfy,'Minpeakprominence',50);
figure; hold on; m = 60;
for i=1:numel(locs)
    plot(squeeze(pos_hand(4,1,locs(i):locs(i)+m)),squeeze(pos_hand(4,2,locs(i):locs(i)+m)),'r');
%     plot(squeeze(pos_hand(2,1,locs(i):locs(i)+m)),squeeze(pos_hand(2,2,locs(i):locs(i)+m)),'b');
%     plot(squeeze(pos_hand(3,1,locs(i):locs(i)+m)),squeeze(pos_hand(3,2,locs(i):locs(i)+m)),'c');
%     plot(squeeze(pos_hand(4,1,locs(i):locs(i)+m)),squeeze(pos_hand(4,2,locs(i):locs(i)+m)),'g');
    if ~any(isnan(squeeze(pos_hand(1,1,locs(i):locs(i)+m))))
        plot(squeeze(pos_hand(4,1,locs(i))),squeeze(pos_hand(4,2,locs(i))),'.k');
%         plot(squeeze(pos_hand(2,1,locs(i))),squeeze(pos_hand(2,2,locs(i))),'.k');
%         plot(squeeze(pos_hand(3,1,locs(i))),squeeze(pos_hand(3,2,locs(i))),'.k');
%         plot(squeeze(pos_hand(4,1,locs(i))),squeeze(pos_hand(4,2,locs(i))),'.k');
    end
end
set(gca,'YDir','reverse');