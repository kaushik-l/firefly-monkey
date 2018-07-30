classdef session < handle
    %%
    properties
        monk_id
        sess_id
        coord
        behaviours = behaviour.empty();                                     % trial
        units = unit.empty();                                               % single/multiunit
        lfps = lfp.empty();                                                 % lfp
        populations = population.empty();                                   % population
    end
    %%
    methods
        %% class constructor
        function this = session(monk_id,sess_id,coord)
            this.monk_id = monk_id;
            this.sess_id = sess_id;
            this.coord = coord;
        end
        %% add behaviour
        function AddBehaviours(this,prs)
            cd(prs.filepath_behv);
            this.behaviours = behaviour(prs.comments);
            this.behaviours.AddTrials(prs);
            this.behaviours.AnalyseBehaviour(prs);
            this.behaviours.UseDatatype('single');
        end
        %% add units
        function AddUnits(this,prs)
            cd(prs.filepath_neur);
            file_ead=dir('_ead.plx');
            file_nev=dir('*.nev');
            if ~isempty(file_ead) % data recorded using Plexon
                fprintf(['... reading ' file_ead.name '\n']);
                t_events = GetEvents_plx(file_ead.name);
                file_plx=dir('*_spk.plx');
                fprintf(['... reading ' file_plx.name '\n']);
                for j=1:prs.maxchannels
                    fprintf(['...... channel ' num2str(j) '/' num2str(prs.maxchannels) '\n']);
                    smua = GetUnits_plx(file_plx.name,prs.units,j); % smua = singleunits + multiunits
                    %fetch multiunit
                    this.units(end+1) = unit('multiunit');
                    this.units(end).AddTrials(smua(1).tspk,t_events,this.behaviours,prs);
                    %fetch units
                    if length(smua)>1
                        for k=2:length(smua)
                            this.units(end+1) = unit('singleunit');
                            this.units(end).AddTrials(smua(k).tspk,t_events,this.behaviours,prs);
                        end
                    end
                end
            elseif ~isempty(file_nev) % data recorded using Cereplex
                [sua, mua] = GetUnits_phy('spike_times.npy', 'spike_clusters.npy', 'cluster_groups.csv'); %, 'cluster_location.xls'); % requires npy-matlab package: https://github.com/kwikteam/npy-matlab
                fprintf(['... reading events from ' file_nev.name '\n']);
                [events_nev,prs] = GetEvents_nev(file_nev.name,prs); % requires package from Blackrock Microsystems: https://github.com/BlackrockMicrosystems/NPMK 
                if length(this.behaviours.trials)==length(events_nev.t_end)
                    if ~isempty(sua)
                        for i=1:length(sua)
                            %fetch singleunit
                            this.units(end+1) = unit('singleunit');
                            this.units(end).AddTrials(sua(i).tspk,events_nev,this.behaviours,prs);
                        end
                    end
                    if ~isempty(mua)
                        for i=1:length(mua)
                            %fetch multiunit
                            this.units(end+1) = unit('multiunit');
                            this.units(end).AddTrials(mua(i).tspk,events_nev,this.behaviours,prs);
                        end
                    end
                else
                    fprintf('Cannot segment spikes: Trial counts in smr and nev files do not match \n');
                    fprintf(['Trial end events: NEV file - ' num2str(length(events_nev.t_end)) ...
                        ' , SMR file - ' num2str(length(this.behaviours.trials)) '\n']);
                    fprintf('Debug and try again! \n');
                end
            else
                fprintf('No neural data files in the specified path \n');
            end
        end
        %% analyse units
        function AnalyseUnits(this,prs)
            nunits = length(this.units);
            for i=1:nunits
                fprintf(['... Analysing unit ' num2str(i) ' :: ' this.units(i).type '\n']);
                this.units(i).AnalyseUnit(this.behaviours,prs);
            end
        end
        %% add lfps
        function AddLfps(this,prs)
            cd(prs.filepath_neur);
            file_ead=dir('_ead.plx');
            file_ns1=dir('*.ns1');
            if ~isempty(file_ead)
                fprintf(['... reading events from ' file_ead.name '\n']);
                t_events = GetEvents_plx(file_ead.name);
                for j=1:prs.maxchannels
                end
            elseif ~isempty(file_ns1)
                file_nev=dir('*.nev');
                fprintf(['... reading events from ' file_nev.name '\n']);
                [events_nev,prs] = GetEvents_nev(file_nev.name,prs); % requires package from Blackrock Microsystems: https://github.com/BlackrockMicrosystems/NPMK 
                if length(this.behaviours.trials)==length(events_nev.t_end)
                    NS1 = openNSx(['/' file_ns1.name],'report','read', 'uV');
                    if NS1.MetaTags.ChannelCount ~= prs.maxchannels, warning('Channel count in the file not equal to prs.maxchannels \n'); end
                    for j=1:prs.maxchannels
                        channel_id = NS1.MetaTags.ChannelID(j);
                        fprintf(['Segmenting LFP :: channel ' num2str(channel_id) '\n']);
                        this.lfps(end+1) = lfp(channel_id);
                        this.lfps(end).AddTrials(NS1.Data(j,:),NS1.MetaTags.SamplingFreq,events_nev,this.behaviours,prs);
                    end
                else
                    fprintf('Cannot segment LFP: Trial counts in smr and nev files do not match \n');
                    fprintf(['Trial end events: NEV file - ' num2str(length(events_nev.t_end)) ...
                        ' , SMR file - ' num2str(length(this.behaviours.trials)) '\n']);
                    fprintf('Debug and try again! \n');
                end
            else
                fprintf('No neural data files in the specified path \n');
            end
        end
        %% analyse lfps
        function AnalyseLfps(this,prs)
            nlfps = length(this.lfps);
            for i=1:nlfps
                fprintf(['... Analysing lfp ' num2str(i) ' :: channel ' num2str(this.lfps(i).channel_id) '\n']);
                this.lfps(i).AnalyseLfp(this.behaviours,prs);
            end
        end
        %% add populations
        function AddPopulation(this,unittype,prs)
            this.populations(end+1) = population();
            if ~strcmp(unittype,'units')
                this.populations.AnalysePopulation(this.units(strcmp({this.units.type},unittype)),unittype,this.behaviours.trials,this.behaviours.stats,prs);
            else
                this.populations.AnalysePopulation(this.units,unittype,this.behaviours,prs);
            end
        end
        %% plot behaviour
        function PlotBehaviour(this,plot_type,prs)
            behv = this.behaviours;
            PlotBehaviour(behv,plot_type,prs);
        end
        %% plot units
        function PlotUnits(this,unit_id,plot_type,prs)
            behv = this.behaviours;
            if length(unit_id)~=1
                error('unit id should be an non-negative integer');
            end
            if unit_id~=0
                unit = this.units(unit_id);
                figure; hold on; suptitle(['m' num2str(this.monk_id) 's' num2str(this.sess_id) 'u' num2str(unit_id)]);
                PlotUnit(behv,unit,plot_type,prs);        % plot data from one specific unit
            else
                PlotUnits(behv,this.units,plot_type,prs); % plot data from all units
            end
        end
    end
end