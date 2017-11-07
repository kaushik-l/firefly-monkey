su = []; mu = []; dt = 0.012;

for i=7:9, su = [su experiments.sessions(i).singleunits]; end
for i=7:9, mu = [mu experiments.sessions(i).multiunits]; end

%% best models - summary
k=1;
for i=1:length(su)
    best_model(k) = su(i).stats.trialtype.all.LNmodels.selected_model;
    k = k+1;
end
for i=1:length(mu)
    best_model(k) = mu(i).stats.trialtype.all.LNmodels.selected_model;
    k = k+1;
end
for i=1:7
    n(i) = sum(best_model==i);
end
n(8) = sum(isnan(best_model));

%% preferred stimulus - summary
k=1;
for i=1:length(su)
    best_model = su(i).stats.trialtype.all.LNmodels.selected_model;
    LNmodels = su(i).stats.trialtype.all.LNmodels;
    param = [];
    if ~isnan(LNmodels.selected_model)
        if LNmodels.selected_model==1
            % pull out the parameter values
            param(1,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            param(2,:) = LNmodels.param{LNmodels.selected_model}(11:20);
            param(3,:) = LNmodels.param{LNmodels.selected_model}(21:30);
            % compute the scale factors
            scale_factor_1 = mean(exp(param(2,:)))*mean(exp(param(3,:)))/dt;
            scale_factor_2 = mean(exp(param(1,:)))*mean(exp(param(3,:)))/dt;
            scale_factor_3 = mean(exp(param(1,:)))*mean(exp(param(2,:)))/dt;
            % compute the model-derived response profiles
            r1 = scale_factor_1*exp(param(1,:));
            r2 = scale_factor_2*exp(param(2,:));
            r3 = scale_factor_3*exp(param(3,:));
        elseif LNmodels.selected_model==2
            % pull out the parameter values
            param(1,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            param(2,:) = LNmodels.param{LNmodels.selected_model}(11:20);
            % compute the scale factors
            scale_factor_1 = mean(exp(param(2,:)))/dt;
            scale_factor_2 = mean(exp(param(1,:)))/dt;
            % compute the model-derived response profiles
            r1 = scale_factor_1*exp(param(1,:));
            r2 = scale_factor_2*exp(param(2,:));
            r3 = nan(1,10);
        elseif LNmodels.selected_model==3
            % pull out the parameter values
            param(1,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            param(3,:) = LNmodels.param{LNmodels.selected_model}(11:20);
            % compute the scale factors
            scale_factor_1 = mean(exp(param(3,:)))/dt;
            scale_factor_3 = mean(exp(param(1,:)))/dt;
            % compute the model-derived response profiles
            r1 = scale_factor_1*exp(param(1,:));
            r2 = nan(1,10);
            r3 = scale_factor_3*exp(param(3,:));
        elseif LNmodels.selected_model==4
            % pull out the parameter values
            param(2,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            param(3,:) = LNmodels.param{LNmodels.selected_model}(11:20);
            % compute the scale factors
            scale_factor_2 = mean(exp(param(3,:)))/dt;
            scale_factor_3 = mean(exp(param(2,:)))/dt;
            % compute the model-derived response profiles
            r1 = nan(1,10);
            r2 = scale_factor_2*exp(param(2,:));
            r3 = scale_factor_3*exp(param(3,:));
        elseif LNmodels.selected_model==5
            % pull out the parameter values
            param(1,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            % compute the scale factors
            scale_factor_1 = 1/dt;
            % compute the model-derived response profiles
            r1 = scale_factor_1*exp(param(1,:));
            r2 = nan(1,10);
            r3 = nan(1,10);
        elseif LNmodels.selected_model==6
            % pull out the parameter values
            param(2,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            % compute the scale factors
            scale_factor_2 = 1/dt;
            % compute the model-derived response profiles
            r1 = nan(1,10);
            r2 = scale_factor_2*exp(param(2,:));
            r3 = nan(1,10);
        elseif LNmodels.selected_model==7
            % pull out the parameter values
            param(3,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            % compute the scale factors
            scale_factor_3 = 1/dt;
            % compute the model-derived response profiles
            r1 = nan(1,10);
            r2 = nan(1,10);
            r3 = scale_factor_3*exp(param(3,:));
        end
    end
    if ~all(isnan(r1)), [~,indx] = max(r1); v_best(k) = indx;  end;
    if ~all(isnan(r2)), [~,indx] = max(r2); w_best(k) = indx; end;
    if ~all(isnan(r3)), [~,indx] = max(r3); d_best(k) = indx; end;
    k = k+1;
end

for i=1:length(mu)
    best_model = mu(i).stats.trialtype.all.LNmodels.selected_model;
    LNmodels = mu(i).stats.trialtype.all.LNmodels;
    param = [];
    if ~isnan(LNmodels.selected_model)
        if LNmodels.selected_model==1
            % pull out the parameter values
            param(1,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            param(2,:) = LNmodels.param{LNmodels.selected_model}(11:20);
            param(3,:) = LNmodels.param{LNmodels.selected_model}(21:30);
            % compute the scale factors
            scale_factor_1 = mean(exp(param(2,:)))*mean(exp(param(3,:)))/dt;
            scale_factor_2 = mean(exp(param(1,:)))*mean(exp(param(3,:)))/dt;
            scale_factor_3 = mean(exp(param(1,:)))*mean(exp(param(2,:)))/dt;
            % compute the model-derived response profiles
            r1 = scale_factor_1*exp(param(1,:));
            r2 = scale_factor_2*exp(param(2,:));
            r3 = scale_factor_3*exp(param(3,:));
        elseif LNmodels.selected_model==2
            % pull out the parameter values
            param(1,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            param(2,:) = LNmodels.param{LNmodels.selected_model}(11:20);
            % compute the scale factors
            scale_factor_1 = mean(exp(param(2,:)))/dt;
            scale_factor_2 = mean(exp(param(1,:)))/dt;
            % compute the model-derived response profiles
            r1 = scale_factor_1*exp(param(1,:));
            r2 = scale_factor_2*exp(param(2,:));
            r3 = nan(1,10);
        elseif LNmodels.selected_model==3
            % pull out the parameter values
            param(1,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            param(3,:) = LNmodels.param{LNmodels.selected_model}(11:20);
            % compute the scale factors
            scale_factor_1 = mean(exp(param(3,:)))/dt;
            scale_factor_3 = mean(exp(param(1,:)))/dt;
            % compute the model-derived response profiles
            r1 = scale_factor_1*exp(param(1,:));
            r2 = nan(1,10);
            r3 = scale_factor_3*exp(param(3,:));
        elseif LNmodels.selected_model==4
            % pull out the parameter values
            param(2,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            param(3,:) = LNmodels.param{LNmodels.selected_model}(11:20);
            % compute the scale factors
            scale_factor_2 = mean(exp(param(3,:)))/dt;
            scale_factor_3 = mean(exp(param(2,:)))/dt;
            % compute the model-derived response profiles
            r1 = nan(1,10);
            r2 = scale_factor_2*exp(param(2,:));
            r3 = scale_factor_3*exp(param(3,:));
        elseif LNmodels.selected_model==5
            % pull out the parameter values
            param(1,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            % compute the scale factors
            scale_factor_1 = 1/dt;
            % compute the model-derived response profiles
            r1 = scale_factor_1*exp(param(1,:));
            r2 = nan(1,10);
            r3 = nan(1,10);
        elseif LNmodels.selected_model==6
            % pull out the parameter values
            param(2,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            % compute the scale factors
            scale_factor_2 = 1/dt;
            % compute the model-derived response profiles
            r1 = nan(1,10);
            r2 = scale_factor_2*exp(param(2,:));
            r3 = nan(1,10);
        elseif LNmodels.selected_model==7
            % pull out the parameter values
            param(3,:) = LNmodels.param{LNmodels.selected_model}(1:10);
            % compute the scale factors
            scale_factor_3 = 1/dt;
            % compute the model-derived response profiles
            r1 = nan(1,10);
            r2 = nan(1,10);
            r3 = scale_factor_3*exp(param(3,:));
        end
    end
    if ~all(isnan(r1)), [~,indx] = max(r1); v_best(k) = indx; end;
    if ~all(isnan(r2)), [~,indx] = max(r2); w_best(k) = indx;end; 
    if ~all(isnan(r3)), [~,indx] = max(r3);d_best(k) = indx; end; 
    k = k+1;
end

figure; hold on;
for i=1:length(v_best)
    if v_best(i)~=0 && w_best(i)~=0
        plot(v_best(i),w_best(i),'.k');
    end
end

figure; hold on;
for i=1:length(v_best)
    if v_best(i)~=0 && w_best(i)~=0
        plot(v_best(i),w_best(i),'.k');
    end
end