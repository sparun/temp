clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder

fanat = dir([maskfolder '*.nii']);
for roi = 1:numel(fanat)
    % creating matrix
    mask_mat = maroi_image(struct('vol', spm_vol([maskfolder fanat(roi).name]), 'binarize',1, 'func', ''));
    mask_mat = maroi_matrix(mask_mat);
    
    % saving back as nii
    template = spm_vol([templatefolder 'mask.nii']);
    mars_rois2img(mask_mat, [maskfolder fanat(roi).name], template, 'none');
end
