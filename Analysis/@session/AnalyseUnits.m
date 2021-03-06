%% analyse units
function AnalyseUnits(this,prs)
    nunits = length(this.units);
    %% the usual way (very slow)
%     for i=1:nunits
%         fprintf(['... Analysing unit ' num2str(i) ' :: ' this.units(i).type '\n']);
%         this.units(i).AnalyseUnit(this.behaviours,this.lfps,prs);
%     end
    %% use parallel fitting (way faster)
    units = this.units; 
    parfor i=1:nunits
        fprintf(['... Analysing unit ' num2str(i) '\n']);
        prs2 = prs; 
        prs2.channel_id = units(i).channel_id; prs2.electrode_type = units(i).electrode_type;
        stats(i) = AnalyseUnit(units(i).trials,...
            this.behaviours.trials,this.behaviours.stats,this.lfps,prs2);
    end
    for i=1:nunits, this.units(i).stats = stats(i); end
end