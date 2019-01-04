function pupilChan = readChanSMR(data,prs, checkChannel); 


nch = length(data);
ch_title = cell(1,nch);
hdr = {data.hdr};
for i=1:nch
    if ~isempty(hdr{i})
        ch_title{i} = hdr{i}.title;
    else
        ch_title{i} = 'nan';
    end
end

pupilChan.LPd = find(strcmp(ch_title,'LPd')); pupilChan.RPd = find(strcmp(ch_title,'RPd'));

if  ~isempty(pupilChan.LPd) & checkChannel 
    scaling.LPd = data(pupilChan.LPd).hdr.adc.Scale; offset.LPd = data(pupilChan.LPd).hdr.adc.DC;
    scaling.RPd = data(pupilChan.RPd).hdr.adc.Scale; offset.RPd = data(pupilChan.RPd).hdr.adc.DC;
    ch_LPd = data(pupilChan.LPd).imp.adc;
    ch_RPd = data(pupilChan.RPd).imp.adc;
    figure; hold on;  
    plot(data(pupilChan.LPd).imp.adc);
    plot(data(pupilChan.RPd).imp.adc)
end