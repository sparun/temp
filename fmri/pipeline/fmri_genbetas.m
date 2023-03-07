clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
fprintf('generating betas...\n');

nruns = 8; f = dir([glmfolder 'beta*.nii']);
glmname = strsplit(glmfolder, '/'); if isempty(glmname{end}), glmname(end) = []; end

xx = strsplit(glmfolder, {'/', '\'}); xx = xx{end-1};
isindi = 1;
ismerged = strfind(xx, 'evtmerged'); if isempty(ismerged), ismerged = 0; else ismerged = 1; isindi = 0; end
iseo = [strfind(xx, 'evtmergedeven') strfind(xx, 'evtmergedodd')]; if isempty(iseo), iseo = 0; else iseo = 1; isindi = 0; ismerged = 0; end

nfiles = length(f) - isindi*nruns - iseo*nruns/2 - ismerged*nruns - (iseo|ismerged)*6;
denominator = (ismerged|iseo)*nfiles + isindi*(nfiles/nruns);
nevents = denominator - 6*isindi;

betas = [];
for fid = 1:nfiles
    fname = f(fid).name(1:end-4); xx = strsplit(fname, '_'); bid = str2double(xx{2});
    runid = ceil(bid/denominator);
    evtid = mod(bid,denominator);
    if evtid == 0, evtid = nevents; end
    if evtid > nevents, continue; end
    betas(:,evtid,runid) = vec(spm_read_vols(spm_vol([glmfolder f(fid).name])));
end

save(sprintf('%s/mats/%s_%s_betas', subjfolder, subjectid, glmname{end}), 'betas');

