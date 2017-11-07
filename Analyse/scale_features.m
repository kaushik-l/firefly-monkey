function [X_norm, mu, sigma] = scale_features(X)
%scale_features Scales the features in X 
%   scale_features(X) returns a normalized version of X where
%   the mean value of each feature is 0 and the standard deviation
%   is 1. This is often a good preprocessing step to do when
%   working with learning algorithms.

X_norm = X;
mu = zeros(1, size(X, 2));
sigma = zeros(1, size(X, 2));

m = size(X,1);
mu = repmat(mean(X),[m 1]);
sigma = repmat(std(X),[m 1]);
X_norm = (X-mu)./sigma;

