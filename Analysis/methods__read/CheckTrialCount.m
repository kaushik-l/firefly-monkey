prs = default_prs(44,1);
cd('Y:\Data\MOOG\Quigley\Utah array')
flist = dir;
row = 1; col = 0;
for i=1:length(flist)
    if all(length(flist(i).name) > 4)
        if flist(i).name(end-3:end) == '2017'
            cd(flist(i).name); foldername = dir('beha*'); cd(foldername.name);
            trials = []; % initialise
            %% list all files to read
            flist_log=dir('*.log');
            for i=1:length(flist_log), fnum_log(i) = str2num(flist_log(i).name(end-6:end-4)); end
            flist_smr=dir('*.smr');
            for i=1:length(flist_smr), fnum_smr(i) = str2num(flist_smr(i).name(end-6:end-4)); end
            flist_mat=dir('*.mat');
            for i=1:length(flist_mat), fnum_mat(i) = str2num(flist_mat(i).name(end-6:end-4)); end
            nfiles = length(flist_log);
            
            %% read files
            for i=1:nfiles
                fprintf(['... reading ' flist_log(i).name '\n']);
                % read .log file
                trials_log = AddLOGData(flist_log(i).name);
                % read all .smr files associated with this log file
                if i<nfiles, indx_smr = find(fnum_smr >= fnum_log(i) & fnum_smr < fnum_log(i+1));
                else indx_smr = find(fnum_smr >= fnum_log(i)); end
                trials_smr = [];
                for j = indx_smr
                    fprintf(['... reading ' flist_smr(j).name '\n']);
                    data_smr = ImportSMR(flist_smr(j).name);
                    trials_smr = [trials_smr AddSMRData(data_smr,prs)];
                end
                % add contents of .mat file
                fprintf(['... reading ' flist_mat(i).name '\n']);
                MATData = load(flist_mat(i).name);
                ntrls_log = length(trials_log);
                ntrls_smr = length(trials_smr);
                ntrls_mat = length(MATData.events.t_end);
                
                cd('Y:\Data\MOOG\Quigley');
%                 csvwrite('CheckTrialCount.csv',[str2num(flist_log(i).name(end-6:end-4)), ntrls_log, ntrls_smr, ntrls_mat],row,col);
                dlmwrite('test.csv',[str2num(flist_log(i).name(end-6:end-4)), ntrls_log, ntrls_smr, ntrls_mat],'delimiter',',','-append');
                row = row + 1;
                cd('Y:\Data\MOOG\Quigley\Utah array');
            end
        end
    end
end
