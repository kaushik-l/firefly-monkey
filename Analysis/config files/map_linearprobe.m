function [xcoords, ycoords] = map_utaharray(fpath,electrode)
% create a channel Map file for UProbe recordings

if nargin<2, electrode = 'linearprobe24'; end % default

switch electrode
    case 'linearprobe16'
        chanMap = 1:16;
        
        connected = true(16, 1);
        
        % coord units in micrometers
        coords = [0, 1600];
        [0, 1500];
        [0, 1400];
        [0, 1300];
        [0, 1200];
        [0, 1100];
        [0, 1000];
        [0, 900];
        [0, 800];
        [0, 700];
        [0, 600];
        [0, 500];
        [0, 400];
        [0, 300];
        [0, 200];
        [0, 100];
        
        
        xcoords = coords(:,1); xcoords = flipud(xcoords);
        ycoords = coords(:,2); ycoords = flipud(ycoords);
        
        kcoords = 1:16;
        
        fs = 20000;
        
        if nargin==1
            save(fullfile(fpath, 'chanMap.mat'), 'chanMap', 'connected', 'xcoords', 'ycoords', 'kcoords', 'fs');
        else
            xcoords = (xcoords/100)  + 1;
            ycoords = (ycoords/100)  + 1;
        end;
        
    case 'linearprobe24'
        chanMap = 1:24;
        
        connected = true(24, 1);
        
        % coord units in micrometers
        coords = [0, 2400];
        [0, 2300];
        [0, 2200];
        [0, 2100];
        [0, 2000];
        [0, 1900];
        [0, 1800];
        [0, 1700];
        [0, 1600];
        [0, 1500];
        [0, 1400];
        [0, 1300];
        [0, 1200];
        [0, 1100];
        [0, 1000];
        [0, 900];
        [0, 800];
        [0, 700];
        [0, 600];
        [0, 500];
        [0, 400];
        [0, 300];
        [0, 200];
        [0, 100];
        
        xcoords = coords(:,1); xcoords = flipud(xcoords);
        ycoords = coords(:,2); ycoords = flipud(ycoords);
        
        kcoords = 1:24;
        
        fs = 20000;
        
        if nargin==1
            save(fullfile(fpath, 'chanMap.mat'), 'chanMap', 'connected', 'xcoords', 'ycoords', 'kcoords', 'fs');
        else
            xcoords = (xcoords/100)  + 1;
            ycoords = (ycoords/100)  + 1;
        end;
        
end