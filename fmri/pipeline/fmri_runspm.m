% runspm   -> run standard visionlab pipeline for fMRI preprocessing

% PIPELINE STEPS
%    1. realign_estimate_reslice
%    2. slicetiming correction
%    3. coregister
%    4. segment
%    5. smooth localizer data
%    6. glmdenoise to remove extraneous spatial noise
%    7. estimate betas for merged-localizer-runs
%    8. estimate the following evtbetas
%           - single beta across all runs (for use in most standard analyses)
%           - single betas from even and odd runs separately (for splithalf correlation)
%           - single beta for each run (for use in decoding type analyses)
% NOTES
%    - Steps 5-8 are done for both subject-space and normalized-space
%    - For subject-space analyses, standard anatomical masks are transformed back into subject-space
%    - To run any step of the pipeline, comment out the other steps and run
%
% REFERENCES
%    See pipeline_report.doc for how/which preprocessing choices have been optimized
%
% REQUIRED TOOLBOXES
%     SPM        - http://www.fil.ion.ucl.ac.uk/spm/software/download/ [v12]
%     glmdenoise - http://kendrickkay.net/GLMdenoise/ [v1.4]
%                  SET line 531 opt.wantpercentbold = 0;
%     marsbar    - http://marsbar.sourceforge.net/download.html [v0.44]
% 
% Place appropriate fmri_level1glmcontrast.m in the experiment root folder before starting the pipeline

% ChangeLog:
%    13/12/2017 - Zhivago/Pramod/Aakash - first version
%    29/01/2018 - Aakash                - generating betas for merged block design

allclear; dbstop if error;
answer = inputdlg({'experiment name (case-sensitive)', 'number of slices per volume', 'TR (seconds)'}, 'experiment information');
if isempty(answer) | isempty(answer{1}) | isempty(answer{2}) | isempty(answer{3}), fprintf('*** please provide valid experiment information ***\n\n'); return; end
exptname = answer{1};
nslices = str2double(answer{2}); if isnan(nslices), fprintf('*** invalid number of slices specified ***\n\n'); return; end
TR = str2double(answer{3}); if isnan(TR), fprintf('*** invalid TR specified ***\n\n'); return; end

