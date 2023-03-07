clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
files = dir([subjfolder, 'nii/', dataspec]);

for rid = 1:length(files)
    nvols(rid) = length(spm_vol([subjfolder, 'nii/' files(rid).name]));
    for vid = 1:nvols(rid)
        data{rid,1}{vid,1} = sprintf('%s/nii/%s,%d', subjfolder, files(rid).name, vid);
    end
end

%%
batchid = batchid + 1;
matlabbatch{batchid}.spm.spatial.realign.estwrite.data = data;
matlabbatch{batchid}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{batchid}.spm.spatial.realign.estwrite.eoptions.sep = 3; % changed to 3mm from 4mm default
matlabbatch{batchid}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{batchid}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{batchid}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{batchid}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{batchid}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{batchid}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{batchid}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{batchid}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{batchid}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{batchid}.spm.spatial.realign.estwrite.roptions.prefix = outprefix;

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('serial', matlabbatch(batchid));
save(sprintf('%s/matlabbatch_%s_%s',[subjfolder, 'matlabbatch'], subjectid, starttime), 'matlabbatch');

hfall = get(0, 'Children'); qhf = find(cellfun(@length, cellfun(@(x) strfind(x, 'Graphics'), get(hfall, 'Name'), 'UniformOutput', false)));
figure(hfall(qhf)); set(gcf, 'Resize', 'on'); set(gcf, 'Units', 'normalized', 'Position', [0 0 1 1]);
export_fig([subjfolder 'plots/image_motion_' starttime  '.pdf'], '-native', '-nocrop');