if ~exist('processzip'), processzip = 0; end

rootniifolder = [rootdatafolder slstr 'nii']; if ~isdir(rootniifolder), mkdir(rootniifolder); end
dirlist = [...
    dir([rootdatafolder slstr '*_str_*']);
    dir([rootdatafolder slstr '*_fun_*']);
    ];

for fid = 1:length(dirlist)
    
    currentfolder = dirlist(fid).name;
    seriesstr = currentfolder(1:4);
    
    if processzip == 0
        nvols = length(dir([rootdatafolder slstr currentfolder])) - 2;
        dicomfile = [rootdatafolder slstr currentfolder slstr seriesstr '_001.dcm'];
        fp = fopen(dicomfile, 'r'); xx = char(fread(fp))'; fclose(fp);
        yy = cellstr(xx); yy = yy{1}; pattern = 'tCoilID	= ""Head_'; q = strfind(yy, pattern); if isempty(q), pattern = 'tCoilID	 = 	""Head_'; q = strfind(yy, pattern); end
        xx = strsplit(yy(q(1):q(1)+30), '"'); coilinfo = strsplit(xx{2},' '); coilinfo = coilinfo{1}(1:7);
        info = dicominfo(dicomfile);
        protocolstr = info.ProtocolName;
        if isfield(info, 'Private_0019_1029')
            nslices = length(info.Private_0019_1029);
            TR = info.RepetitionTime/1000;
        else
            nslices = nvols;
            nvols = 1;
            TR = info.RepetitionTime/1000;
        end
        dirname = lower(sprintf('%s_%03dv_%03ds_tr%.3f_%.1fx%.1fx%.1fmm_%s_%s', seriesstr, nvols, nslices, TR, info.PixelSpacing(1), info.PixelSpacing(2), info.SliceThickness, coilinfo, protocolstr));
        movefile([rootdatafolder slstr currentfolder], [rootdatafolder slstr dirname]);
    else
        dirname = currentfolder;
    end
    
    niisrc = [rootdatafolder slstr dirname];
    cmdstr = ['dcm2nii -b .' slstr 'dcm2nii.ini -o ' rootniifolder ' ' niisrc];
    system(cmdstr);
    
    niifile = seriesstr;
    f = dir([rootniifolder slstr niifile '*.nii']);
    movefile([rootniifolder slstr f.name], [rootniifolder slstr dirname '.nii']);
end

fprintf('Copying mcf data...\n');
destfolder = [rootdatafolder slstr 'mcf']; if ~isdir(destfolder), mkdir(destfolder); end
copyfile([rootdatafolder slstr 'psy' slstr 'mcf*.mat'], destfolder);

fprintf('Renaming structural nii...\n');
f = dir([rootniifolder slstr '*_str_*.nii']);
movefile([rootniifolder slstr f.name], [rootniifolder slstr 'anat.nii']);

fprintf('Deleting functional test nii...\n');
f = dir([rootniifolder slstr '*_fun_*_pre.nii']);
delete([rootniifolder slstr f.name]);

if processzip == 0 & labsharedrive ~= 0
    fprintf('Zipping dicoms and experiment log...\n');
    zipfile = [rootdatafolder '.zip'];
    zip(zipfile, {'s0*', 'psy', '*.pdf'}, rootdatafolder);
    fprintf('Copying zipped file to the labshare...\n');
    copyfile(zipfile, [labsharedrive '/experiments/fMRI/data']);
end