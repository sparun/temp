clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
files = dir([subjfolder, 'nii/', dataspec]);

data = cell(0);
for rid = 1:length(files)
    nvols(rid) = length(spm_vol([subjfolder, 'nii/' files(rid).name]));
    for vid = 1:nvols(rid)
        data{end+1,1} = sprintf('%s/nii/%s,%d', subjfolder, files(rid).name, vid);
    end
end

batchid = batchid + 1;
matlabbatch{batchid}.spm.spatial.smooth.data = data;
matlabbatch{batchid}.spm.spatial.smooth.fwhm = [5 5 5];
matlabbatch{batchid}.spm.spatial.smooth.dtype = 0;
matlabbatch{batchid}.spm.spatial.smooth.im = 0;
matlabbatch{batchid}.spm.spatial.smooth.prefix = 's';

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('serial', matlabbatch(batchid));
save(sprintf('%s/matlabbatch_%s_%s',[subjfolder, 'matlabbatch'], subjectid, starttime), 'matlabbatch');
