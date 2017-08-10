function trials = AddLOGData(file)

count = 0;
fid = fopen(file, 'r');
eof=0; newline = 'nothingnew'; count=0;
while newline ~= -1
    %% get ground plane density
    while ~strcmp(newline(1:9),'Floor Den')
        newline = fgetl(fid);
        if newline == -1, break; end
    end
    if newline == -1, break; end
    count = count+1;
    trials(count).floordensity = str2num(newline(27:34));
    %% get perturbation parameter
    %     while ~strcmp(newline(1:12),'Perturbation')
    %         newline = fgetl(fid);
    %     end
    %     trials(count).linptb = str2num(newline(35:40));
    %     newline = fgetl(fid);
    %     trials(count).angptb = str2num(newline(36:41));
    %%
    newline = fgetl(fid);
end