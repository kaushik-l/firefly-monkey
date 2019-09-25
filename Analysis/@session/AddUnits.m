%% add units
function AddUnits(this,prs)

cd(prs.filepath_neur);
linearprobe_type = find(cellfun(@(electrode_type) strcmp(prs.electrode_type,electrode_type), prs.linearprobe.types),1);
utaharray_type = find(cellfun(@(electrode_type) strcmp(prs.electrode_type,electrode_type), prs.utaharray.types),1);

if ~isempty(linearprobe_type) % assume linearprobe is recorded using Plexon
    file_ead=dir('*_ead.plx'); prs.neur_filetype = 'plx';
    fprintf(['... reading ' file_ead.name '\n']);
    [events_plx,prs.fs_spk] = GetEvents_plx(file_ead.name);
    file_plx=dir('*_spk.plx');
    fprintf(['... reading ' file_plx.name '\n']);
    for j=1:prs.linearprobe.channelcount(linearprobe_type)
        fprintf(['...... channel ' num2str(j) '/' num2str(prs.linearprobe.channelcount(linearprobe_type)) '\n']);
        smua = GetUnits_plx(file_plx.name,prs.units,j); % smua = singleunits + multiunits
        %fetch multiunit
        this.units(end+1) = unit('multiunit',smua(1),prs.fs_spk);
        this.units(end).AddTrials(smua(1).tspk,events_plx,this.behaviours,prs);
        %fetch units
        if length(smua)>1
            for k=2:length(smua)
                this.units(end+1) = unit('singleunit',smua(k),prs.fs_spk);
                this.units(end).AddTrials(smua(k).tspk,events_plx,this.behaviours,prs);
            end
        end
    end
end

if ~isempty(utaharray_type) % assume utaharray is recorded using Cereplex
    file_nev=dir('*.nev'); prs.neur_filetype = 'nev';
    [sua, mua] = GetUnits_phy('spike_times.npy', 'spike_clusters.npy', 'cluster_groups.csv','cluster_location.xls',prs.utaharray.types{utaharray_type}); % requires npy-matlab package: https://github.com/kwikteam/npy-matlab
    brain_area = prs.area{strcmp(prs.electrode_type,prs.utaharray.types{utaharray_type})};
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
                if strcmp(prs.utaharray.types{utaharray_type},'utah96'), this.units(end).brain_area = brain_area;
                else, this.units(end).brain_area = prs.MapDualArray2BrainArea(brain_area, this.units(end).electrode_id); end
                this.units(end).AddTrials(sua(i).tspk,events_nev,this.behaviours,prs);
            end
        end
        if ~isempty(mua)
            for i=1:length(mua)
                %fetch multiunit
                this.units(end+1) = unit('multiunit',mua(i),prs.fs_spk);
                if strcmp(prs.utaharray.types{utaharray_type},'utah96'), this.units(end).brain_area = brain_area;
                else, this.units(end).brain_area = prs.MapDualArray2BrainArea(brain_area, this.units(end).electrode_id); end
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