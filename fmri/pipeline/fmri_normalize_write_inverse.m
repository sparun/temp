clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
files = dir([exptfolder '/anatmasks/' dataspec]);

data = cell(0);
for niis = 1:numel(files)
    data{end+1,1} = sprintf('%s/anatmasks/%s,%d', exptfolder, files(niis).name, 1);
end

f = dir([subjfolder, 'nii/iy_anat.nii']);

batchid = batchid + 1;
matlabbatch{batchid}.spm.spatial.normalise.write.subj.def = {[subjfolder, 'nii/', f.name]};
matlabbatch{batchid}.spm.spatial.normalise.write.subj.resample = data;
matlabbatch{batchid}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70; 78 76 85];
matlabbatch{batchid}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
matlabbatch{batchid}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{batchid}.spm.spatial.normalise.write.woptions.prefix = outprefix;

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('serial', matlabbatch(batchid));
save(sprintf('%s/matlabbatch_%s_%s',[subjfolder, 'matlabbatch'], subjectid, starttime), 'matlabbatch');

% move the antamasks to subject folder
movefile([exptfolder '/anatmasks/wROI_*.nii'],[subjfolder '/anatmasks/']);
