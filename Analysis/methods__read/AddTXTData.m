function [ts, x_monk, y_monk, X_fly, Y_fly, I_fly, fly_sts] = AddTXTData(fname)

% t: vector of time points (1xT)
% x_monk: vector of monkey x-coor (1xT)
% y_monk: vector of monkey y-coor (1xT)
% x_fly: array of fly x-coor (NxT)
% y_fly: array of fly y-coor (NxT)
% rew: array of structs for each reward
%      rew(i).t: time of ith reward
%      rew(i).x_monk: monkey x-coord at the time of ith reward
%      rew(i).y_monk: monkey y-coord at the time of ith reward
%      rew(i).x_fly: fly x-coord at the time of ith reward
%      rew(i).y_fly: fly y-coord at the time of ith reward

fid = fopen(fname, 'r');
newline = 'nothingnew'; count=0;
while newline ~= -1
    %% get firefly info
    while ~strcmp(newline(1:7),'Firefly')
        newline = fgetl(fid);
        if isempty(newline), break; end
    end
    if isempty(newline), break; end
    count = count+1;
    fly(count).t_catch = []; fly(count).t_on = []; fly(count).t_off = []; 
    fly(count).x = []; fly(count).y = []; monk(count).x = []; monk(count).y = [];
    reset = 0;
    while ~reset
        newline = fgetl(fid);
        indx_space = strfind(newline,' ');
        numspaces = length(indx_space);
        if numspaces ~= 4, reset = 1;
        else
            fly(count).t_catch(end+1) = str2double(newline(1:indx_space(1)));
            fly(count).x(end+1) = str2double(newline(indx_space(1):indx_space(2)));
            fly(count).y(end+1) = str2double(newline(indx_space(2):indx_space(3)));
            monk(count).x(end+1) = str2double(newline(indx_space(3):indx_space(4)));
            monk(count).y(end+1) = str2double(newline(indx_space(4):end));
        end
    end
    while ~strcmp(newline(1:7),'Firefly')
        indx_space = strfind(newline,' ');
        fly(count).t_on(end+1) = str2double(newline(1:indx_space(1)));
        fly(count).t_off(end+1) = str2double(newline(indx_space(1):end));
        newline = fgetl(fid);
        if isempty(newline), break; end
    end
    if isempty(newline), break; end
end
fclose(fid);

fid = fopen(fname, 'r');
newline = 'nothingnew'; count=0;
x_monk = []; y_monk = []; ts = [];
while newline ~= -1
    %% get monkey trajectory info
    while ~strcmp(newline(1:6),'Monkey')
        newline = fgetl(fid);
        if newline == -1, break; 
        elseif isempty(newline), newline = 'nothingnew'; end
    end
    if newline == -1, break; end
    newline = fgetl(fid);
    while newline ~= -1
        indx_space = strfind(newline,' ');
        x_monk(end+1) = str2double(newline(1:indx_space(1)));
        y_monk(end+1) = str2double(newline(indx_space(1):indx_space(2)));
        ts(end+1) = str2double(newline(indx_space(2):end));
        newline = fgetl(fid);
    end
end
fclose(fid);

%% vectorize fly positions
Nt = length(ts); Nfly = length(fly);
X_fly = 10000*ones(Nt,Nfly); Y_fly= 10000*ones(Nt,Nfly); I_fly = zeros(Nt,Nfly);
for i=1:length(fly)    
    t_catch = [0 fly(i).t_catch];
    t_on = fly(i).t_on; t_off = fly(i).t_off;
    for j=2:length(t_catch)        
        X_fly(ts>=t_catch(j-1) & ts<t_catch(j),i) = fly(i).x(j-1);
        Y_fly(ts>=t_catch(j-1) & ts<t_catch(j),i) = fly(i).y(j-1);
    end
    for j=1:length(t_on)
        I_fly(ts>=t_on(j) & ts<t_off(j),i) = 1;
    end
end

%% firefly status
fly_sts = struct.empty(Nfly,0);
for i=1:Nfly
    fly_sts(i).t_catch = fly(i).t_catch;
    fly_sts(i).x = fly(i).x;
    fly_sts(i).y = fly(i).y;
    fly_sts(i).x_catch = monk(i).x;
    fly_sts(i).y_catch = monk(i).y;
    fly_sts(i).t_on = fly(i).t_on;
    fly_sts(i).t_off = fly(i).t_off;
end