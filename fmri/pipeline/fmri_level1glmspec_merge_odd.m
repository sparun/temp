clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
delete([glmfolder 'SPM.mat']);

files = dir([subjfolder, 'nii/', dataspec]);

% ODD
data = cell(0);
for rid = 1:2:length(files)
    nvols = length(spm_vol([subjfolder, 'nii/' files(rid).name]));
    for vid = 1:nvols
        data{end+1,1} = sprintf('%s/nii/%s,%d', subjfolder, files(rid).name, vid);
    end
end

fmcf = dir([subjfolder 'mcf/', mcfspec]);
frp = dir([subjfolder 'nii/', rpspec]);

batchid = batchid + 1;
matlabbatch{batchid}.spm.stats.fmri_spec.dir = {glmfolder};
matlabbatch{batchid}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{batchid}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{batchid}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{batchid}.spm.stats.fmri_spec.timing.fmri_t0 = 1;

matlabbatch{batchid}.spm.stats.fmri_spec.sess(1).scans = data;
matlabbatch{batchid}.spm.stats.fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
matlabbatch{batchid}.spm.stats.fmri_spec.sess(1).multi = {[subjfolder, 'mcf/', fmcf.name]};
matlabbatch{batchid}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
matlabbatch{batchid}.spm.stats.fmri_spec.sess(1).multi_reg = {[subjfolder, 'nii/', frp.name]};
matlabbatch{batchid}.spm.stats.fmri_spec.sess(1).hpf = 128;

matlabbatch{batchid}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{batchid}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{batchid}.spm.stats.fmri_spec.volt = 1;
matlabbatch{batchid}.spm.stats.fmri_spec.global = 'None';
matlabbatch{batchid}.spm.stats.fmri_spec.mask = {''};
matlabbatch{batchid}.spm.stats.fmri_spec.cvi = 'AR(1)';

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('serial', matlabbatch(batchid));
save(sprintf('%s/matlabbatch_%s_%s',[subjfolder, 'matlabbatch'], subjectid, starttime), 'matlabbatch');