function DrawPhaseArrows(loc,electrode_id_sorted)

nlocs = size(loc,1); xloc = loc(:,1); yloc = loc(:,2);
% Xshifts = [0 1 1 1]; Yshifts = [1 1 0 -1]; % full diagram (incl. diagonals)
% Xoffset = [0 0.25 0.25 0.25]; Yoffset = [0.25 0.25 0 -0.25];
Xshifts = [0 1]; Yshifts = [1 0]; % only horizontal and vertical connections
Xoffset = [0 0.45]; Yoffset = [0.45 0];
for i=1:nlocs
    xloc1 = xloc(i); yloc1 = yloc(i);
    for j=1:length(Xshifts)
        xloc2 = xloc1 + Xshifts(j); yloc2 = yloc1 + Yshifts(j);
        k = find((xloc==xloc2) & (yloc==yloc2), 1);
        if ~isempty(k) % valid location to draw an arrow to
            if find(electrode_id_sorted==i) < find(electrode_id_sorted==k) % draw arrow from i to k
                ah = annotation('arrow','headstyle','deltoid','HeadLength',5,'HeadWidth',5);
                set(ah,'parent',gca);
                set(ah,'position',[xloc1+Xoffset(j) yloc1+Yoffset(j) 0.1*(xloc2-xloc1) 0.1*(yloc2-yloc1)]);
            else % draw arrow from k to i
                ah = annotation('arrow','headstyle','deltoid','HeadLength',5,'HeadWidth',5);
                set(ah,'parent',gca);
                set(ah,'position',[xloc2-Xoffset(j) yloc2-Yoffset(j) 0.1*(xloc1-xloc2) 0.1*(yloc1-yloc2)]);
            end
        end
    end
end