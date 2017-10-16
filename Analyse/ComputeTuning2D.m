function tuningstats = ComputeTuning2D(x1,x2,ts,tspk,timewindow,binedges)

ntrls = length(x1);
temporal_binwidth = median(diff(ts{1}));
%% concatenate data from different trials
x1t = []; x2t = []; yt = [];
for i=1:ntrls
    t_i = ts{i};
    x1_i = x1{i};
    x2_i = x2{i};
    y_i = hist(tspk{i},t_i); % rasterise spike times into bins --- 1001101000111
    % throw away histogram edges
    t_i = t_i(2:end-1);
    x1_i = x1_i(2:end-1);
    x2_i = x2_i(2:end-1);
    y_i = y_i(2:end-1);
    % select data within the analysis timewindow
    indx = t_i>timewindow(i,1) & t_i<timewindow(i,2);
    x1_i = x1_i(indx);
    x2_i = x2_i(indx);
    y_i = y_i(indx);
    x1t = [x1t(:); x1_i(:)];
    x2t = [x2t(:); x2_i(:)];
    yt = [yt(:); y_i(:)];
end

binedges_x1 = binedges(1,:);
binedges_x2 = binedges(2,:);
nbins_x1 = length(binedges_x1);
nbins_x2 = length(binedges_x2);
%% compute tuning curves
rate = cell(nbins_x1-1,nbins_x2-1);
stim1 = cell(nbins_x1-1,nbins_x2-1);
stim2 = cell(nbins_x1-1,nbins_x2-1);
stimgroup = cell(nbins_x1-1,nbins_x2-1);
for i=1:nbins_x1-1
    for j=1:nbins_x2-1
        indx_x1 = x1t>binedges_x1(i) & x1t<binedges_x1(i+1);
        indx_x2 = x2t>binedges_x2(j) & x2t<binedges_x2(j+1);
        indx = indx_x1 & indx_x2;
        rate{i,j} = yt(indx)/temporal_binwidth;
        stim1{i,j} = x1t(indx);
        stim2{i,j} = x2t(indx);
        stimgroup{i,j} = cell(length(rate{i,j}),1); stimgroup{i,j}(:) = {num2str((nbins_x1-1)*(i-1)+j)};
    end
end
tuningstats.tuning.rate.mu = cellfun(@mean,rate);
tuningstats.tuning.stim1.mu = cellfun(@mean,stim1);
tuningstats.tuning.stim2.mu = cellfun(@mean,stim2);
tuningstats.tuning.pval = anova1(cell2mat(rate(:)),vertcat(stimgroup{:}),'off');