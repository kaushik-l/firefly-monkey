function err = errfun_heteroskdasticlinearmodel(prs,x_pred,x_true)

a = prs(1);
b = prs(2);
c = prs(3);
d = prs(4);

resid = abs(a*x_pred + b - x_true);
err = (resid - sqrt(c*(abs(x_pred).^d))).^2;
indx = err>(max(x_pred)/4)^2;
if numel(indx) < 0.2*numel(x_pred), err(indx) = []; end% remove outliers
err = sqrt(nanmean(err)) + nanmean(resid);