exptfolder = uigetdir('.', 'Select experiment root folder'); if ~exptfolder, return; end
exptfolder = strrep(exptfolder, '\', '/'); exptfolder = [exptfolder, '/'];
subjects = dir([exptfolder '*' exptname '*']);
starttime = datestr(now, 'yyyymmdd_HHMMSS');

fmri_mergemcfs;
spm fmri
for sid = 1:length(subjects)
    batchid = 0;
    
    xx = strsplit(subjects(sid).name, '_');
    subjectid = [xx{2} '_' xx{3}];
    
    % setting up folders
    subjfolder = [exptfolder subjects(sid).name, '/'];
    
    % denoised glm - subject space
    mkdir([subjfolder, 'glm/dnblkmerged']);
    mkdir([subjfolder, 'glm/dnevt']);
    mkdir([subjfolder, 'glm/dnevtmerged']);
    mkdir([subjfolder, 'glm/dnevtmergedeven']);
    mkdir([subjfolder, 'glm/dnevtmergedodd']);
    
    % denoised glm - normalized space
    mkdir([subjfolder, 'glm/wdnblkmerged']);
    mkdir([subjfolder, 'glm/wdnevt']);
    mkdir([subjfolder, 'glm/wdnevtmerged']);
    mkdir([subjfolder, 'glm/wdnevtmergedeven']);
    mkdir([subjfolder, 'glm/wdnevtmergedodd']);
    
    mkdir([subjfolder, 'mats']);
    mkdir([subjfolder, 'anatmasks']);
    mkdir([subjfolder, 'plots/denoise/blk']);
    mkdir([subjfolder, 'plots/denoise/evt']);
    mkdir([subjfolder, 'plots/denoise/wblk']);
    mkdir([subjfolder, 'plots/denoise/wevt']);
    mkdir([subjfolder, 'matlabbatch']);
    
    scantype = 'fun';    
    
    % preprocessing BLK & EVT runs together
    dataspec = 's0*.nii'; outprefix = 'r'; fmri_realign_estimatereslice; % motion correction
    dataspec = 'rs0*.nii'; outprefix = 'a'; fmri_slicetiming; % slice time correction
    dataspec = 'ars0*.nii'; fmri_coregister_estimate; % functional -> anatomical registration
    
    fmri_segment; % segmenting the anatomical image
    outprefix = 'w'; fmri_normalize_write_anat; % normalize the anatomical image
    
    dataspec = 'ars0*.nii'; outprefix = 'w'; fmri_normalize_write; % subject -> normalized space
    dataspec = 'ROI_*.nii'; outprefix = 'w'; fmri_normalize_write_inverse; % normalized -> subject space
    
    dataspec = 'ars0*blk*.nii'; outprefix = 's'; fmri_smooth; % subject space
    dataspec = 'wars0*blk*.nii'; outprefix = 's'; fmri_smooth; % normalized space
    
    % denoising individual BLK runs (merged runs never denoised)
    designtype = 'blk';
    dataspec = 'sars0*blk*.nii'; outprefix = 'd'; fmri_denoisedata; % subject space
    dataspec = 'swars0*blk*.nii'; outprefix = 'd'; fmri_denoisedata; % normalized space
    
    % merging motion parameters
    fmri_mergerps;
    
    % subject space glm & contrasts for BLK
    glmfolder = [subjfolder, '/glm/dnblkmerged/']; dataspec = 'dsars0*blk*.nii'; mcfspec = 'mergedmcf*blk*.mat'; rpspec = 'merged*blk*rp.txt';
    fmri_level1glmspec_merge; fmri_level1glmestimate; fmri_level1glmcontrasts; fmri_genblkbetas
    
    % normalized space space glm & contrasts for BLK
    glmfolder = [subjfolder, '/glm/wdnblkmerged/']; dataspec = 'dswars0*blk*.nii'; mcfspec = 'mergedmcf*blk*.mat'; rpspec = 'merged*blk*rp.txt';
    fmri_level1glmspec_merge; fmri_level1glmestimate; fmri_level1glmcontrasts; fmri_genblkbetas
    
    % denoising individual EVT runs (merged runs never denoised)
    designtype = 'evt';
    dataspec = 'ars0*evt*.nii'; outprefix = 'd'; fmri_denoisedata; % subject space
    dataspec = 'wars0*evt*.nii'; outprefix = 'd'; fmri_denoisedata; % normalized space
    
    % subject space glm for EVT
    glmfolder = [subjfolder, '/glm/dnevt/']; dataspec = 'dars0*evt*.nii'; mcfspec = 'mcf*evt*.mat'; rpspec = 'rp*evt*.txt';
    fmri_level1glmspec; fmri_level1glmestimate; fmri_genbetas;
    glmfolder = [subjfolder, '/glm/dnevtmerged/']; dataspec = 'dars0*evt*.nii'; mcfspec = 'mergedmcf*evt.mat'; rpspec = 'merged*evt*rp.txt';
    fmri_level1glmspec_merge; fmri_level1glmestimate; fmri_genbetas;
    glmfolder = [subjfolder, '/glm/dnevtmergedodd/']; dataspec = 'dars0*evt*.nii'; mcfspec = 'mergedmcf*evt*odd.mat'; rpspec = 'merged*evt*rp*odd.txt';
    fmri_level1glmspec_merge_odd; fmri_level1glmestimate; fmri_genbetas;
    glmfolder = [subjfolder, '/glm/dnevtmergedeven/']; dataspec = 'dars0*evt*.nii'; mcfspec = 'mergedmcf*evt*even.mat'; rpspec = 'merged*evt*rp*odd.txt';
    fmri_level1glmspec_merge_even; fmri_level1glmestimate; fmri_genbetas;
    fmri_gensplithalfmaps;
    
    % normalized space glm for EVT
    glmfolder = [subjfolder, '/glm/wdnevt/']; dataspec = 'dwars0*evt*.nii'; mcfspec = 'mcf*evt*.mat'; rpspec = 'rp*evt*.txt';
    fmri_level1glmspec; fmri_level1glmestimate; fmri_genbetas;
    glmfolder = [subjfolder, '/glm/wdnevtmerged/']; dataspec = 'dwars0*evt*.nii'; mcfspec = 'mergedmcf*evt.mat'; rpspec = 'merged*evt*rp.txt';
    fmri_level1glmspec_merge; fmri_level1glmestimate; fmri_genbetas;
    glmfolder = [subjfolder, '/glm/wdnevtmergedodd/']; dataspec = 'dwars0*evt*.nii'; mcfspec = 'mergedmcf*evt*odd.mat'; rpspec = 'merged*evt*rp*odd.txt';
    fmri_level1glmspec_merge_odd; fmri_level1glmestimate; fmri_genbetas;
    glmfolder = [subjfolder, '/glm/wdnevtmergedeven/']; dataspec = 'dwars0*evt*.nii'; mcfspec = 'mergedmcf*evt*even.mat'; rpspec = 'merged*evt*rp*odd.txt';
    fmri_level1glmspec_merge_even; fmri_level1glmestimate; fmri_genbetas;
    fmri_genwsplithalfmaps;    
    
    % resample all anatROIs to subject space dimensions
    maskfolder = [subjfolder '/anatmasks/']; templatefolder = [subjfolder '/glm/dnblkmerged/']; fmri_xformmasks;
    
    % diagnostics
    fmri_rundiag;
    
    % delete some glm folders
    rmdir([subjfolder, 'glm/dnevtmergedeven/'],'s');
    rmdir([subjfolder, '/glm/dnevtmergedodd/'],'s');
    rmdir([subjfolder, '/glm/wdnevtmergedeven/'],'s');
    rmdir([subjfolder, '/glm/wdnevtmergedodd/'],'s');
end
maskfolder = [exptfolder '/anatmasks/']; templatefolder = [subjfolder '/glm/wdnblkmerged/']; fmri_xformmasks;  

% bundling all the precprocessing codes used for this experiment
xx = which('visionlabfmripipelinelocator'); pipelinefolder = fileparts(xx);
pipelinefiles = dir([pipelinefolder '/fmri_*.m']); pipelinefiles = arrayfun(@(x) x.name, pipelinefiles, 'UniformOutput', false);
pipelinefiles = cellfun(@(x) which(x), pipelinefiles, 'UniformOutput', false);
xx = which('fmri_level1glmcontrasts'); pipelinefiles{end+1,1} = xx;
xx = which('packdeps'); pipelinefiles{end+1,1} = xx;
xx = which('unpackdeps'); pipelinefiles{end+1,1} = xx;

depstr = packdeps(pipelinefiles);
save([exptfolder exptname '_pipelinecodes'], 'depstr');
