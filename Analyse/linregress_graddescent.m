function [theta, J_history] = linregress_graddescent(X, y, theta, alpha, niters)
%grad_descent Performs gradient descent to learn theta
%   theta = grad_descent(x, y, theta, alpha, num_iters) updates theta by
%   taking niters gradient steps with learning rate alpha

% Initialize
m = length(y); % number of training examples
n = length(theta); % number of features
J_history = zeros(niters, 1);

for iter = 1:niters
    fprintf(['iteration # ' num2str(iter) '\n'])
    theta = theta - (alpha/m)*sum(repmat((X*theta - y),[1 n]).*X)';
    J_history(iter) = linregress_cost(X, y, theta);
end