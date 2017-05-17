classdef session < handle
    %%
    properties
        monk_id
        session_id
        coord
        tseries
        trials                                                              % trial
        multiunits = multiunit.empty();                                     % multiunit
        singleunits = singleunit.empty();                                   % singleunit
        lfps = lfp.empty();                                                 % lfp
        populations = population.empty();                                   % population
        behaviour
    end
    %%
    methods
        %% class constructor
        function this = session(monk_id,session_id,coord)
            this.monk_id = monk_id;
            this.session_id = session_id;
            this.coord = coord;
        end
        %% add trials
        function AddTrials(this,prs)
            cd(prs.filepath_behv);
            flist_smr=dir('*.smr'); nfile = length(flist_smr);
            flist_log=dir('*.log');
            flist_mat=dir('*.mat');
            for i=1:length(flist_smr)
                fprintf(['... reading ' flist_smr(i).name '\n']);
                data_smr = ImportSMR(flist_smr(i).name);
                [this.tseries.smr(i),trials_temp] = AddSMRData(data_smr,prs);
                trials_temp = AddLOGData(flist_log(i).name,trials_temp);
                trials_temp = AddMATData(flist_mat(i).name,trials_temp);
                this.trials = [this.trials trials_temp];
                clear trials_temp;
            end
        end
        %% analyse behaviour
        function AnalyseBehaviour(this,prs)
            this.behaviour = AnalyseBehaviour(this.trials,prs);
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
                events_nev = GetEvents_nev(file_mat.name);
                events_smr.t_beg = [this.trials.t_beg];
                events_smr.t_rew = [this.trials.t_rew];
                events_smr.t_end = [this.trials.t_end];
                events_smr.ntrls = [this.tseries.smr.ntrls];
                if length(this.trials)==length(events_nev.t_end)
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
    end
end