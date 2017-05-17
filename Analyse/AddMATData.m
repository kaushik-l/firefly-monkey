function trials = AddMATData(file,trials)

MATData = load(file);

%% matlab data might have an extra trial (either at the beginning or at the end)
%% so choose the subset that matches with smr
ntrls = length(trials);
ntrls_mat = length(MATData.events.t_end);
z = ntrls_mat - ntrls;
for i=0:z
    t_end_smr = [trials.t_end]; t_end_smr = t_end_smr(1:ntrls);
    t_end_mat = MATData.events.t_end; t_end_mat = t_end_mat(1+i:ntrls+i);
    P(i+1,:) = polyfit(t_end_smr,t_end_mat,1);
    t_end_mat = t_end_mat - P(i+1,2);
    err(i+1) = sum(abs(t_end_mat - t_end_smr));
end
[~,indx] = min(err); i=indx-1; offset = P(i+1,2);
t_end_mat = MATData.events.t_end; t_end_mat = t_end_mat(1+i:ntrls+i) - offset;
t_flyON = MATData.events.t_flyON; t_flyON = t_flyON(1+i:ntrls+i) -  offset;
t_flyOFF = MATData.events.t_flyOFF; t_flyOFF = t_flyOFF(1+i:ntrls+i) - offset;

%% add fly ON/OFF times
for j=1:ntrls
    trials(j).t_end_mat = t_end_mat(j); % trial end times from matlab (compare with trials(j).t_end)
    trials(j).t_flyON = t_flyON(j);
    if t_flyOFF(j)>t_flyON(j)
        trials(j).t_flyOFF = t_flyOFF(j);
    else
        trials(j).t_flyOFF = nan; % trials in which firefly was ON throughout
    end
end