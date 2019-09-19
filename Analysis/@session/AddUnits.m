%% add units
function AddUnits(this,prs)
    cd(prs.filepath_neur);
    file_ead=dir('*_ead.plx');
    file_nev=dir('*.nev');
    prs.fs_spk = 40000; % (Hz) hard-coded for now -- must read sampling rate from plx file!!!!
    if ~isempty(file_ead) % data recorded using Plexon
        prs.neur_filetype = 'plx';
        fprintf(['... reading ' file_ead.name '\n']);
        t_events = GetEvents_plx(file_ead.name);
        file_plx=dir('*_spk.plx');
        fprintf(['... reading ' file_plx.name '\n']);
        for j=1:prs.maxchannels_plx
            fprintf(['...... channel ' num2str(j) '/' num2str(prs.maxchannels_plx) '\n']);
            smua = GetUnits_plx(file_plx.name,prs.units,j); % smua = singleunits + multiunits
            %fetch multiunit 
            this.units(end+1) = unit('multiunit',smua(1),prs.fs_spk);
            this.units(end).AddTrials(smua(1).tspk,t_events,this.behaviours,prs);
            %fetch units
            if length(smua)>1
                for k=2:length(smua)
                    this.units(end+1) = unit('singleunit',smua(k),prs.fs_spk);
                    this.units(end).AddTrials(smua(k).tspk,t_events,this.behaviours,prs);
                end
            end
        end
    elseif ~isempty(file_nev) % data recorded using Cereplex
        prs.neur_filetype = 'nev';
        [sua, mua] = GetUnits_phy('spike_times.npy', 'spike_clusters.npy', 'cluster_groups.csv','cluster_location.xls',prs.electrode_type); % requires npy-matlab package: https://github.com/kwikteam/npy-matlab
        fprintf(['... reading events from ' file_nev.name '\n']);
        [events_nev,prs] = GetEvents_nev(file_nev.name,prs); % requires package from Blackrock Microsystems: https://github.com/BlackrockMicrosystems/NPMK
        if length(this.behaviours.trials)~=length(events_nev.t_end)
            events_nev = FixEvents_nev(events_nev,this.behaviours.trials);
        end
        if length(this.behaviours.trials)==length(events_nev.t_end)
            if ~isempty(sua)
                for i=1:length(sua)
                    %fetch singleunit
                    this.units(end+1) = unit('singleunit',sua(i),prs.fs_spk);
                    this.units(end).AddTrials(sua(i).tspk,events_nev,this.behaviours,prs);
                end
            end
            if ~isempty(mua)
                for i=1:length(mua)
                    %fetch multiunit
                    this.units(end+1) = unit('multiunit',mua(i),prs.fs_spk);
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