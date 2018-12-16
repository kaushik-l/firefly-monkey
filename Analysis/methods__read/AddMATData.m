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

%% add fly ON/OFF times to trials
for j=1:ntrls
    trials(j).t_end_mat = t_end_mat(j); % trial end times from matlab (compare with trials(j).t_end)
    trials(j).t_flyON = t_flyON(j);
    if t_flyOFF(j)>t_flyON(j)
        trials(j).t_flyOFF = t_flyOFF(j);
    else
        trials(j).t_flyOFF = nan; % trials in which firefly was ON throughout
    end
end

%% add fly status to tseries
% ts = tseries.ts; ns = length(ts);
% tseries.fly_sts = zeros(ns,1);
% for i=1:ntrls
%     if ~isnan(trials(i).t_flyOFF)
%         tseries.fly_sts(ts>trials(i).t_flyON & ts<trials(i).t_flyOFF)=1;
%     else
%         tseries.fly_sts(ts>trials(i).t_flyON & ts<trials(i).t_end)=1;
%     end
% end

%% add fly status to trials
for i=1:ntrls
    ts = trials(i).ts; ns = length(ts);
    trials(i).fly_sts = zeros(ns,1);
    t_on = trials(i).t_flyON - trials(i).t_beg;
    t_off = trials(i).t_flyOFF - trials(i).t_beg;
    if ~isnan(t_off)
        trials(i).fly_sts(ts>t_on & ts<t_off)=1;
    else
        trials(i).fly_sts(ts>t_on)=1;
    end
end