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
            elseif ~isempty(file_nev) % data recorded using Cereplex
                file_mat=dir('*.mat');
                fprintf(['... reading events from ' file_mat.name '\n']);
                [events_nev,prs] = GetEvents_nev(file_mat.name,prs);
                events_smr.t_beg = [this.behaviours.trials.t_beg];
                events_smr.t_rew = [this.behaviours.trials.t_rew];
                events_smr.t_end = [this.behaviours.trials.t_end];
                events_smr.ntrls = [this.behaviours.tseries.smr.ntrls];
                if length(this.behaviours.trials)==length(events_nev.t_end)
                    fprintf(['... reading spikes from ' file_mat.name '\n']);
                    for j=1:prs.maxchannels
                        fprintf(['...... channel ' num2str(j) '/' num2str(prs.maxchannels) '\n']);
                        units = GetUnits_nev(file_mat.name,j);
                        if ~isempty(units)
                            for i=1:length(units)
                                if units(i).type == 'mua'
                                    %fetch multiunit
                                    this.multiunits(end+1) = multiunit(units(i));
                                    this.multiunits(end).AddTrials(units(i).tspk,events_nev,events_smr,prs);
                                    this.multiunits(end).AnalyseUnit('firefly-monkey',this.behaviours,prs);
                                elseif units(i).type == 'sua'
                                    %fetch singleunits
                                    this.singleunits(end+1) = singleunit(units(i));
                                    this.singleunits(end).AddTrials(units(i).tspk,events_nev,events_smr,prs);
                                end
                            end
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
        function PlotUnits(this,unit_type,unit_id,plot_type)
            behv = this.behaviours;
            units = this.(unit_type);
            if length(unit_id)~=1
                error('unit id should be an non-negative integer');
            end
            if unit_id~=0
                unit = units(unit_id);
                PlotUnit(behv,unit,plot_type);        % plot data from a specific unit
            else
                PlotUnits(behv,units,plot_type);      % plot data from all units
            end
        end
    end
end