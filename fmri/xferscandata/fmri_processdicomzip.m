allclear; dbstop if error;
if ispc , slstr = '\'; else slstr = '/'; end
processzip = 1;
[files,datafolder] = uigetfile('z:\experiments\fMRI\03_data\*.zip', 'Select files to unzip','MultiSelect', 'On'); 
zipdestfolder = uigetdir('.', 'Select destination data folder');

if ~iscell(files), datafiles{1} = files; else datafiles = files; end

fprintf('*** Processing %d data files\n\n',length(datafiles)); 
for i = 1:length(datafiles)
    dicomzip = [datafolder '\' datafiles{i}]; 
    fprintf('Processing %s \n',dicomzip); 
    [path, fname, ext] = fileparts(dicomzip);
    rootdatafolder = [zipdestfolder slstr fname]; 
    mkdir(rootdatafolder);
    fprintf('Unzipping dicom...\n');
    unzip(dicomzip,rootdatafolder);
    fmri_postxfer;
    f = [dir([rootdatafolder slstr 'psy*']); dir([rootdatafolder slstr 's0*'])];
    fprintf('Removing dicom and psy folders...\n'); % not removing the experiment log
    arrayfun(@(x) rmdir([rootdatafolder slstr x.name], 's'), f, 'UniformOutput', false);    
end
