%% add lfps
function AddLfps(this,prs)

%% load plx
cd(prs.filepath_neur);
if any(strcmp(prs.electrode_type,'linearprobe24')) | any(strcmp(prs.electrode_type,'linearprobe16')) % Modify, keep one brain area for k=1:24, lfps(k).brain_area = lfps(k).brain_area(2); else, lfps(k).brain_area = lfps(k).brain_area(1); end
    if any(strcmp(prs.electrode_type,'linearprobe24')), electrode_type = {'linearprobe24'}; else electrode_type = {'linearprobe16'}; end 
    disp ('loading plexon file...')
    
    file_ead_plx=dir('*_ead.plx');
    file_lfp_plx=dir('*_lfp.plx');
    file_ns1=dir('*.ns1');
    
    if ~isempty(file_lfp_plx) && ~isempty(file_ead_plx)
        % read events
        fprintf(['... reading events from ' file_ead_plx.name '\n']);
        [events_plx, fs_plx] = GetEvents_plx(file_ead_plx.name);
        % convert eventtimes from samples to seconds
        events_plx.t_start = events_plx.start/fs_plx;
        events_plx.t_beg = events_plx.t_beg/fs_plx; events_plx.t_end = events_plx.t_end/fs_plx; events_plx.t_rew = events_plx.t_rew/fs_plx;
        % read lfp
        if length(this.behaviours.trials)==length(events_plx.t_end)
            fprintf(['... reading ' file_lfp_plx.name '\n']);
            [ch_id,electrode_id] = MapChannel2Electrode('linearprobe');
            
            % load electrode_type brain_area coord from prs
            for j=1:prs.maxchannels_plx
                fprintf(['...... channel ' num2str(j) '/' num2str(prs.maxchannels_plx) '\n']);
                [adfreq, n, ~, fn, ad] = plx_ad_v(file_lfp_plx.name, j-1); ad = ad*1000; % convert to microvolts
                if n == fn
                    if adfreq > prs.fs_lfp, N = round(adfreq/prs.fs_lfp); ad = downsample(ad,N); end
                    channel_id = j;
                    fprintf(['Segmenting LFP :: channel ' num2str(channel_id) '\n']);
                    this.lfps(end+1) = lfp(channel_id,electrode_id(ch_id == channel_id),electrode_type,prs.brain_area,prs.coord);
                    this.lfps(end).AddTrials(ad,adfreq/N,events_plx,this.behaviours,prs);
                else
                    fprintf('...... LFP is fragmented. Use a machine with more RAM or contact KL\n');
                    
                end
            end
        else
            fprintf('Cannot segment LFP: Trial counts in smr and plx files do not match \n');
            fprintf(['Trial end events: PLX file - ' num2str(length(events_plx.t_end)) ...
                ' , SMR file - ' num2str(length(this.behaviours.trials)) '\n']);
            fprintf('Debug and try again! \n');
            fprintf('No neural data files in the specified path \n');
        end
    end
    
    %% load nev
    if any(strcmp(prs.electrode_type,'utah96')) | any(strcmp(prs.electrode_type,'utah2x48'));
        if any(strcmp(prs.electrode_type,'utah96')), electrode_type = {'utah96'}; else electrode_type = {'utah2x48'}; end
        if ~isempty(file_ns1), file_nev=dir('*.nev');
            prs.lfp_filtorder = 2; end % higher-order filter fails with ns6
        fprintf(['... reading events from ' file_nev.name '\n']);
        [events_nev,prs] = GetEvents_nev(file_nev.name,prs); % requires package from Blackrock Microsystems: https://github.com/BlackrockMicrosystems/NPMK
        if length(this.behaviours.trials)~=length(events_nev.t_end)
            events_nev = FixEvents_nev(events_nev,this.behaviours.trials);
        end
        if length(this.behaviours.trials)==length(events_nev.t_end)
            [ch_id,electrode_id] = MapChannel2Electrode('utah96'); % assuming 96 channel array -- need to generalise this line of code
            for j=1:prs.maxchannels_nev
                lfpdata = openNSx(['/' file_ns1.name],'report','read', 'uV',['c:' num2str(j)]);
                channel_id = lfpdata.MetaTags.ChannelID;
                fprintf(['Segmenting LFP :: channel ' num2str(channel_id) '\n']);
                this.lfps(end+1) = lfp(channel_id,electrode_id(ch_id == channel_id),electrode_type,prs.brain_area,prs.coord);
                this.lfps(end).AddTrials(lfpdata.Data,lfpdata.MetaTags.SamplingFreq,events_nev,this.behaviours,prs); % end
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
end

