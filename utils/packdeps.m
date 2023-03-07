% ----------------------------------------------------------------------
% this function packs all the dependencies that are in the current
% folder and lib folder of the given m-file into a structure
% ----------------------------------------------------------------------
% depstr = packdeps(mfile, varargin)
%
% INPUTS
%  mfile  = name of the matlab file or list of mfilenames
%
% OPTONAL INPUTS
%  one argument for every variable indicated by a variable-name string to
%  be stored
%
% OUTPUTS
%  depstr = dependency structure, each field is named after the dependency
%           file name and the contents are the ascii characters of the file
%
% Usage: packdeps('testercode.m', 'screenNumber', 'path_id', 'windowRect', 'time')

% Change log
%     - 12/05/2017 (Georgin/Pramod/Zhivago) - first version
%     - 13/12/2017 (Zhivago/Pramod)         - updated to take list of mfiles and pack all of them

function depstr = packdeps(mfile, varargin)

if ~ischar(mfile), 
    flist = mfile; libflag = 0; 
else
    flist = matlab.codetools.requiredFilesAndProducts(mfile); libflag = 1;
end

for fid = 1:length(flist)
    f = flist{fid};
    [path, funcname, ext] = fileparts(f);
    if libflag & (~strcmp(ext, '.m') | (isempty(strfind(path, pwd)) & isempty(strfind(path, '/lib/')) & isempty(strfind(path, '\lib\')))), continue; end
    fprintf('adding %s\n', f);
    filestr = []; fp = fopen(f); while(~feof(fp)), str = fgets(fp); filestr = [filestr str]; end; fclose(fp);
    eval(['depstr.mfiles.' funcname ' = filestr;']);
end

% dealing with variables
nvars = length(varargin);
if nvars > 0
    for vid = 1:nvars
        eval(['depstr.vars.' varargin{vid} ' = evalin(''base'', varargin{vid});']);
    end
end

n = 0;
n = n + 1; depstr.fields{n,1} = 'mfiles = contains one field for each matlab script or function in the current folder and lib folder mfile depends on';
n = n + 1; depstr.fields{n,1} = 'vars = contains one field for each variable that was passed';

return