function MakeDatFile(fname,T_exp)

[~,fOut] = fileparts(fname);
buffer_read = 1000; % batch length of data to read (s)
buffer_write = 10; % batch length of data to write (s)
NT_header = 102; % header length of .ns6
count = 0;

%% read header information
NEV = openNEV('/m44s1249.nev','report', 'read');
fs = NEV.MetaTags.SampleRes;
% load the entire file if T_exp is not specified
% this is what we want for spike-sorting; duration should only be 
% specified for debugging
if nargin<2
    T_exp = NEV.MetaTags.DataDurationSec;
end

%% load raw data
t_read = 0;
while t_read<T_exp
    fprintf(['Reading datafile... T = ' num2str(t_read) 's\n']);
    if T_exp-t_read > buffer_read
        NS6 = openNSx(['/' fname],'report','read', 'uV',['t:' num2str(t_read) ':' num2str(t_read+buffer_read)],'sec');        
        dt_read = buffer_read;
    else
        NS6 = openNSx(['/' fname],'report','read', 'uV',['t:' num2str(t_read) ':' num2str(T_exp)],'sec');
        dt_read = T_exp - t_read;
    end
    t_read = t_read + buffer_read;
    NS6.Data(:,1:NT_header) = [];
    %% write raw data into a binary file
    t_write = 0; nt_write = 0;
    fidW = fopen([fOut '.dat'], 'a');
    NT_write   = buffer_write*fs;
    while t_write<dt_read
        if dt_read-t_write >= buffer_write
            dat = NS6.Data(:,nt_write+1:nt_write+NT_write);
        elseif dt_read-t_write > 0
            dat = NS6.Data(:,nt_write+1:end);
        end
        dat = int16(dat);
        fwrite(fidW, dat,'int16');
        t_write = t_write + buffer_write;
        nt_write = t_write*fs;
        count = count + size(dat,2);
    end
    fclose(fidW); % all done
end