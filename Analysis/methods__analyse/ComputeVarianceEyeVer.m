function var_eyever = ComputeVarianceEyeVer(x,y,z,varx,vary,alignment)

Nt = max(cellfun(@(x) length(x),x));
switch alignment
    case 'normal'
        x = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],x,'UniformOutput',false));
        y = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],y,'UniformOutput',false));
        z = repmat(z,size(x));
        varx = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],varx,'UniformOutput',false));
        vary = cell2mat(cellfun(@(x) [x(:) ; nan(Nt - length(x),1)],vary,'UniformOutput',false));
    case 'reverse'
        x = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],x,'UniformOutput',false));
        y = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],y,'UniformOutput',false));
        z = repmat(z,size(x));
        varx = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],varx,'UniformOutput',false));
        vary = cell2mat(cellfun(@(x) [flipud(x(:)) ; nan(Nt - length(x),1)],vary,'UniformOutput',false));
end

dEyeVer__dx_sqrd = ((z.^2).*(x.^2))./(((x.^2 + y.^2 + z.^2).^2).*(x.^2 + y.^2));
dEyeVer__dy_sqrd = ((z.^2).*(y.^2))./(((x.^2 + y.^2 + z.^2).^2).*(x.^2 + y.^2));
var_eyever = (dEyeVer__dx_sqrd.*varx + dEyeVer__dy_sqrd.*vary)*(180/pi); % degrees