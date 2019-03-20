%% add lfps
function AddLfps(this,prs)
    cd(prs.filepath_neur);
    file_ead=dir('_ead.plx');
    file_ns1=dir('*.ns1');
    file_ns6=dir('*.ns6');
    if ~isempty(file_ead)
        fprintf(['... reading events from ' file_ead.name '\n']);
        t_events = GetEvents_plx(file_ead.name);
        for j=1:prs.maxchannels
        end
    elseif ~isempty(file_ns1) || ~isempty(file_ns6)
        if ~isempty(file_ns1), file_lfp = file_ns1; else, file_lfp = file_ns6; end
        file_nev=dir('*.nev');
        fprintf(['... reading events from ' file_nev.name '\n']);
        [events_nev,prs] = GetEvents_nev(file_nev.name,prs); % requires package from Blackrock Microsystems: https://github.com/BlackrockMicrosystems/NPMK
        if length(this.behaviours.trials)~=length(events_nev.t_end)
            events_nev = FixEvents_nev(events_nev,this.behaviours.trials);
        end
        if length(this.behaviours.trials)==length(events_nev.t_end)
            [ch_id,electrode_id] = MapChannel2Electrode('utah96'); % assuming 96 channel array -- need to generalise this line of code
            for j=1:prs.maxchannels
                lfpdata = openNSx(['/' file_lfp.name],'report','read', 'uV',['c:' num2str(j)]);
                channel_id = lfpdata.MetaTags.ChannelID;
                fprintf(['Segmenting LFP :: channel ' num2str(channel_id) '\n']);
                this.lfps(j) = lfp(channel_id,electrode_id(ch_id == channel_id));
                this.lfps(j).AddTrials(lfpdata.Data,lfpdata.MetaTags.SamplingFreq,events_nev,this.behaviours,prs);
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