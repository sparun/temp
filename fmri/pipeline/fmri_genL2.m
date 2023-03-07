% generates L2_str for a given fMRI experiment
% 
% Before running this code
%       - generate functional ROIs for subject- and normal-space data separately and store them under 
%         'subjfolder/froimasks/subjectspace/' or 'subjfolder/froimasks/normalspace/' respectively
%       - create separate xls files for subject- and normal-space fROIs with columns 
%         SUBJECTID, CONTRASTNAMES, FROINAMES, ISFWE, PTHRESH, CLUSTEREXTENT
%         [CONTRASTNAMES should match that used in level1glmcontrasts.m & FROINAMES should be same as the ROI filenames]  
%         naming convention for xls files: 'exptname_frois' for subject-space and 'exptname_wfrois' for normal-space data 
%         Example file: 1) SYM_frois.xlsx  - functional ROIs for SYM experiment in subject-space
%                       2) SYM_wfrois.xlsx - functional ROIs for SYM experiment in normal-space
%       - copy 'eventimages.mat' used during the scan session to the root experiment folder
%
% Run this script separately for subject-space and normal-space data 
%
% ChangeLog
%    02/01/2018 - Pramod/Aakash/Zhivago - first version 
%    29/01/2018 - Aakash                - added names and betas of merged block design

allclear; dbstop if error;

answer = inputdlg({'experiment name', 'normalize prefix (type w for normalized space, leave empty otherwise)'}, 'experiment information');
exptname = answer{1};
normprefix = answer{2};

