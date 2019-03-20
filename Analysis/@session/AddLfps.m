%% add lfps
function AddLfps(this,prs)
    cd(prs.filepath_neur);
    file_ead=dir('*_ead.plx'); file_nev=dir('*.nev'); % possible event files
    file_lfp=dir('*_lfp.plx'); file_ns1=dir('*.ns1'); file_ns6=dir('*.ns6'); % possible lfp files
    if ~isempty(file_lfp) && ~isempty(file_ead)  % read (lfp + ead) if using Plexon
        % read events
        fprintf(['... reading events from ' file_ead.name '\n']);
        [events_plx, fs] = GetEvents_plx(file_ead.name);
        % convert eventtimes from samples to seconds
        events_plx.start = events_plx.start/fs;
        events_plx.t_beg = events_plx.t_beg/fs; events_plx.t_end = events_plx.t_end/fs; events_plx.t_rew = events_plx.t_rew/fs;
        % read lfp
        if length(this.behaviours.trials)==length(events_plx.t_end)
            fprintf(['... reading ' file_lfp.name '\n']);
            [ch_id,electrode_id] = MapChannel2Electrode('linearprobe');
            for j=1:prs.maxchannels
                fprintf(['...... channel ' num2str(j) '/' num2str(prs.maxchannels) '\n']);
                [adfreq, n, ~, fn, ad] = plx_ad_v(file_lfp.name, j-1);
                if n == fn
                    if adfreq > prs.fs_lfp, N = round(adfreq/prs.fs_lfp); ad = downsample(ad,N); end
                    channel_id = j;
                    fprintf(['Segmenting LFP :: channel ' num2str(channel_id) '\n']);
                    this.lfps(j) = lfp(channel_id,electrode_id(ch_id == channel_id));
                    this.lfps(j).AddTrials(ad,adfreq/N,events_plx,this.behaviours,prs);
                else
                    fprintf('...... LFP is fragmented. Use a machine with more RAM or contact KL\n');
                end
            end
        else
            fprintf('Cannot segment LFP: Trial counts in smr and plx files do not match \n');
            fprintf(['Trial end events: PLX file - ' num2str(length(events_plx.t_end)) ...
                ' , SMR file - ' num2str(length(this.behaviours.trials)) '\n']);
            fprintf('Debug and try again! \n');
        end
    elseif (~isempty(file_ns1) || ~isempty(file_ns6)) && ~isempty(file_nev) % read (ns1/ns6 + nev) if using Cereplex
        if ~isempty(file_ns1), file_lfp = file_ns1; else, file_lfp = file_ns6; prs.lfp_filtorder = 2; end % higher-order filter fails with ns6
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