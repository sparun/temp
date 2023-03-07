clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder

f = dir([subjfolder, 'nii/y_anat.nii']);

batchid = batchid + 1;
matlabbatch{batchid}.spm.spatial.normalise.write.subj.def = {[subjfolder, 'nii/', f.name]};
matlabbatch{batchid}.spm.spatial.normalise.write.subj.resample = {[subjfolder, 'nii/manat.nii']};;
matlabbatch{batchid}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70; 78 76 85];
matlabbatch{batchid}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
matlabbatch{batchid}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{batchid}.spm.spatial.normalise.write.woptions.prefix = outprefix;

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('serial', matlabbatch(batchid));
save(sprintf('%s/matlabbatch_%s_%s',[subjfolder, 'matlabbatch'], subjectid, starttime), 'matlabbatch');