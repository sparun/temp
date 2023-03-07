clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder

fprintf('generating diagnostics...\n');

files = dir([subjfolder, 'nii/dars*_', scantype, '_*.nii']);
data = cell(0);
for rid = 1:length(files)
    xx = strsplit(files(rid).name, '_');
    nvols(rid) = sscanf(xx{2}, '%03dv');
    for vid = 1:nvols(rid)
        data{end+1,1} = sprintf('%s/nii/%s,%d', subjfolder, files(rid).name, vid);
    end
end
PI = char(data);

niifolder = [exptfolder subjects(sid).name '/nii/'];
plotsfolder = [exptfolder subjects(sid).name '/plots/'];
fmri_gensnrmaps;


f = dir([niifolder 'dsars*_blk_*.nii']);
for rid = 1:length(f)
    V = spm_vol([niifolder f(rid).name]);
    vols = spm_read_vols(V);
    blkvols(rid,:,:,:,:) = vols;
end

f = dir([niifolder 'dars*_evt_*.nii']);
for rid = 1:length(f)
    V = spm_vol([niifolder f(rid).name]);
    vols = spm_read_vols(V);
    evtvols(rid,:,:,:,:) = vols;
end

% for each loc run
figure;
vols = blkvols; % 5D: nruns x 3D image x nvols
sz = size(vols);
xx = reshape(vols, sz(1), prod(sz(2:4)), sz(5));
tc = squeeze(nanmean(xx,2))'; sem = squeeze(nansem(xx,2));
% tc = zscore(tc);
for rid = 1:size(vols,1)
    subplot(2,1,rid);
    timecourse = tc(:,rid);
    shadedErrorBar(1:length(timecourse), vec(timecourse), vec(sem(rid,:)), '-k');
    title(['BLK timecourse for ' num2str(rid, '%02d')]);
end
set(gcf, 'Units', 'normalized', 'Position', [0 0 1 1]);
export_fig([plotsfolder subjectid '_blk_runtimecourse.pdf'], '-native', '-nocrop');
delete(gcf);

% for each evt run
figure;
vols = evtvols; % 5D: nruns x 3D image x nvols
sz = size(vols);
xx = reshape(vols, sz(1), prod(sz(2:4)), sz(5));
tc = squeeze(nanmean(xx,2))'; sem = squeeze(nansem(xx,2));
% tc = zscore(tc);
for rid = 1:size(vols,1)
    subplot(2,4,rid);
    timecourse = tc(:,rid);
    shadedErrorBar(1:length(timecourse), vec(timecourse), vec(sem(rid,:)), '-k');
    title(['EVT timecourse for ' num2str(rid, '%02d')]);
end
set(gcf, 'Units', 'normalized', 'Position', [0 0 1 1]);
export_fig([plotsfolder subjectid '_evt_runtimecourse.pdf'], '-native', '-nocrop');
delete(gcf);

figure;
subplot(2,1,1);
vols = blkvols;
xx = squeeze(nanmean(nanmean(nanmean(vols,4),3),2)); xx = zscore(xx');
meantimecourse = nanmean(xx,2); semtimecourse = nansem(xx,2);
shadedErrorBar(1:length(meantimecourse), meantimecourse, semtimecourse, '-k');
title('mean BLK timecourse');

subplot(2,1,2);
vols = evtvols;
xx = squeeze(nanmean(nanmean(nanmean(vols,4),3),2)); xx = zscore(xx');
meantimecourse = nanmean(xx,2); semtimecourse = nansem(xx,2);
shadedErrorBar(1:length(meantimecourse), meantimecourse, semtimecourse, '-k');
title('mean EVT timecourse');

set(gcf, 'Units', 'normalized', 'Position', [0 0 1 1]);
export_fig([plotsfolder subjectid '_timecourse.pdf'], '-native', '-nocrop');
delete(gcf);

f = dir([niifolder '*_map_*.nii']);
for rid = 1:length(f)
    xx = strsplit(f(rid).name, {'_', '.'});
    vols = spm_read_vols(spm_vol([niifolder f(rid).name]));
    manyimagesc(vols); colormap(redbluemap); colorbar;
    set(gcf, 'Units', 'normalized', 'Position', [0 0 1 1]);
    global_title([], [], [subjectid ' -- ' xx{end-1}]);
    export_fig([plotsfolder subjectid '_signalmap_' xx{end-1} '.pdf'], '-native', '-nocrop');
    delete(gcf);
end

% subplot(3,3,7); imshow(squeeze(nanmean(meantsnr,1)), []); colormap(redbluemap);
% subplot(3,3,8); imshow(squeeze(nanmean(meantsnr,2)), []); colormap(redbluemap);
% subplot(3,3,9); imshow(squeeze(nanmean(meantsnr,3)), []); colormap(redbluemap);


