clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
delete([glmfolder 'SPM.mat']);


files = dir([subjfolder, 'nii/', dataspec]);

for rid = 1:length(files)
    nvols(rid) = length(spm_vol([subjfolder, 'nii/' files(rid).name]));
    for vid = 1:nvols(rid)
        data{rid,1}{vid,1} = sprintf('%s/nii/%s,%d', subjfolder, files(rid).name, vid);
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

for rid = 1:size(data,1)
    matlabbatch{batchid}.spm.stats.fmri_spec.sess(rid).scans = data{rid};
    matlabbatch{batchid}.spm.stats.fmri_spec.sess(rid).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
    matlabbatch{batchid}.spm.stats.fmri_spec.sess(rid).multi = {[subjfolder, 'mcf/', fmcf(rid).name]};
    matlabbatch{batchid}.spm.stats.fmri_spec.sess(rid).regress = struct('name', {}, 'val', {});
    matlabbatch{batchid}.spm.stats.fmri_spec.sess(rid).multi_reg = {[subjfolder, 'nii/', frp(rid).name]};
    matlabbatch{batchid}.spm.stats.fmri_spec.sess(rid).hpf = 128;
end

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

% xx = strsplit(glmfolder, '/'); glmtype = xx{end-1};
% hfall = get(0, 'Children'); qhf = find(cellfun(@length, cellfun(@(x) strfind(x, 'Graphics'), get(hfall, 'Name'), 'UniformOutput', false)));
% figure(hfall(qhf)); set(gcf, 'Resize', 'on'); set(gcf, 'Units', 'normalized', 'Position', [0 0 1 1]);
% export_fig([subjfolder 'plots/glmspec_' glmtype '_' starttime  '.pdf'], '-native', '-nocrop');
