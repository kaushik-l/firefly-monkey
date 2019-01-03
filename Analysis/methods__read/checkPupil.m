function filesPupil = checkPupil(monk_id, session_id)

% get file location
prs = getfileLocation(monk_id, session_id); % load prs
numFiles = 1:length(prs.filepath_behv); 
% read smr file
for i = 1:length(numFiles)
    cd(prs.filepath_behv{i})
    

    data= importSMR(filename)
% read channels

end 

% check for pupil diameter channel (lpd or rpd) or not and save the
% filename. 





