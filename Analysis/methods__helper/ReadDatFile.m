function [data,startsample] = ReadDatFile(fname,nch,nsamples,precision,startsample)

%% open file
fid = fopen(fname,'r');

%% determine file size
fseek(fid, 0, 'eof');
datfilesize = ftell(fid);
maxstartsample = (datfilesize - (nch*nsamples))/nch;
fseek(fid, 0, 'bof');

%% select the position to begin reading
if nargin<5, startsample = round(rand*maxstartsample)*nch; end
sts = fseek(fid, round(startsample), 0);
if sts, fprintf('unable to start reading file at the specified sample'); return; end

%% read data
data = fread(fid,nch*nsamples,precision);
data = reshape(data,[nch nsamples]);

%% close file
fclose(fid);