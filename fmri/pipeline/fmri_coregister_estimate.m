clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
files = dir([subjfolder, 'nii/', dataspec]);

data = cell(0);
for rid = 1:length(files)
    nvols(rid) = length(spm_vol([subjfolder, 'nii/' files(rid).name]));
    for vid = 1:nvols(rid)
        data{end+1,1} = sprintf('%s/nii/%s,%d', subjfolder, files(rid).name, vid);
    end
end

spmdir = which('spm'); spmdir = spmdir(1:end-6); spmdir = strrep(spmdir, '\', '/');
meanepi = dir([subjfolder, 'nii/means*_', scantype, '_*.nii']);
anat = [subjfolder, 'nii/anat.nii'];

batchid = batchid + 1;
matlabbatch{batchid}.spm.spatial.coreg.estimate.ref = {anat};
matlabbatch{batchid}.spm.spatial.coreg.estimate.source = {[subjfolder, 'nii/' meanepi.name]};
matlabbatch{batchid}.spm.spatial.coreg.estimate.other = data;
matlabbatch{batchid}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{batchid}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{batchid}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{batchid}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('serial', matlabbatch(batchid));
save(sprintf('%s/matlabbatch_%s_%s', [subjfolder, 'matlabbatch'], subjectid, starttime), 'matlabbatch');

hfall = get(0, 'Children'); qhf = find(cellfun(@length, cellfun(@(x) strfind(x, 'Graphics'), get(hfall, 'Name'), 'UniformOutput', false)));
figure(hfall(qhf)); set(gcf, 'Resize', 'on'); set(gcf, 'Units', 'normalized', 'Position', [0 0 1 1]);
export_fig([subjfolder 'plots/coregistration_' starttime  '.pdf'], '-native', '-nocrop');