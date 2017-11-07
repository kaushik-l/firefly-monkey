function J = linregress_cost(X, y, theta)
%linregress_cost Compute cost for linear regression with multiple variables
%   J = linregress_cost(X, y, theta) computes the cost of using theta as the
%   parameter for linear regression to fit the data points in X and y

% Initialize
m = length(y); % number of training examples
J = sum((X*theta - y).^2)/(2*m);