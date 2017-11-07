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
            file_ead=dir('*.plx');
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
                [sua, mua] = GetUnits_phy('spike_times.npy', 'spike_clusters.npy', 'cluster_groups.csv'); % requires npy-matlab package: https://github.com/kwikteam/npy-matlab
                fprintf(['... reading events from ' file_nev.name '\n']);
                [events_nev,prs] = GetEvents_nev(file_nev.name,prs); % requires package from Blackrock Microsystems: https://github.com/BlackrockMicrosystems/NPMK 
                if length(this.behaviours.trials)==length(events_nev.t_end)
                    if ~isempty(sua)
                        for i=1:length(sua)
                            %fetch singleunit
                            this.units(end+1) = unit('singleunit');
                            this.units(end).AddTrials(sua(i).tspk,events_nev,this.behaviours,prs);
                            fprintf(['... Analysing singleunit ' num2str(i) '\n']);
                            this.units(end).AnalyseUnit(this.behaviours,prs);
                        end
                    end
                    if ~isempty(mua)
                        for i=1:length(mua)
                            %fetch multiunit
                            this.units(end+1) = unit('multiunit');
                            this.units(end).AddTrials(mua(i).tspk,events_nev,this.behaviours,prs);
                            fprintf(['... Analysing multiunit ' num2str(i) '\n']);
                            this.units(end).AnalyseUnit(this.behaviours,prs);
                        end
                    end
                else
                    fprintf('Trial counts in smr and nev files do not match \n');
                    fprintf(['Trial end events: NEV file - ' num2str(length(events_nev.t_end)) ...
                        ' , SMR file - ' num2str(length(this.behaviours.trials)) '\n']);
                    fprintf('Debug and try again! \n');
                end
            else
                fprintf('No neural data files in the specified path \n');
            end
        end
        %% add lfps
        function AddLfps(this,filepath,prs)
            cd(filepath);
            file_ead=dir('*_ead.plx');
            fprintf(['... reading ' file_ead.name '\n']);
            for j=1:prs.maxchannels
                this.lfps = GetLfp(file_ead.name,j);
            end
        end
        %% add populations
        function AddPopulation(this,unittype,prs)
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
        function PlotUnits(this,unit_type,unit_id,plot_type,prs)
            behv = this.behaviours;
            units = this.(unit_type);
            if length(unit_id)~=1
                error('unit id should be an non-negative integer');
            end
            if unit_id~=0
                unit = units(unit_id);
                PlotUnit(behv,unit,plot_type,prs);        % plot data from a specific unit
            else
                PlotUnits(behv,units,plot_type,prs);      % plot data from all units
            end
        end
    end
end