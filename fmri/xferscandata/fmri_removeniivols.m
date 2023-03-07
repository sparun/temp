function fmri_removeniivols(niifilespec, qremvols)
f = dir(niifilespec);
[folder, ~, ~] = fileparts(niifilespec);
for fid = 1:length(f)
    V = fmri_load_nifti([folder '/' f(fid).name]);    
    if size(V.vol,4) == 1, continue; end
    oldvolstr = num2str(size(V.vol,4), '_%03dv_');
    qvols = setdiff(1:size(V.vol,4), qremvols);
    V.vol = V.vol(:,:,:,qvols);
    newvolstr = num2str(length(qvols), '_%03dv_');
    xx = strrep(f(fid).name, oldvolstr, newvolstr);
    [~, name, ext] = fileparts(xx);
    newfname = [folder '/' name '_volsremoved' ext];
    fmri_save_nifti(V, newfname);
end
end