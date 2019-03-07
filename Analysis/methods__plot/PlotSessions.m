%% function to plot neural population data from all sessions
function PlotSessions(sessions,unit_type,plot_type,prs)

%% gather all units of type unit_type from all sessions
units = struct.empty();
nsessions = length(sessions);
for i = 1:nsessions
    thisunits = sessions(i).units;
%     unitindx{i} = find(strcmp({thisunits.type},'singleunit'));
%     units = [units sessions(i).populations.(unit_type).stats.trialtype.all.models.log.units(unitindx{i})];
    units = [units sessions(i).populations.(unit_type).stats.trialtype.all.models.log.units];
end
nunits = length(units);

switch plot_type
    case 'GAM'
        %% population statistics
        bestmodelclass = [];
        nvars = length(units(1).Uncoupledmodel.class{1});
        for i = 1:nunits
            if ~isnan(units(i).Uncoupledmodel.bestmodel)
                bestmodelclass = [bestmodelclass ; units(i).Uncoupledmodel.class{units(i).Uncoupledmodel.bestmodel}];
            else
                bestmodelclass = [bestmodelclass ; false(1,nvars)];
            end
        end
        frac_tuned = sum(bestmodelclass)/nunits;
        figure; hold on;  set(gcf,'Position',[80 200 900 400]);
        errorbar(1:nvars, frac_tuned, sqrt(frac_tuned.*(1-frac_tuned)/nunits),'o','MarkerFace','b','CapSize',0);
        xlabel('Task variable'); ylabel('Fraction of tuned neurons');
        set(gca, 'XTick', 1:9, 'XTickLabel', units(i).Uncoupledmodel.xname, 'TickLabelInterpreter','none');
        axis([0 10 0 1]); hline([0:0.2:1]);
        %% tuning functions
        ncols = 8;
        nrows = ceil(max(frac_tuned)*nunits/ncols);
        for i=1:nvars
            figure; hold on; set(gcf,'Position',[80 200 900 1500]);
            count = 0;
            for j=1:nunits
                if bestmodelclass(j,i)
                    count = count + 1;
                    stim = units(j).Uncoupledmodel.x{i};
                    rate = units(j).Uncoupledmodel.marginaltunings{units(j).Uncoupledmodel.bestmodel}{i};
                    vartype = units(j).Uncoupledmodel.xtype{i};
                    subplot(nrows, ncols, count); hold on;
                    plot(stim, rate);
                    ylim = get(gca,'ylim'); ylim = [floor(ylim(1)) ceil(ylim(2))]; set(gca,'ylim',ylim);
                    xlim = get(gca,'xlim'); xlim = [floor(xlim(1)) ceil(xlim(2))]; set(gca,'xlim',xlim); 
                    set(gca,'YTick',ylim,'XTick',xlim,'Fontsize',10);
                    if strcmp(vartype,'event'), set(gca,'xlim',[-0.5 0.5],'XTick',[-0.5 0.5]); vline(0,'k'); end
                end
            end
%             if nunits>0, title(['Tuning to ' prs.varlookup(num2str(units(1).Uncoupledmodel.xname{i}))], 'Interpreter', 'none'); end
            if nunits>0, s = suptitle(strrep(['Tuning to ' prs.varlookup(num2str(units(1).Uncoupledmodel.xname{i}))],'_','\_')); 
                set(s,'FontSize',12,'FontWeight','Bold'); end
        end
        %% variance explained - coupled vs uncoupled
        count = 0;
        for j=1:nunits
            if ~isnan(units(j).Uncoupledmodel.bestmodel)
                count = count + 1;
                varexp_uncoupled(count) = mean(units(j).Uncoupledmodel.testFit{units(j).Uncoupledmodel.bestmodel}(:,2));
                varexp_coupled(count) = mean(units(j).Coupledmodel.testFit(:,2));
            else
                count = count + 1;
                varexp_uncoupled(count) = 0;
                varexp_coupled(count) = mean(units(j).Coupledmodel.testFit(:,2));
            end
        end
        figure; hold on;
        [F,X,FLO,FUP] = ecdf(varexp_uncoupled);
        shadedErrorBar(X,F,[F-FLO FUP-F],'lineprops','-b');
        [F,X,FLO,FUP] = ecdf(varexp_coupled);
        shadedErrorBar(X,F,[F-FLO FUP-F],'lineprops','-r');
        axis([0 1 0 1]); hline(0.5,'--k');
        set(gca,'Fontsize',10); xlabel('Variance explained'); ylabel('Cumulative fraction of neurons');
        h = findobj(gca); legend([h(2) h(6)], {'Uncoupled model', 'Coupled model'}, 'Location', 'SE','Fontsize', 10);
        %% coupled vs uncoupled
        figure; hold on;
        count = 0;
        for j=1:nunits
            if ~isnan(units(j).Uncoupledmodel.bestmodel)
                count = count + 1;
                LL_uncoupled(count) = mean(units(j).Uncoupledmodel.testFit{units(j).Uncoupledmodel.bestmodel}(:,3));
                LL_coupled(count) = mean(units(j).Coupledmodel.testFit(:,3));
                plot(LL_uncoupled, LL_coupled, '.k');
            end
        end
        plot(0.01:0.01:3,0.01:0.01:3,'--k'); set(gca,'XScale','log','YScale','log'); axis([0.01 3 0.01 3]);
        set(gca,'Fontsize',10); xlabel('(Uncoupled model), bits/spike'); ylabel('(Coupled model), bits/spike');
        title('Log Likelihood', 'Fontsize', 12);
        %% coupling (effect of distance)
end