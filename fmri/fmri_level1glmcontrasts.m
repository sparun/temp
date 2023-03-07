% LEVEL1 GLM CONTRASTS FOR READING EXPERIMENT
% MODIFY AS REQUIRED FOR YOUR EXPERIMENT

clearvars -except batchid matlabbatch starttime exptfolder subjfolder glmfolder designtype scantype subjectid nslices TR subjects sid dataspec outprefix mcfspec rpspec  maskfolder templatefolder
batchid = batchid + 1; 
matlabbatch{batchid}.spm.stats.con.spmmat = {[glmfolder, 'SPM.mat']};

n = 0;

% [F O S Scr Fix]
n = n + 1;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.name = 'scramobjects-fixation';
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.convec = [0 0 0 0 1 0 -1]/2;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.sessrep = 'repl';
n = n + 1;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.name = 'objects-scramobjects';
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.convec = [0 0 1 0 -1 0 0]/2;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.sessrep = 'repl';
n = n + 1;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.name = 'engwords-scrambled';
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.convec = [1 0 0 -1 0 0 0]/2;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.sessrep = 'repl';
n = n + 1;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.name = 'telwords-scrambled';
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.convec = [0 0 0 -1 0 1 0]/2;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.sessrep = 'repl';
n = n + 1;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.name = 'malwords-scrambled';
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.convec = [0 1 0 -1 0 0 0]/2;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.sessrep = 'repl';
n = n + 1;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.name = 'malwords-telwords';
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.convec = [0 1 0 0 0 -1 0]/2;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.sessrep = 'repl';
n = n + 1;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.name = 'telwords-malwords';
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.convec = [0 -1 0 0 0 1 0]/2;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.sessrep = 'repl';
n = n + 1;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.name = 'engwords-malwords';
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.convec = [1 -1 0 0 0 0 0]/2;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.sessrep = 'repl';
n = n + 1;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.name = 'engwords-telwords';
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.convec = [1 0 0 0 0 -1 0]/2;
matlabbatch{batchid}.spm.stats.con.consess{n}.tcon.sessrep = 'repl';
n = n + 1;


matlabbatch{batchid}.spm.stats.con.delete = 1;

% print results
matlabbatch{batchid}.spm.stats.results.spmmat = {[glmfolder, 'SPM.mat']};
matlabbatch{batchid}.spm.stats.results.conspec.titlestr = '';
matlabbatch{batchid}.spm.stats.results.conspec.contrasts = Inf; % for all contrasts (or enter number vector for subset)
matlabbatch{batchid}.spm.stats.results.conspec.threshdesc = 'FWE'; % <-uncorrected % 'FWE';
matlabbatch{batchid}.spm.stats.results.conspec.thresh = 0.05; %  <- for uncorrected % 0.05;
matlabbatch{batchid}.spm.stats.results.conspec.extent = 20;
matlabbatch{batchid}.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
matlabbatch{batchid}.spm.stats.results.units = 1;
matlabbatch{batchid}.spm.stats.results.print = 'pdf';

f = dir([glmfolder '*.ps']);
for fid = 1:length(f)
    system(['ps2pdf "' glmfolder f(fid).name '"  "' glmfolder subjectid '_' f(fid).name(1:end-3) '.pdf"']);
end

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('serial', matlabbatch(batchid));
save(sprintf('%s/matlabbatch_%s_%s',[subjfolder, 'matlabbatch'], subjectid, starttime), 'matlabbatch');
