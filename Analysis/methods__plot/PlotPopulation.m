function PlotPopulation(behv,units,plot_type,prs)

%% parameters
binwidth_abs = prs.binwidth_abs;
binwidth_warp = prs.binwidth_warp;
trlkrnlwidth = prs.trlkrnlwidth;

correct = behv.stats.trialtype.reward(1).trlindx;
incorrect = behv.stats.trialtype.reward(2).trlindx;
crazy = ~(behv.stats.trialtype.all.trlindx);
indx_all = ~crazy;

% behavioural data
behv_all = behv.trials(~crazy); ntrls_all = length(behv_all);
behv_correct = behv.trials(correct); ntrls_correct = length(behv_correct);
behv_incorrect = behv.trials(incorrect); ntrls_incorrect = length(behv_incorrect);

%%
switch plot_type
    case 'GAM'
        units = units.stats.trialtype.all.models.log.units; nunits = length(units);
        nvars = 8; cmap = jet(nvars); cmap(5,2) = 0.25;
        file_name_root='Fig_';
        LL_uncoupled = []; LL_coupled = []; Jij = zeros(nunits,nunits);
        for i=1:nunits
            uncoupledmodel = units(i).Uncoupledmodel;
            coupledmodel = units(i).Coupledmodel;
            bestmodel = uncoupledmodel.bestmodel;
            Jij(i,[1:i-1 i+1:end]) = coupledmodel.marginaltunings{end};
            if ~isnan(bestmodel)
                LL_uncoupled = [LL_uncoupled nanmean(units(i).Uncoupledmodel.testFit{bestmodel}(:,3))];
                LL_coupled = [LL_coupled nanmean(units(i).Coupledmodel.testFit(:,3))];
                varindx = find(uncoupledmodel.class{bestmodel});
                %% tuning of this unit
                figure(i); hold on; %set(gcf,'Position',[85 -276 700 1000]);
                ymin = inf; ymax = -inf;
                for j=varindx
                    subplot(2,4,j); hold on;
                    plot(uncoupledmodel.x{j},uncoupledmodel.marginaltunings{bestmodel}{j},'Color',cmap(j,:));
                    ymin = min(ymin,min(uncoupledmodel.marginaltunings{bestmodel}{j}));
                    ymax = max(ymax,max(uncoupledmodel.marginaltunings{bestmodel}{j}));
                end
                % match y-axes of all subplots
                for j=varindx
                    subplot(2,4,j); set(gca,'Ylim',[ymin ymax]);
                    if j==6 || j==8
                        set(gca,'Xlim',[uncoupledmodel.x{j}(1) uncoupledmodel.x{j}(end)],'XTick',[uncoupledmodel.x{j}(1) uncoupledmodel.x{j}(end)],'XTicklabel',[0 0.6]);
                    elseif j>4
                        set(gca,'Xlim',[uncoupledmodel.x{j}(1) uncoupledmodel.x{j}(end)],'XTick',[-0.3 0 0.3]); vline(0,'k');
                    end
                end
                %% tuning of all units
                for k=1:nvars
                    figure(50+k); hold on; %set(gcf,'Position',[85 -276 700 1000]);
                    k_index = 50 + k;
                    if any(varindx==k)
                        subplot(6,6,i); hold on;
                        plot(uncoupledmodel.x{k},uncoupledmodel.marginaltunings{bestmodel}{k},'Color',cmap(k,:));
                        if k==6 || k==8
                            set(gca,'Xlim',[uncoupledmodel.x{k}(1) uncoupledmodel.x{k}(end)],'XTick',[uncoupledmodel.x{k}(1) uncoupledmodel.x{k}(end)],'XTicklabel',[0 0.6]);
                        elseif k>4
                            set(gca,'Xlim',[uncoupledmodel.x{k}(1) uncoupledmodel.x{k}(end)],'XTick',[-0.3 0 0.3]); vline(0,'k');
                        end
                    end
                    file_name=[file_name_root num2str(k_index)];
%                     saveas(gcf, file_name, 'epsc')
                end
                file_name=[file_name_root num2str(i)];
%                 saveas(gcf, file_name, 'epsc')
            end
        end
        figure; errorbar([1 2],[mean(LL_uncoupled) mean(LL_coupled)],[std(LL_uncoupled) std(LL_coupled)]/sqrt(nunits)); xlim([0.5 2.5]);
        figure; imagesc(Jij./repmat(max(Jij,[],2),[1 nunits]));
end