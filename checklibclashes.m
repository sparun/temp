%------------ FreeSurfer -----------------------------%
fshome = getenv('FREESURFER_HOME');
fsmatlab = sprintf('%s/matlab',fshome);
if (exist(fsmatlab) == 7)
    path(path,fsmatlab);
end
clear fshome fsmatlab;
%-----------------------------------------------------%

%------------ FreeSurfer FAST ------------------------%
fsfasthome = getenv('FSFAST_HOME');
fsfasttoolbox = sprintf('%s/toolbox',fsfasthome);
if (exist(fsfasttoolbox) == 7)
    path(path,fsfasttoolbox);
end
clear fsfasthome fsfasttoolbox;
%-----------------------------------------------------%

% checking if any of the visionlablib function names clash with other MATLAB/toolbox function names
xx = path; pathfolders = strsplit(xx, pathsep)';
slstr = '/'; if ispc, slstr = '\'; end
libstr = [slstr 'lib' slstr];
q = find(cellfun(@(x) ~isempty(x), strfind(pathfolders, libstr)));
libfolders = pathfolders(q);
cellfun(@(x) rmpath(x), libfolders);
libfiles = cell(0);
for folderid = 1:length(libfolders)
    xx = dir([libfolders{folderid,1} '/*.m']);
    xx = arrayfun(@(x) x.name, xx, 'UniformOutput', false);
    libfiles = [libfiles; xx];
end
clc; fprintf('Checking for lib filename clashes with MATLAB/toolbox...\n\n');
for fileid = 1:length(libfiles)
    clashfile = which(libfiles{fileid});
    xx = isempty(clashfile);    
    isabsent(fileid,1) = xx;
    if ~xx
        fprintf('%30s ---> %s\n', libfiles{fileid}, clashfile);
    end
end
if all(isabsent == 1), fprintf('\t\tno clashes found\n'); end
q = strfind(libfolders{1}, libstr) + 4;
addpath(genpath(libfolders{1}(1:q)));
savepath;
assert(all(isabsent == 1), 'some visionlablib function/script names clash with other MATLAB/toolbox function/script names')
%-----------------------------------------------------%

