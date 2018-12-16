function [rewardwin, pCorrect, pCorrect_shuffled_mu] = ...
    ComputeROCFirefly(X_fly,X_monk,maxrewardwin,npermutations)

%% initialise
rewardwin = linspace(0, maxrewardwin, 20); % total of 20 reward windows
pCorrect = zeros(1,length(rewardwin));
pCorrect_shuffled_mu = zeros(1,length(rewardwin));
ntrls = length(X_fly);
dist2fly = zeros(1,ntrls);

%% compute
for j=1:length(rewardwin)
    % unshuffled errors
    for i=1:ntrls
        dist2fly(i) = distance(X_fly(i,:), X_monk(i,:), 'polar');
    end
    % unshuffled accuracy
    pCorrect(j) = sum(dist2fly < rewardwin(j))/ntrls; % fraction of correct trials
    pCorrect_shuffled = zeros(1,npermutations);
    for k=1:npermutations
        indx = randperm(ntrls);
        X_monk2 = X_monk(indx,:);
        % shuffled errors
        dist2fly_shuffled = zeros(1,ntrls);
        for i=1:ntrls
            dist2fly_shuffled(i) = distance(X_fly(i,:), X_monk2(i,:), 'polar');
        end
        % shuffled accuracy
        pCorrect_shuffled(k) = sum(dist2fly_shuffled < rewardwin(j))/ntrls;
    end
    pCorrect_shuffled_mu(j) = mean(pCorrect_shuffled);
end