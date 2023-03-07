% wm_createL2str_vischmap -> this function creates L2_str for visual channel mapping from L1_str
% Main Use = Plot Global Raster for nImages shown in mapping task
%
% INPUT
% L1str_vischmap = L1_str generated using 'wm_createL1str' function on vischmap fixation task
%
% OUTPUT
% L2str_vischmap = L2_str for visual channel map fixation task
%
% Version History:
%    Date               Authors             Notes
%    15-Jan-2023        Shubho              Initial implementation
%    31-Jan-2023        Arun                Updated code suitably
%    31-Jan-2023        Shubho              Updated code to ignore trials with ptdmismatchflag
%    19-Feb-2023        Shubho              Updated code to store mean & std of transformed raw eye data
%=========================================================================================

%% ----- USER-DEFINED SECTION ----------
allclear;
load L1_VCM_20230201.mat;                           % load L1_str here
spkwindow    = [-0.1 0.3];                          % seconds pre and post of stim onset
calibtrialID = L1_str.calibmodel.trialID(end);      % using last correct calib trial to transform raw data, change if you want

%% START OF STANDARDIZED CODE
fprintf('***** wm_createL2str_vischmap starting ***** \n');

%% Process Fix trials
ncells = length(L1_str.tspike); nstim = max(cell2mat(L1_str.trialProperties.stimID)); 

% GET all fixtrials
fixtrials = manystrmatch('Fix',L1_str.trialProperties.taskType)'; % all fix trials
ptdmismatchtrials = find([L1_str.trialEvents.PtdMismatchFlag]); % trial ids with ptd mismatch 
fixtrials  = setdiff(fixtrials, ptdmismatchtrials); % remove all trials with ptd mismatch 

% create a dummy variable xx for storing stuff later. 
for cellid = 1:ncells
    for stimid = 1:nstim
        tspike{cellid,1}{stimid,1} = {}; 
        xx{cellid,1}{stimid,1} = []; 
    end
end
responsecorrect = xx; trialnum = xx; blocknum = xx; stimpos = xx; eyeXYstats = xx; 

for trialid = fixtrials
    clear tcodes qstim* tstim*
    tcodes          = L1_str.trialEvents(trialid).tEcubePtd; % using ptd-corrected event times
    trialcodenames  = L1_str.trialEvents(trialid).eventcodenames;
    qstimon         = find(~cellfun(@isempty,strfind(trialcodenames,regexpPattern('stim\dOn'))));
    qstimoff        = find(~cellfun(@isempty,strfind(trialcodenames,regexpPattern('stim\dOff'))));
    trialstimIDs    = L1_str.trialProperties.stimID{trialid}; % list of stims that were planned for the trial

    % get rawEyeData for this trial & transform using last correct calib trial
    trialraweye = L1_str.rawEyeData{trialid}(:,1:2); % take only eyeX & eyeY
    trialraweye = [trialraweye, ones(size(trialraweye,1),1)]; % [signalX signalY 1]
    trialeyeX   = trialraweye * L1_str.calibmodel.rawEyeXmodel{calibtrialID}; % x-dva model
    trialeyeY   = trialraweye * L1_str.calibmodel.rawEyeYmodel{calibtrialID}; % y-dva model
    tecube      = [0:length(trialeyeX)-1]/L1_str.specs.ecube.specs.samplingRate; % time axis for eye data 
    tecube      = tecube*1000; % convert to milliseconds

    for stimnum  = 1:length(qstimoff) % cycle through stimuli that were turned off without error
        stimid   = trialstimIDs(stimnum);
        tstimon  = tcodes(qstimon(stimnum));
        tstimoff = tcodes(qstimoff(stimnum));
        for cellid  = 1:length(L1_str.tspike)
            spk     = L1_str.tspike{cellid}{trialid}; 
            q       = find(spk>=tstimon+spkwindow(1) & spk<=tstimon+spkwindow(2)); 
            tspike{cellid}{stimid}{end+1,1} = (spk(q)-tstimon)*1000; % storing spikes in ms as per series123 convention
            responsecorrect{cellid}{stimid}(end+1,1) = L1_str.responseCorrect(trialid); 
            % store expt-design related details
            trialnum{cellid}{stimid}(end+1,1) = trialid; 
            blocknum{cellid}{stimid}(end+1,1) = L1_str.trialProperties.block(trialid);
            stimpos{cellid}{stimid}(end+1,1)  = stimnum; 

            % extract eye samples for this particular stimulus
            q = find(tecube>=tstimon+spkwindow(1) & tecube<=tstimon+spkwindow(2)); 
            stimeyeX = trialeyeX(q); stimeyeY = trialeyeY(q); 
            % store mean & std of x & y dva for this transformed eye data
            eyeXYstats{cellid}{stimid}(end+1,:) = [nanmean(stimeyeX) nanstd(stimeyeX) nanmean(stimeyeY) nanstd(stimeyeY)]; % [mean-X std-X mean-Y std-Y]
        end
    end
