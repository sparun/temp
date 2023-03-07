clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
batchid = batchid + 1;
matlabbatch{batchid}.spm.stats.fmri_est.spmmat = {[glmfolder, 'SPM.mat']};
matlabbatch{batchid}.spm.stats.fmri_est.method.Classical = 1;
spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('serial', matlabbatch(batchid));
save(sprintf('%s/matlabbatch_%s_%s',[subjfolder, 'matlabbatch'], subjectid, starttime), 'matlabbatch');