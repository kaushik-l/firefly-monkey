function MakeDatFile(fname,duration)

NS6 = openNSx(['/' fname],'report','read', 'uV',['t:0:' num2str(duration)],'sec');
fs = NS6.MetaTags.SamplingFreq;

fidW = fopen('data_binary.dat', 'w');
NT   = 4*fs; % batch size + buffer
t = 0; nt = 0;
while t<duration
    dat = NS6.Data(:,nt+1:nt+NT);
    dat = int16(dat);
    fwrite(fidW, dat,'int16');
    t = t + NT/fs;
    nt = t*fs;
end
fclose(fidW); % all done