end

%% build L2_str
L2_str.expt_name          = L1_str.exptName;
L2_str.expt_date          = L1_str.exptDate;
L2_str.items              = L1_str.images;
if(isfield(L1_str,'imageNames'))
L2_str.itemnames          = L1_str.imageNames;
end
L2_str.neuron_id          = L1_str.neuronid;
L2_str.spikes             = tspike;
L2_str.response_correct   = responsecorrect;
L2_str.trialnum           = trialnum;
L2_str.blocknum           = blocknum;
L2_str.itempos            = stimpos;
L2_str.eyeXYstats         = eyeXYstats;
L2_str.calibtrialID       = calibtrialID; 

%% build L2_str.specs
L2_str.specs.spk_window   = spkwindow;
L2_str.specs.L1specs      = L1_str.specs;
L2_str.specs.waveforms    = L1_str.neuronwf; 
L2_str.specs.twaveforms   = L1_str.neuronwft; 
L2_str.specs.L1specs      = L1_str.specs; 

% fields documentation
n=0;fields={};
n=n+1;fields{n,1}= 'expt_name         = Name of the experiment';
n=n+1;fields{n,1}= 'items             = images used in expt';
n=n+1;fields{n,1}= 'itemnames         = filenames of stims / items used in expt.';
n=n+1;fields{n,1}= 'neuron_id         = monkeyname(1:2)-sessionID-channelID-unitid';
n=n+1;fields{n,1}= 'spikes            = {ncell,1}{nstim,1}{nreps,1} cell array of spike times in ms relative to stim on';
n=n+1;fields{n,1}= 'response_correct  = {ncell,1}{stimid,1}(nreps,1) vector of response_correct for that cell/stim/trial';
n=n+1;fields{n,1}= 'trialnum          = {ncell,1}{stimid,1}(nreps,1) vector of trial number for that cell/stim/rep';
n=n+1;fields{n,1}= 'blocknum          = {ncell,1}{stimid,1}(nreps,1) vector of block number for that cell/stim/rep';
n=n+1;fields{n,1}= 'itempos           = {ncell,1}{stimid,1}(nreps,1) vector of position of a stim in a trial for that cell/stim/rep';
n=n+1;fields{n,1}= 'eyeXYstats        = {ncell,1}{stimid,1}(nreps,4) matrix of eye data (within spikewindow) stats [meanX stdX meanY stdY] for each cell/stim/rep';
n=n+1;fields{n,1}= 'calibtrialID      = ID of calib trial used to transform eye data';
n=n+1;fields{n,1}= 'specs             = specs used in L2_str creation';
L2_str.fields    = fields;

% L2_str.specs fields
n=0;fields={};
n=n+1;fields{n,1}= 'spk_window        = [tstart tend] of time window for spike storage in s relative to stim on';
n=n+1;fields{n,1}= 'L1specs           = L1_str.specs just copied here'; 
n=n+1;fields{n,1}= 'waveforms         = {ncells x 1} [nsamples x 2] matrix with mean & std of unit waveform, in mV'; 
n=n+1;fields{n,1}= 'twaveforms        = [nsamples x 1] time axis vector for unit waveforms, in sec'; 
n=n+1;fields{n,1}= 'L1specs           = entire L1_str.specs for posterity'; 
L2_str.specs.fields = fields;

%% save & wrapup
L2filename = ['L2_' L1_str.exptName '.mat']; 
save(L2filename,'L2_str'); 

fprintf('***** wm_createL2str_vischmap DONE !! ***** \n');
