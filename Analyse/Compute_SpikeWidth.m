function spkwidth = Compute_SpikeWidth(spkwf,Fs)

dt = 1/Fs; Nt = length(spkwf);
t = 1e3*(dt:dt:Nt*dt); % time in ms
[~,minindx] = min(spkwf); t_min = t(minindx); % detect trough
[~,maxindx] = max(spkwf(minindx+1:end));
maxindx = maxindx + minindx; t_max = t(maxindx); % detect peak that follows trough
spkwidth = t_max - t_min; % spikewidth  = t_peak - t_trough