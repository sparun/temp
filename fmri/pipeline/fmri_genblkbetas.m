clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices subjects sid denoiseflag
fprintf('generating betas...\n');

nruns = 2; f = dir([glmfolder 'beta*.nii']);
glmname = strsplit(glmfolder, '/'); if isempty(glmname{end}), glmname(end) = []; end

xx = strsplit(glmfolder, {'/', '\'}); xx = xx{end-1};
nfiles = length(f) - nruns - 6;

betas = [];
for fid = 1:nfiles
    fname = f(fid).name(1:end-4); 
    betas(:,fid) = vec(spm_read_vols(spm_vol([glmfolder f(fid).name])));
end

save(sprintf('%s/mats/%s_%s_betas', subjfolder, subjectid, glmname{end}), 'betas');

