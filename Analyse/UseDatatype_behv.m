function UseDatatype_behv(data_behv,data_type)

%% tseries
% nseries = length(data_behv.tseries.smr);
% for i=1:nseries
%     tseries_temp = data_behv.tseries.smr(i);
%     flds = fields(tseries_temp);
%     nflds = length(flds);
%     for j=1:nflds
%         tseries_temp.(flds{j}) = eval([data_type '(tseries_temp.(flds{j}))']);
%     end
%     data_behv.tseries.smr(i) = tseries_temp;
% end

%% trials
ntrls = length(data_behv.trials);
for i=1:ntrls
    trial_temp = data_behv.trials(i);
    flds = fields(trial_temp.continuous);
    nflds = length(flds);
    for j=1:nflds
        trial_temp.continuous.(flds{j}) = eval([data_type '(trial_temp.continuous.(flds{j}))']);
    end
    data_behv.trials(i) = trial_temp;
end