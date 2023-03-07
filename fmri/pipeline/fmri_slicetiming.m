clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
files = dir([subjfolder, 'nii/', dataspec]);

for rid = 1:length(files)
    nvols(rid) = length(spm_vol([subjfolder, 'nii/' files(rid).name]));
    for vid = 1:nvols(rid)
        data{rid,1}{vid,1} = sprintf('%s/nii/%s,%d', subjfolder, files(rid).name, vid);
    end
end

batchid = batchid + 1;
matlabbatch{batchid}.spm.temporal.st.scans = data;
matlabbatch{batchid}.spm.temporal.st.nslices = nslices;
matlabbatch{batchid}.spm.temporal.st.tr = 2;
matlabbatch{batchid}.spm.temporal.st.ta = 2-(2/nslices);
matlabbatch{batchid}.spm.temporal.st.so = nslices:-1:1;
matlabbatch{batchid}.spm.temporal.st.refslice = round(nslices/2);
matlabbatch{batchid}.spm.temporal.st.prefix = outprefix;

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('serial', matlabbatch(batchid));
save(sprintf('%s/matlabbatch_%s_%s',[subjfolder, 'matlabbatch'], subjectid, starttime), 'matlabbatch');
