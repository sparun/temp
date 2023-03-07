clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
% from individual run betas
f = dir([subjfolder '/mats/*_dnevt_betas.mat']);
load([subjfolder '/mats/' f.name]);
nvox = size(betas,1);
nruns = size(betas,3);
fprintf('generating splithalf corrmap for %s...\n',subjectid);
for vid = 1:nvox
    evenrun = squeeze(betas(vid,:,2:2:nruns)); evenrun = nanmean(evenrun,2);
    oddrun = squeeze(betas(vid,:,1:2:nruns)); oddrun = nanmean(oddrun,2);
    [shcorrmap(vid,1), shsigmap(vid,1)] = nancorrcoef(evenrun,oddrun);
end
xx = strsplit(f.name,'_');
save(sprintf('%s/mats/%s_%s_shmaps', subjfolder, subjectid, xx{3}), 'shcorrmap','shsigmap');

% from merged odd/even betas
f = dir([subjfolder '/mats/*_dnevtmergedeven_betas.mat']);
load([subjfolder '/mats/' f.name]); evenbetas = betas;
f = dir([subjfolder '/mats/*_dnevtmergedodd_betas.mat']);
load([subjfolder '/mats/' f.name]); oddbetas = betas;

nvox = size(betas,1);
fprintf('generating splithalf corrmap for %s...\n',subjectid);
for vid = 1:nvox
    [oeshcorrmap(vid,1), oeshsigmap(vid,1)] = nancorrcoef(evenbetas(vid,:),oddbetas(vid,:));
end
save(sprintf('%s/mats/%s_dnevtmerged_shmaps', subjfolder, subjectid), 'oeshcorrmap','oeshsigmap');
