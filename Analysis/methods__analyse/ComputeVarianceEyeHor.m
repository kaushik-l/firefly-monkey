function var_eyehor = ComputeVarianceEyeHor(x,y,z,varx,vary,alignment)

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

dEyeHor__dx_sqrd = ((y.^2 + z.^2))./(((x.^2 + y.^2 + z.^2).^2));
dEyeHor__dy_sqrd = ((y.^2).*(x.^2))./(((x.^2 + y.^2 + z.^2).^2).*(y.^2 + z.^2));
var_eyehor = (dEyeHor__dx_sqrd.*varx + dEyeHor__dy_sqrd.*vary)*(180/pi);