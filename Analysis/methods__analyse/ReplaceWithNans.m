function x = ReplaceWithNans(x, thresh, nanpadding)

indx = sum(abs(x)>thresh,2)>0;
indx_right = circshift(indx,nanpadding);
indx_left = circshift(indx,-nanpadding);
x(indx|indx_right|indx_left, :) = nan;