classdef session < handle
    %%
    properties
        monk_id
        sess_id
        coord
        behaviours = behaviour.empty();                                     % trial
        multiunits = multiunit.empty();                                     % multiunit
        singleunits = singleunit.empty();                                   % singleunit
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
            this.behaviours = behaviour(prs.comments);
            this.behaviours.AddTrials(prs);
            this.behaviours.AnalyseBehaviour(prs);
            this.behaviours.UseDatatype('single');
        end
        %% add units
        function AddUnits(this,prs)
            cd(prs.filepath_neur);
            file_ead=dir('*_ead.plx');
            file_ns6=dir('*.ns6');
            file_nev=dir('*.nev');
            if ~isempty(file_ead) % data recorded using Plexon
                fprintf(['... reading ' file_ead.name '\n']);
                t_events = GetEvents_plx(file_ead.name);
                file_plx=dir('*_spk.plx');
                fprintf(['... reading ' file_plx.name '\n']);
                for j=1:prs.maxchannels
                    fprintf(['...... channel ' num2str(j) '/' num2str(prs.maxchannels) '\n']);
                    units = GetUnits_plx(file_plx.name,prs.units,j);
                    %fetch multiunit
                    this.multiunits(end+1) = multiunit(units(1));
                    this.multiunits(end).AddTrials(units(1).tspk,t_events,prs);
                    %fetch singleunits
                    if length(units)>1
                        for k=2:length(units)
                            this.singleunits(end+1) = singleunit(units(k));
                            this.singleunits(end).AddTrials(units(k).tspk,t_events,prs);
                        end
                    end
                end
            elseif ~isempty(file_ns6) % data recorded using Cereplex
                [sua, mua] = GetUnits_phy('spike_times.npy', 'spike_clusters.npy', 'cluster_groups.csv');
                fprintf(['... reading events from ' file_nev.name '\n']);
                [events_nev,prs] = GetEvents_nev(file_nev.name,prs);
                events_smr.t_beg = [this.behaviours.trials.t_beg];
                events_smr.t_rew = [this.behaviours.trials.t_rew];
                events_smr.t_end = [this.behaviours.trials.t_end];
                events_smr.ntrls = [this.behaviours.tseries.smr.ntrls];
                if 1 %length(this.behaviours.trials)==length(events_nev.t_end)
                    if ~isempty(sua)
                        for i=1:length(sua)
                            %fetch singleunit
                            this.singleunits(end+1) = singleunit(sua(i));
                            this.singleunits(end).AddTrials(sua(i).tspk,events_nev,events_smr,prs);
%                             this.singleunits(end).AnalyseUnit('firefly-monkey',this.behaviours,prs);
                        end
                    end
                else
                    fprintf('... trial counts in smr and nev files do not match \n');
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