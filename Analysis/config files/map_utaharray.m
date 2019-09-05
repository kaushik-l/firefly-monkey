function [xcoords, ycoords] = map_utaharray(fpath,electrode)
% create a channel Map file for simulated data (eMouse)

% here I know a priori what order my channels are in.  So I just manually
% make a list of channel indices (and give
% an index to dead channels too). chanMap(1) is the row in the raw binary
% file for the first channel. chanMap(1:2) = [33 34] in my case, which happen to
% be dead channels.

if nargin<2, electrode = 'utah96'; end % default

switch electrode
    case 'utah96'
        chanMap = 1:96;
        
        % the first thing Kilosort does is reorder the data with data = data(chanMap, :).
        % Now we declare which channels are "connected" in this normal ordering,
        % meaning not dead or used for non-ephys data
        
        connected = true(96, 1);
        
        % now we define the horizontal (x) and vertical (y) coordinates of these
        % 34 channels. For dead or nonephys channels the values won't matter. Again
        % I will take this information from the specifications of the probe. These
        % are in um here, but the absolute scaling doesn't really matter in the
        % algorithm.
        
        coords = [[3600, 3200];
            [3600, 2800];
            [3600, 2400];
            [3600, 2000];
            [3600, 1600];
            [3600, 1200];
            [3600, 800];
            [3600, 400];
            [3200, 3600];
            [3200, 3200];
            [3200, 2800];
            [3200, 2400];
            [3200, 2000];
            [3200, 1600];
            [3200, 1200];
            [3200, 800];
            [3200, 400];
            [3200, 0];
            [2800, 3600];
            [2800, 3200];
            [2800, 2800];
            [2800, 2400];
            [2800, 2000];
            [2800, 1600];
            [2800, 1200];
            [2800, 800];
            [2800, 400];
            [2800, 0];
            [2400, 3600];
            [2400, 3200];
            [2400, 2800];
            [2400, 2400];
            [2400, 2000];
            [2400, 1600];
            [2400, 1200];
            [2400, 800];
            [2400, 400];
            [2400, 0];
            [2000, 3600];
            [2000, 3200];
            [2000, 2800];
            [2000, 2400];
            [2000, 2000];
            [2000, 1600];
            [2000, 1200];
            [2000, 800];
            [2000, 400];
            [2000, 0];
            [1600, 3600];
            [1600, 3200];
            [1600, 2800];
            [1600, 2400];
            [1600, 2000];
            [1600, 1600];
            [1600, 1200];
            [1600, 800];
            [1600, 400];
            [1600, 0];
            [1200, 3600];
            [1200, 3200];
            [1200, 2800];
            [1200, 2400];
            [1200, 2000];
            [1200, 1600];
            [1200, 1200];
            [1200, 800];
            [1200, 400];
            [1200, 0];
            [800, 3600];
            [800, 3200];
            [800, 2800];
            [800, 2400];
            [800, 2000];
            [800, 1600];
            [800, 1200];
            [800, 800];
            [800, 400];
            [800, 0];
            [400, 3600];
            [400, 3200];
            [400, 2800];
            [400, 2400];
            [400, 2000];
            [400, 1600];
            [400, 1200];
            [400, 800];
            [400, 400];
            [400, 0];
            [0, 3200];
            [0, 2800];
            [0, 2400];
            [0, 2000];
            [0, 1600];
            [0, 1200];
            [0, 800];
            [0, 400]];
        
        xcoords = coords(:,1); xcoords = flipud(xcoords);
        ycoords = coords(:,2); ycoords = flipud(ycoords);
        
        % Often, multi-shank probes or tetrodes will be organized into groups of
        % channels that cannot possibly share spikes with the rest of the probe. This helps
        % the algorithm discard noisy templates shared across groups. In
        % this case, we set kcoords to indicate which group the channel belongs to.
        % In our case all channels are on the same shank in a single group so we
        % assign them all to group 1.
        
        kcoords = 1:96;
        
        % at this point in Kilosort we do data = data(connected, :), ycoords =
        % ycoords(connected), xcoords = xcoords(connected) and kcoords =
        % kcoords(connected) and no more channel map information is needed (in particular
        % no "adjacency graphs" like in KlustaKwik).
        % Now we can save our channel map for the eMouse.
        
        % would be good to also save the sampling frequency here
        fs = 30000;
        
        if nargin==1
            save(fullfile(fpath, 'chanMap.mat'), 'chanMap', 'connected', 'xcoords', 'ycoords', 'kcoords', 'fs');
        else
            xcoords = (xcoords/400)  + 1;
            ycoords = (ycoords/400)  + 1;
        end;
    case 'utah2x48'
        chanMap = 1:96;
        
        % the first thing Kilosort does is reorder the data with data = data(chanMap, :).
        % Now we declare which channels are "connected" in this normal ordering,
        % meaning not dead or used for non-ephys data
        
        connected = true(96, 1);
        
        % now we define the horizontal (x) and vertical (y) coordinates of these
        % 34 channels. For dead or nonephys channels the values won't matter. Again
        % I will take this information from the specifications of the probe. These
        % are in um here, but the absolute scaling doesn't really matter in the
        % algorithm.
        
        coords = [[0, 0];
            [0, 400];
            [0, 800];
            [0, 1200];
            [0, 1600];
            [0, 2000];
            [400, 0];
            [400, 400];
            [400, 800];
            [400, 1200];
            [400, 1600];
            [400, 2000];
            [800, 0];
            [800, 400];
            [800, 800];
            [800, 1200];
            [800, 1600];
            [800, 2000];
            [1200, 0];
            [1200, 400];
            [1200, 800];
            [1200, 1200];
            [1200, 1600];
            [1200, 2000];
            [1600, 0];
            [1600, 400];
            [1600, 800];
            [1600, 1200];
            [1600, 1600];
            [1600, 2000];
            [2000, 0];
            [2000, 400];
            [2000, 800];
            [2000, 1200];
            [2000, 1600];
            [2000, 2000];
            [2400, 0];
            [2400, 400];
            [2400, 800];
            [2400, 1200];
            [2400, 1600];
            [2400, 2000];
            [2800, 0];
            [2800, 400];
            [2800, 800];
            [2800, 1200];
            [2800, 1600];
            [2800, 2000];
            [4000, 0];
            [4000, 400];
            [4000, 800];
            [4000, 1200];
            [4000, 1600];
            [4000, 2000];
            [4400, 0];
            [4400, 400];
            [4400, 800];
            [4400, 1200];
            [4400, 1600];
            [4400, 2000];
            [4800, 0];
            [4800, 400];
            [4800, 800];
            [4800, 1200];
            [4800, 1600];
            [4800, 2000];
            [5200, 0];
            [5200, 400];
            [5200, 800];
            [5200, 1200];
            [5200, 1600];
            [5200, 2000];
            [5600, 0];
            [5600, 400];
            [5600, 800];
            [5600, 1200];
            [5600, 1600];
            [5600, 2000];
            [6000, 0];
            [6000, 400];
            [6000, 800];
            [6000, 1200];
            [6000, 1600];
            [6000, 2000];
            [6400, 0];
            [6400, 400];
            [6400, 800];
            [6400, 1200];
            [6400, 1600];
            [6400, 2000];
            [6800, 0];
            [6800, 400];
            [6800, 800];
            [6800, 1200];
            [6800, 1600];
            [6800, 2000]];
        
        xcoords = coords(:,1);
        ycoords = coords(:,2);
        
        % Often, multi-shank probes or tetrodes will be organized into groups of
        % channels that cannot possibly share spikes with the rest of the probe. This helps
        % the algorithm discard noisy templates shared across groups. In
        % this case, we set kcoords to indicate which group the channel belongs to.
        % In our case all channels are on the same shank in a single group so we
        % assign them all to group 1.
        
        kcoords = 1:96;
        
        % at this point in Kilosort we do data = data(connected, :), ycoords =
        % ycoords(connected), xcoords = xcoords(connected) and kcoords =
        % kcoords(connected) and no more channel map information is needed (in particular
        % no "adjacency graphs" like in KlustaKwik).
        % Now we can save our channel map for the eMouse.
        
        % would be good to also save the sampling frequency here
        fs = 30000;
        
        if nargin==1
            save(fullfile(fpath, 'chanMap.mat'), 'chanMap', 'connected', 'xcoords', 'ycoords', 'kcoords', 'fs');
        else
            xcoords = (xcoords/400)  + 1;
            ycoords = (ycoords/400)  + 1;
        end
end