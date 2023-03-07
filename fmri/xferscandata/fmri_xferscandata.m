allclear; dbstop if error;
if ispc , slstr = '\'; else slstr = '/'; end

dicomfolder = uigetdir('.', 'Select DICOM root folder');
if ~dicomfolder, return; end

labsharedrive = uigetdir('.', 'Select labshare drive if you want to transfer data (eg. Z:)');
if labsharedrive ~= 0 & ispc, labsharedrive = labsharedrive(1:2); end

psyfolder = uigetdir('.', 'Select PSY folder');
if ~psyfolder, return; end

[exptlogfile, exptlogpath] = uigetfile('*.pdf', 'Select Experiment Log PDF');
if exptlogfile, exptlogfile = [exptlogpath exptlogfile]; end

% flattening the dicom folder structure
clear global folderlist counter;
global folderlist counter;
folderlist = [];
counter = 1;
findendfolders(dicomfolder);
tmpfolder = ['.' slstr 'tmp_' datestr(now, 'yyyymmdd_HHMMSS')]; if ~isdir(tmpfolder), mkdir(tmpfolder); end
for fid = 1:length(folderlist)
    fprintf('\t copying folder: %s\n', folderlist{fid});
    copyfile(folderlist{fid}, tmpfolder);
end
originaldicoms = dir([tmpfolder]); originaldicoms(1:2) = [];

% extracting patient, study, and coil information from dicoms before anonymization
info = dicominfo([tmpfolder slstr originaldicoms(1).name]);
% patientname = info.PatientName.FamilyName;
patientid = info.PatientID;
% patientage = info.PatientAge;
% patientsex = info.PatientSex;
% patientweigth = info.PatientWeight;
studydate = info.StudyDate;
studyid = info.StudyDescription;
fp = fopen([tmpfolder slstr originaldicoms(1).name], 'r'); xx = char(fread(fp))'; fclose(fp);
yy = cellstr(xx); yy = yy{1}; pattern = 'tCoilID	= ""Head_'; q = strfind(yy, pattern); if isempty(q), pattern = 'tCoilID	 = 	""Head_'; q = strfind(yy, pattern); end
xx = strsplit(yy(q(1):q(1)+30), '"'); coilinfo = strsplit(xx{2},' '); coilinfo = coilinfo{1}(1:7);

rootdatafolder = [pwd slstr studydate '_' studyid '_' patientid];
if ~isdir(rootdatafolder), mkdir(rootdatafolder); end

% anonymize dicoms
cmdstr = ['dcm2nii -b dcmanon.ini ' tmpfolder]; system(cmdstr);

for fid = 1:length(originaldicoms)
    delete([tmpfolder slstr originaldicoms(fid).name]);
end

% renaming dicom folders and generating nii
flist = dir(tmpfolder); flist(1:2) = [];
for fid = 1:length(flist)
    oldname = [tmpfolder slstr flist(fid).name];
    info = dicominfo(oldname);    
    protocol = info.ProtocolName; protocol(protocol == '(') = '_'; protocol(protocol == ')') = '_';
    imagetype = info.ImageType;
    seriesid = info.SeriesNumber;
    nslices = -1;
    if isfield(info, 'Private_0019_1029')
        nslices = length(info.Private_0019_1029);
    end
    volumeid = info.InstanceNumber;
    
    newname = sprintf('s%03d_%03d.dcm', seriesid, volumeid);
    destfolder = [rootdatafolder slstr num2str(seriesid,'s%03d_') protocol];
    if ~isdir(destfolder), mkdir(destfolder); end
    movefile(oldname, [destfolder slstr newname]);
    
    fprintf('\t\tsorted %s\n', oldname);
end
rmdir(tmpfolder);

fprintf('Copying psy data...\n');
destfolder = [rootdatafolder slstr 'psy'];
if ~isdir(destfolder), mkdir(destfolder); end
copyfile([psyfolder slstr 'mcf_*.mat'], destfolder);
copyfile([psyfolder slstr 'exptstr_*.mat'], destfolder);

if exptlogfile
    fprintf('Copying experiment log to the dicom folder...\n');
    copyfile(exptlogfile, rootdatafolder);
end

fmri_postxfer;

fprintf('Done!\n');
