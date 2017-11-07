function [theta, J, scalingprs] = GradientDescent(X, y, alpha, niters, featurescale, modelname)

if featurescale
    [X, scalingprs.mu, scalingprs.sigma] = scale_features(X);
else
    scalingprs = [];
end

m = size(y,1);
X = X; %[ones(m,1) X];
n = size(X,2);

if strcmp(modelname,'LR')
    theta = ones(n, 1);
    [theta, J] = linregress_graddescent(X, y, theta, alpha, niters);
end