exptfolder = uigetdir('.', 'Select experiment root folder'); if ~exptfolder, return; end
exptfolder = strrep(exptfolder, '\', '/'); exptfolder = [exptfolder, '/'];
subjects = dir([exptfolder '*' '_' exptname '_' '*']);
load([exptfolder 'evtimages']);

L2_str = fmri_getL2def; % initialize all fields
L2_str.expt_name = exptname;
L2_str.images = images;

for sid = 1:length(subjects)    
    subjfolder = [exptfolder subjects(sid).name, '/'];
    fprintf('processing (%02d/%02d) %s\n', sid, length(subjects), subjfolder);
    
    fnii = [subjfolder 'nii/'];
    fblkm = [subjfolder 'glm/' normprefix 'dnblkmerged/'];
    fevt = [subjfolder 'glm/' normprefix 'dnevt/'];
    fevtm = [subjfolder 'glm/' normprefix 'dnevtmerged/'];
    fmats = [subjfolder 'mats/'];
    if isempty(normprefix), fanatmasks = [subjfolder 'anatmasks/']; else fanatmasks = ['./anatmasks/']; end % anatomical masks 
    if isempty(normprefix), ffroimasks = [subjfolder 'froimasks/subjectspace/']; else ffroimasks = [subjfolder 'froimasks/normalspace/']; end % functional ROIs
    xx = strsplit(subjects(sid).name, '_'); % 20170329_SYM_SUB05
    subjectid = xx{3}; exptsub = [xx{2} '_' xx{3}];
    L2_str.subjectid{sid,1} = subjectid;
    
    % betas and splithalfs
    xx = spm_vol([fevtm 'mask.nii']); L2_str.voldim(sid,:) = xx.dim;
    xx = spm_read_vols(xx); % brain mask
    L2_str.qbrainmask{sid,1} = find(xx);
    load([fmats exptsub '_' normprefix 'dnlocmerged_betas']);
    L2_str.mergedblkbeta{sid,1} = betas;
    load([fmats exptsub '_' normprefix 'dnevtmerged_betas']); % merged evt GLM betas
    L2_str.mergedevtbeta{sid,1} = betas;
    load([fmats exptsub '_' normprefix 'dnevtmerged_shmaps']); % splithalf correlation for merged evt GLM
    L2_str.mergedevtbetash{sid,1} = oeshcorrmap;
    
    % anatmasks
    f = dir([fanatmasks '*.nii']);
    arois = arrayfun(@(x) x.name(6-length(normprefix):end-8), f, 'UniformOutput', false);
    for roid = 1:length(arois)
        xx = spm_read_vols(spm_vol([fanatmasks f(roid).name]));
        L2_str.aROI.(arois{roid}){sid,1} = find(xx);
    end
    
    % FROI SPREADSHEET
    L2_str.fROI.fROIfile = [exptname '_' normprefix 'frois.xlsx'];
    [~, ~, xlsinfo] = xlsread([exptfolder exptname '_' normprefix 'frois.xlsx']); xlsinfo(1,:) = [];
    xlsinfo = cellfun(@upper, xlsinfo, 'UniformOutput', false);
    subjectids = xlsinfo(:,1); % should match the subjectid field of the subject folder
    contrastnames = xlsinfo(:,2); % should match the names in level1glmcontrasts.m  
    froinames = xlsinfo(:,3); % should match the filenames in froimasks/subjectspace or froimasks/normalspace
    isfwe = cellfun(@(x) strcmp(x, 'FWE'), xlsinfo(:,4)); 
    pthresh = cell2mat(xlsinfo(:,5));
    clusterextent = cell2mat(xlsinfo(:,6));
    
    % SPM.MAT
    load([fevtm 'SPM']);
    L2_str.evtnames{sid,1} = upper(arrayfun(@(x) x.descrip(29:end-6), SPM.Vbeta, 'UniformOutput', false)');  L2_str.evtnames{sid,1}(end-13:end) = [];

    load([fblkm 'SPM']);
    spmcontrasts = upper(arrayfun(@(x) x.name(1:end-15), SPM.xCon, 'UniformOutput', false)');
    L2_str.blknames{sid,1} = upper(arrayfun(@(x) x.descrip(29:end-6), SPM.Vbeta, 'UniformOutput', false)');  L2_str.blknames{sid,1}(end-7:end) = [];

    % MANUALLY CREATED FROI MASKS
    f = dir([ffroimasks '*.nii']);
    froifilenames = upper(arrayfun(@(x) x.name(1:end-4), f, 'UniformOutput', false));
        
    for froid = 1:length(froifilenames)
        
        currentfroi = froifilenames{froid};
        q = find(strcmp(subjectid, subjectids) & strcmp(froinames, currentfroi));
        
        % froi specs from spreadsheet
        L2_str.fROI.(currentfroi).specs(sid,:) = [isfwe(q) pthresh(q) clusterextent(q)];
        L2_str.fROI.(currentfroi).contrastnames = contrastnames{q};
        
        % froi voxels from masks
        xx = spm_read_vols(spm_vol([ffroimasks f(froid).name]));
        qfroivoxels = find(xx);
        L2_str.fROI.(currentfroi).ids{sid,1} = qfroivoxels;
        
        % froi tvalues
        spmtfile = [fblkm sprintf('spmT_%04d.nii', manystrmatch(contrastnames{q}, spmcontrasts))];
        xx = spm_read_vols(spm_vol(spmtfile));
        L2_str.fROI.(currentfroi).tvalues{sid,1} = xx(qfroivoxels);
        
        % froi runbetas
        load([fmats exptsub '_' normprefix 'dnevt_betas']);
        L2_str.fROI.(currentfroi).runbetas{sid,1} = betas(qfroivoxels,:,:);
    end    
end

% packing mfiles used for pipeline and L2 generation
load([exptfolder exptname '_pipelinecodes']); L2_str.depstr = depstr;
L2files{1,1} = which('fmri_genL2'); L2files{2,1} = which('fmri_getL2def');
depstr = packdeps(L2files); f = fieldnames(depstr.mfiles);
for fid = 1:length(f)
    L2_str.depstr.mfiles.(f{fid}) = depstr.mfiles.(f{fid});
end

save([exptfolder 'L2fmri_' normprefix exptname], 'L2_str');