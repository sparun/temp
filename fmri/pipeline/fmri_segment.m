clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
batchid = batchid + 1;
spmpath = fileparts(which('spm'));

spmfolder = fileparts(which('spm')); tpmfolder = [spmfolder '/tpm/']; 
matlabbatch{batchid}.spm.spatial.preproc.channel.vols = {[subjfolder, 'nii/anat.nii']};
matlabbatch{batchid}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{batchid}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{batchid}.spm.spatial.preproc.channel.write = [1 1];
matlabbatch{batchid}.spm.spatial.preproc.tissue(1).tpm = {[tpmfolder 'TPM.nii,1']};
matlabbatch{batchid}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{batchid}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{batchid}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{batchid}.spm.spatial.preproc.tissue(2).tpm = {[tpmfolder 'TPM.nii,2']};
matlabbatch{batchid}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{batchid}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{batchid}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{batchid}.spm.spatial.preproc.tissue(3).tpm = {[tpmfolder 'TPM.nii,3']};
matlabbatch{batchid}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{batchid}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{batchid}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{batchid}.spm.spatial.preproc.tissue(4).tpm = {[tpmfolder 'TPM.nii,4']};
matlabbatch{batchid}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{batchid}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{batchid}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{batchid}.spm.spatial.preproc.tissue(5).tpm = {[tpmfolder 'TPM.nii,5']};
matlabbatch{batchid}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{batchid}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{batchid}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{batchid}.spm.spatial.preproc.tissue(6).tpm = {[tpmfolder 'TPM.nii,6']};
matlabbatch{batchid}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{batchid}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{batchid}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{batchid}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{batchid}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{batchid}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{batchid}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{batchid}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{batchid}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{batchid}.spm.spatial.preproc.warp.write = [1 1];


spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('serial', matlabbatch(batchid));
save(sprintf('%s/matlabbatch_%s_%s',[subjfolder, 'matlabbatch'], subjectid, starttime), 'matlabbatch');
