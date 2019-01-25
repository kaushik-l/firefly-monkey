function prcnt_reward = get_rewarded_trl(experiments,sess);

% get the percentage of rewarded trials for each session

indx = experiments.sessions(sess).behaviours.stats.trialtype.reward.trlindx; 
prcnt_reward = (sum(indx)/length(indx))*100; 

end 


