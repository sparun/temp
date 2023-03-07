clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder

f = dir([subjfolder '/nii/rp_s0*_blk_*.txt']);
nruns = length(f);
rpc = [];
for fid = 1:nruns
    rp = load([subjfolder '/nii/' f(fid).name]);
    rp = zscore(rp);
    nvols = size(rp,1); xx = zeros(nvols,1); if fid < 2, xx(:,fid) = 1; end
    rpc = [rpc; rp xx];
end
save([subjfolder '/nii/merged_blk_rp.txt'], 'rpc', '-ascii','-double');

f = dir([subjfolder '/nii/rp_s0*_evt_*.txt']);
nruns = length(f);
rpc = [];
for fid = 1:nruns
    rp = load([subjfolder '/nii/' f(fid).name]);
    rp = zscore(rp);
    nvols = size(rp,1); xx = zeros(nvols,7); if fid < 8, xx(:,fid) = 1; end
    rpc = [rpc; rp xx];
end
save([subjfolder '/nii/merged_evt_rp.txt'], 'rpc', '-ascii','-double');

for eo = 1:2
    cnt = 1; rpc = [];
    for fid = eo:2:nruns
        rp = load([subjfolder '/nii/' f(fid).name]);
        rp = zscore(rp);
        nvols = size(rp,1); xx = zeros(nvols,3); if cnt < 4, xx(:,cnt) = 1; end
        rpc = [rpc; rp xx]; cnt = cnt +1;
    end
    if eo == 1
        save([subjfolder '/nii/merged_evt_rp_odd.txt'], 'rpc', '-ascii','-double');
    else
        save([subjfolder '/nii/merged_evt_rp_even.txt'], 'rpc', '-ascii','-double');
    end
end