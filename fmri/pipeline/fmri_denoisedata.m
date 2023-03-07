clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
fprintf('denoising data...\n');

mcfs = dir([subjfolder, '/mcf/mcf*' designtype '*.mat']);
niis = dir([subjfolder, 'nii/', dataspec]);

prefix = ''; if dataspec(1) == 'w' | dataspec(2) == 'w', prefix = 'w'; end
if strcmpi(designtype, 'evt')
    stimdur = 0.3;
    figfolder = [subjfolder, 'plots/denoise/' prefix 'evt'];
else    
    stimdur = 12;
    figfolder = [subjfolder, 'plots/denoise/' prefix 'blk'];
end

design = cell(0); data = cell(0);

for i = 1:numel(mcfs)
    load([subjfolder,'/mcf/',mcfs(i).name]);    
    design{i} = onsets;
end

for  i = 1:numel(niis)
    data{i} =  single(spm_read_vols(spm_vol([subjfolder, '/nii/', niis(i).name])));
end

[results,denoiseddata] = GLMdenoisedata(design,data,stimdur,TR,'assume',[],[],strrep(figfolder,'/','\'));
beta = results.modelmd{2}; beta_se = results.modelse{2};
save([subjfolder 'mats/' subjects(sid).name '_' prefix designtype '_denoised_betas'], 'beta', 'beta_se')

for  i = 1:numel(niis)
    temp = spm_vol([subjfolder,'/nii/',niis(i).name]);
    for vol = 1:length(temp)
        temp(vol).fname = [subjfolder, '/nii/d', niis(i).name];
        spm_write_vol(temp(vol), denoiseddata{i}(:,:,:,vol));
    end
end