function trials = AddLOGData(file,trials)

ntrls = length(trials);
count = 0;
fid = fopen(file, 'r');
eof=0; newline = 'nonewline'; count=0;
while ~eof
    while ~strcmp(newline(1:9),'Floor Den')
        newline = fgetl(fid);
    end
    count = count+1;
    trials(count).floordensity = str2num(newline(27:34));
%     while ~strcmp(newline(1:12),'Perturbation')
%         newline = fgetl(fid);
%     end
%     trials(count).linptb = str2num(newline(35:40));
%     newline = fgetl(fid);
%     trials(count).angptb = str2num(newline(36:41));
    if count==ntrls 
        eof=1;
    else
        newline = fgetl(fid);
    end
end