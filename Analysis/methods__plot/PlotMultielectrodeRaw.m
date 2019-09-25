function PlotMultielectrodeRaw(monk_id,sess_id)

%% load parameters
prs = default_prs(monk_id,sess_id);
factor_downsample = 4;

%% go to data folder
cd(prs.filepath_neur);

%% time period to load
duration = 5; starttime = round(rand*1000); % seconds
linearprobe_type = find(sum(cell2mat(cellfun(@(electrode_type) strcmp(prs.electrode_type,electrode_type), prs.linearprobe.types,'UniformOutput',false)'),2));
utaharray_type = find(sum(cell2mat(cellfun(@(electrode_type) strcmp(prs.electrode_type,electrode_type), prs.utaharray.types,'UniformOutput',false)'),2));
    
if ~isempty(utaharray_type) % assume utaharray is recorded using Cereplex
        electrode_type = prs.utaharray.types{utaharray_type};
        %% load raw data
        datfile = dir('*.dat'); nevfile = dir('*.nev');
        events_nev = GetEvents_nev(nevfile.name,prs); % requires package from Blackrock Microsystems: https://github.com/BlackrockMicrosystems/NPMK
        nch = prs.utaharray.channelcount(utaharray_type); fs = 30000; dt = 1/fs; 
        [data_array,startsample] = ReadDatFile(datfile.name,nch,duration*fs,'int16',(events_nev.t_start(1) + starttime)*nch*fs);
        [nch,ntimebins] = size(data_array); starttimebin = (startsample/nch);
        ts = (starttime*fs + 1)*dt:dt:(starttime*fs + ntimebins)*dt;
        [~,elec_indx] = MapChannel2Electrode(electrode_type);
        [~,sortindx] = sort(elec_indx);
        data_array = data_array(sortindx,:);
        
        %% load spike times
        [sua, mua] = GetUnits_phy('spike_times.npy', 'spike_clusters.npy', 'cluster_groups.csv', 'cluster_location.xls', electrode_type);        
        nsua = numel(sua); nmua = numel(mua);
        spikelength = 0.002*fs; % color a 2ms stretch around action potential
        for k = 1:nsua
            tspk = double(sua(k).tspk);
            sua(k).tspk = tspk(tspk > starttimebin & tspk < (starttimebin + ntimebins - spikelength)) - starttimebin;
        end
        for k = 1:nmua
            tspk = double(mua(k).tspk);
            mua(k).tspk = tspk(tspk > starttimebin & tspk < (starttimebin + ntimebins - spikelength)) - starttimebin;
        end
        units = [sua mua]; nunits = nsua + nmua;
        
        %% plot raw data
        data_array_downsampled = downsample(data_array',factor_downsample)';
        ts_downsampled = downsample(ts,factor_downsample);
        figure; hold on;
        for k=1:nch, plot(ts_downsampled,data_array_downsampled(k,:) + 50*k*(k<=48) + (50*k+1000)*(k>48),'Color',[0.7 0.7 0.7]); end
        xlabel('Time (sec)'); ylabel('Amplitude (\muV)');
        
        %% do spike coloring
        spikelength_downsampled = spikelength/factor_downsample;
        clrs = jet(nunits);
        for k=1:nunits
            thisunit = units(k);
            electrode_id = thisunit.electrode_id; 
            tspk = round(thisunit.tspk); nspk = numel(tspk); tspk_downsampled = round(tspk/factor_downsample);
            for i=1:nspk
                spikeindx = tspk_downsampled(i):tspk_downsampled(i)+spikelength_downsampled;
                plot(ts_downsampled(spikeindx),data_array_downsampled(electrode_id,spikeindx) + 50*electrode_id*(electrode_id<=48) + (50*electrode_id+1000)*(electrode_id>48),'Color',clrs(k,:));
            end
        end
end

if ~isempty(linearprobe_type) % assume linearprobe is recorded using Plexon        
        electrode_type = prs.linearprobe.types{linearprobe_type};
        %% load raw data
        rawfile = dir('*raw.plx'); lfpfile = dir('*lfp.plx'); spkfile = dir('*spk.plx'); eadfile = dir('*ead.plx');
        events_plx = GetEvents_plx(eadfile.name);
        nch = prs.linearprobe.channelcount(linearprobe_type); fs = 20000; dt = 1/fs; 
        starttimebin = round(events_plx.start(1) + starttime)*fs + 1;
        ntimebins = duration*fs;
        for k=1:nch, [adfreq, n, data_proberaw(k,:)] = plx_ad_span(rawfile.name, 32+k-1, starttimebin, starttimebin+ntimebins-1); end
        for k=1:nch, [adfreq, n, data_probelfp(k,:)] = plx_ad_span(lfpfile.name, k-1, starttimebin, starttimebin+ntimebins-1); end
        ts = (starttime*fs + 1)*dt:dt:(starttime*fs + ntimebins)*dt;
        
        %% load spike times
        spikelength = 0.002*fs;
        units = [];
        for j=1:prs.linearprobe.channelcount(linearprobe_type)
            fprintf(['...... channel ' num2str(j) '/' num2str(prs.linearprobe.channelcount(linearprobe_type)) '\n']);
            smua = GetUnits_plx(spkfile.name,0,j); % smua = singleunits + multiunits
            for i=1:numel(smua)
                tspk = round(smua(i).tspk*fs);
                smua(i).tspk = tspk(tspk > starttimebin & tspk < (starttimebin + ntimebins - spikelength)) - starttimebin;
            end
            units = [units smua]; nunits = numel(units);
        end
        
        %% plot raw data
        data_probelfp_downsampled = downsample(data_probelfp',factor_downsample)';
        data_proberaw_downsampled = downsample(data_proberaw',factor_downsample)';
        ts_downsampled = downsample(ts,factor_downsample);
        for k=1:nch, plot(ts_downsampled,data_probelfp_downsampled(k,:) + 0.05*data_proberaw_downsampled(k,:) + 7000 + 50*k,'Color',[0.7 0.7 0.7]); end
        xlabel('Time (sec)'); ylabel('Amplitude (\muV)');
        
        %% do spike coloring
        spikelength_downsampled = spikelength/factor_downsample;
        clrs = jet(nunits);
        for k=1:nunits
            thisunit = units(k);
            electrode_id = thisunit.electrode_id; 
            tspk = round(thisunit.tspk); nspk = numel(tspk); tspk_downsampled = round(tspk/factor_downsample);
            for i=1:nspk
                spikeindx = tspk_downsampled(i):tspk_downsampled(i)+spikelength_downsampled;
                plot(ts_downsampled(spikeindx),data_probelfp_downsampled(electrode_id,spikeindx) + 0.05*data_proberaw_downsampled(electrode_id,spikeindx) + 7000 + 50*electrode_id,'Color',clrs(k,:));
            end
        end
end