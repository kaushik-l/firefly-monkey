function filesPupil = checkPupil(monk_id, session_id)
checkChannel = 1; 
% get file location
prs = getfileLocation(monk_id, session_id); % load prs
numFiles = 1:length(prs.filepath_behv); 
% read smr filess
for i = 1:length(numFiles)
    cd(prs.filepath_behv{i}); 
    %check for smr files (and just read the first one)
    flist_smr=dir('*.smr'); filename = flist_smr(1).name; 
    fprintf(['... reading ' flist_smr(1).name '\n']);
     % import channels 
    data_smr = ImportSMR(filename);
    % read channels and check for pupil diameter channel (lpd or rpd) or not and save the filename. 
    pupilChan = readChanSMR(data_smr,prs,checkChannel);
    cntFiles = 0;
    if ~isempty(pupilChan.LPd) | ~isempty(pupilChan.LPd)
        filesPupil.file{i} = filename; filesPupil.exist(i) = 1; 
        cntFiles = cntFiles+1; 
    else
         filesPupil.file{i} = filename; filesPupil.exist(i) = 0; 
    end
    filesPupil.totalCnt = cntFiles; 
end







