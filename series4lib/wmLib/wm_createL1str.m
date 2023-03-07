% wm_createL1str -> creates L1_str from ML, eCube and neural data files
%
% Required Inputs
%       bhvFileFullPath        : full path of .bhv2 file
%       ecubeFolderFullPath    : full path of ecube folder containing all analog & digital files
%       neuralFileFullPath     : full path of neural file (.bin / .nex)
%
% Optional inputs
%       channelwiseThreshold   : channelwise spike-sorting threshold for quick-and-dirty spike sorting (not for the faint-hearted)
%       IMUsensitivity         : sensitivity of IMU sensor set during recording 
%
% Outputs
%       L1_str                 : L1_str
% Version History: 
%    Date               Authors             Notes
%    17-Dec-2022        SP Arun             First version
%    07-Jan-2023        Shubho, Arun        Cleaned up and incorporated series4 group comments.
%    31-Jan-2023        Arun                Updated with eye-calibration model.
%    31-Jan-2023        Shubho              Updated various portions after looking through data from all template tasks.
%    13-Feb-2023        Shubho              corrected few variables while handling continuous neural data.
% ========================================================================================

%% ----- USER-DEFINED SECTION ----------
allclear; 
dbstop if error

% SSD
% pathprefix = 'x:\data\setup\benchmarking\dryrun_20230201\SSD\';
% bhvFileFullPath     = [pathprefix 'didi_S005-E01-SSD-template_20230201_101552.bhv2']; 
% ecubeFolderFullPath = [pathprefix 'didi_S005-E01-SSD-template\Record Node 101']; 
% neuralFileFullPath  = [pathprefix 'HSW_2023_02_01__10_15_42__03min_06sec__hsamp_192ch_25000sps.nex']; 

% TSD
% pathprefix = 'x:\data\setup\benchmarking\dryrun_20230201\TSD\';
% bhvFileFullPath     = [pathprefix 'didi_S005-E04-TSD-template_20230201_105814.bhv2']; 
% ecubeFolderFullPath = [pathprefix 'didi_S005-E04-TSD-template\Record Node 101']; 
% neuralFileFullPath  = [pathprefix 'HSW_2023_02_01__10_58_01__02min_51sec__hsamp_192ch_25000sps.bin']; 

% VSO
% pathprefix = 'x:\data\setup\benchmarking\dryrun_20230201\VSO\';
% bhvFileFullPath     = [pathprefix 'didi_S005-E02-VSO-template_20230201_102124.bhv2']; 
% ecubeFolderFullPath = [pathprefix 'didi_S005-E02-VSO-template\Record Node 101']; 
% neuralFileFullPath  = [pathprefix 'HSW_2023_02_01__10_21_18__03min_39sec__hsamp_192ch_25000sps.nex']; 

% VISCHMAP
pathprefix = 'x:\data\setup\benchmarking\dryrun_20230201\VCM\';
bhvFileFullPath     = [pathprefix 'didi_S005-E03-FIX-vischmap_20230201_104447.bhv2']; 
ecubeFolderFullPath = [pathprefix 'didi_S005-E03-FIX-vischmap\Record Node 101']; 
neuralFileFullPath  = [pathprefix 'HSW_2023_02_01__10_44_40__05min_13sec__hsamp_192ch_25000sps.nex']; %.nex

% 
channelwiseThreshold = 18e-3; % default threshold for quick-and-dirty spikesorting (modify as required) 
L1specs.IMUsensitivity = 'med'; % fix based on IMU settings used (options: high/med/low)
% --------------------------------------

%% START OF STANDARDIZED CODE 
fprintf('***** wm_createL1str starting ***** \n \n \n '); 
if(~exist('IMUsensitivity')), IMUsensitivity = 'med'; end % assuming medium sensitivity

%% sanity check on order of file dates/times
[L1specs.bhvFileDate,L1specs.ecubeFileDate,L1specs.neuralFileDate] = ...
    wm_checkEcubeBhvDates(bhvFileFullPath,ecubeFolderFullPath,neuralFileFullPath); 

%% Load up all fixed ecube properties
L1specs.ecube                               = wm_ecubeProperties; 
L1specs.ecubeFolder                         = ecubeFolderFullPath;

%% Reading data from all files

% READ digital data from ecube (nsamples x 1 vector of 64-bit numbers converted into decimals) 
[digitalData, L1specs]                      = wm_readDigitalData(L1specs);

% READ analog data from ecube (nch x nsamples)
[analogData, L1specs]                       = wm_readAnalogData(L1specs);

% READ MonkeyLogic BHV file (NIMH MonkeyLogic needs to be installed as MATLAB App) 
[mlData, L1specs.mlConfig, mlTrialRecord]   = mlread(bhvFileFullPath);
[L1specs.bhvFilePath,filename,fileext]      = fileparts(bhvFileFullPath); 
L1specs.bhvFile                             = [filename,fileext];
RecordedSerialData                          = mlTrialRecord.User.serialData; 
serialTimeStamp                             = mlTrialRecord.User.timeStamp;

% READ neural data file
[L1specs.neuralFilePath,filename,fileext]   = fileparts(neuralFileFullPath); 
L1specs.neuralFile                          = [filename,fileext];
[nch,neuralSamplingRate,iswireless]         = wm_processBinFilename(L1specs.neuralFile); 
L1specs.nchannels                           = nch; 
L1specs.neuralSamplingRate                  = neuralSamplingRate; 
L1specs.iswireless                          = iswireless; 

if(strcmp(fileext,'.nex'))
    fprintf('SUCCESS! Spike data detected. \n');
    neuralData = wm_readNexFile(neuralFileFullPath);
    inp = input('Enter filter parameters used during spike sorting : ',"s"); 
    L1specs.neuralBandpassFilterSpecs = inp; 
elseif(strcmp(fileext,'.bin'))
    fprintf('SUCCESS! Continuous data file detected. Reading data (~... \n');
    inp = input('    For quick-and-dirty spike sorting, press 1. For LFP, press 2 : '); 
    if(inp==1) % do quick-and-dirty spike sorting on WB data 
        if(length(channelwiseThreshold)==1), channelwiseThreshold = channelwiseThreshold*ones(nch,1); end
        % reading bindata channelwise to avoid overloading memory
        for chid = 1:nch
            fprintf('    Reading raw data in channel %d of %d \n',chid,nch);
			chwbData = wm_readBinData(neuralFileFullPath,chid);
            fprintf('    Starting quick-and-dirty spike sorting for channel %d of %d \n',chid,nch);
            chneuralData = wm_BasicSpikeSortThreshold(chwbData,channelwiseThreshold(chid),neuralSamplingRate);
            neuralData.neurons{chid}.name = sprintf('Channel%03d',chid);
            neuralData.neurons{chid}.wireNumber = chid-1;
            neuralData.neurons{chid}.unitNumber = 0;
            neuralData.neurons{chid}.timestamps = chneuralData.neurons{1}.timestamps;
            neuralData.waves{chid}.waveforms = chneuralData.waves{1}.waveforms*1e3; % store wfs in mV to be consistent with plexon
        end
        L1specs.channelwiseThreshold = channelwiseThreshold; 
    elseif(inp==2) % do bandpass and resample wideband data to get LFP
        neuralBandpassFreqs = [50 500]; % low-cut and high-cut values for LFP
		lfpSamplingRate = 2*neuralBandpassFreqs(2); % resample LFP data down to 2*highcut value of bandpass
        % reading bindata channelwise to avoid overloading memory
        fprintf('Progress of LFP storage:\n');
        fprintf(['\n' repmat('.',1,nch) '\n\n']);
        parfor chid = 1:nch
            chwbData = wm_readBinData(neuralFileFullPath,chid);
			y 		 = bandpass(chwbData,neuralBandpassFreqs,neuralSamplingRate);
            yr 		 = resample(y,lfpSamplingRate,neuralSamplingRate);
            neuralData(chid,:)  = yr;
            fprintf('\b|\n'); % show progressbar
        end
        L1specs.neuralBandpassFilterSpecs = sprintf('Default from %s',which('bandpass.m')); 
        L1specs.neuralBandpassFreqs = neuralBandpassFreqs;
        L1specs.lfpSamplingRate = lfpSamplingRate;
    end
end
fprintf('SUCCESS! Neural data extracted. Continuing. \n');

% READ IMU data if available
IMUdata = wm_readIMUmmxData(L1specs.neuralFilePath,IMUsensitivity);
if(~isempty(IMUdata)), L1specs.IMUsensitivity = IMUsensitivity; end % store IMU sensitivity only if IMU data is present

%% Extracting ecube time axis
maxNsamples = max([length(analogData),length(digitalData)]); % #samples in digital data is slightly more than analog data, so taking max
tecube      = (0:maxNsamples-1)*1/L1specs.ecube.specs.samplingRate; % define ecube time axis

%% Extract strobe, photodiode and netcam sync pulse channels from digital data
% For each of these variables, the value will be 1 when this input occurred and 0 otherwise
strobe             = wm_extractDigitalBits(digitalData, L1specs.ecube.digital.strobe); 
netcamSync         = wm_extractDigitalBits(digitalData, L1specs.ecube.digital.netcamSync);
wirelessSync       = wm_extractDigitalBits(digitalData, L1specs.ecube.digital.HSWsync);

%% Extract the start time of netcam recording
L1specs  = wm_findNetcamStartTime(tecube, netcamSync, L1specs); 

%% Extract start time & duration of wireless sync pulse
L1specs.wirelessStartTime         = find(wirelessSync==1,1)/L1specs.ecube.specs.samplingRate; 
L1specs.wirelessPulseDuration     = length(find(wirelessSync==1))/L1specs.ecube.specs.samplingRate; 
if(isempty(L1specs.wirelessStartTime)),error('FAILURE! Wireless sync pulse not found'); end

%% Extracting photodiode signal from ecube
photodiodeData                    = analogData(:,L1specs.ecube.analog.photodiode);

%% Extract eventsCodes, experiment Header, trial Footer. 
% extract header, files, basic info
[events, L1specs.MLfiles, MLinfo] = wm_extractExpEventsAndHeader(tecube, digitalData, strobe);

% extract trial events and trial footer from event codes
[trialEvents,trialFooter]         = wm_extractTrialEventsAndFooter(events);  

%% extract stimuli (if any)
[exptImages, exptImageNames]      = ml_exportStim(bhvFileFullPath); 

%% Start building L1 structure 
L1_str.exptName         = MLinfo.expName; 
L1_str.exptDate         = L1specs.bhvFileDate; % taking the ML file as the file date
L1_str.monkey           = MLinfo.monkeyName; 
L1_str.images           = exptImages; 
L1_str.imageNames       = exptImageNames; 
L1_str.specs            = L1specs; 
L1_str.neuronid = []; L1_str.neuronwf = []; L1_str.neuronwft = []; L1_str.tspike = []; % just to put the neurons first 
L1_str.trialProperties  = trialFooter; 
L1_str.responseCorrect  = double(trialFooter.trialError==0); 

%% extract unit name and waveforms
% get session number
q = strfind(bhvFileFullPath,'_S');
sesnum = str2num(bhvFileFullPath(q+2:q+4)); %#ok<ST2NM>

if(isstruct(neuralData)) % assume sorted spikes
    ncells = length(neuralData.neurons);
    for neuronid = 1:ncells
        chnum                       = neuralData.neurons{neuronid}.wireNumber+1;
        unitnum                     = neuralData.neurons{neuronid}.unitNumber;
        unitnumstr                  = sprintf('u%.2d',unitnum); 
        if(unitnumstr=='u00'), unitnumstr = 'mua'; end
        L1_str.neuronid{neuronid,1} = sprintf('%s%03d_ch%03d_%s',L1_str.monkey(1:2),sesnum,chnum,unitnumstr); % e.g. di014_ch013_u03, di014_ch192_mua
        wfmean                      = nanmean(neuralData.waves{neuronid}.waveforms,2);      % mean of the unit waveform
        wfstd                       = nanstd(neuralData.waves{neuronid}.waveforms,[],2);    % std of the unit waveform
        L1_str.neuronwf{neuronid,1} = [wfmean, wfstd];
    end
    wft                             = [0:length(wfmean)-1]'/L1specs.neuralSamplingRate;
    L1_str.neuronwft                = wft; 
else % assume continuous data
    ncells = size(neuralData,1); nsamples = size(neuralData,2); 
    for channelid = 1:ncells
        L1_str.neuronid{channelid,1} = sprintf('%s%03d_ch%03d_lfp',L1_str.monkey(1:2),sesnum,channelid); % e.g. di014_ch013_lfp
    end
    tneural = [0:nsamples]/L1specs.lfpSamplingRate; % time axis for neural data 
end

%% Extract trial-wise data
% load ML event codes for each type of variable
[err, pic, aud, bhv, rew, exp, trl, chk, asc] = ml_loadEvents(); 
% we are storing tEcube as absolute ecube...
% because in case we want to work with netcamdata... 
% + zero for a trial is not clear, might depend on task
for trialid = 1:length(trialEvents)
    trialStart      = trialEvents(trialid).tEcube(1);
    trialStop       = trialEvents(trialid).tEcube(end);
    ecubeTrialIndex = find(tecube>=trialStart & tecube<=trialStop); % find indices b/w trialstart & trialstop
    % compile neural data
    if(isstruct(neuralData)) % if sorted data 
        for neuronid = 1:ncells
            tspike = neuralData.neurons{neuronid}.timestamps + L1specs.wirelessStartTime; % add wireless start time to bring to ecube time axis
            L1_str.tspike{neuronid,1}{trialid,1} = tspike(tspike>=trialStart & tspike<=trialStop);
        end
    else % if wideband/LFP data
        qneural = find(tneural+L1specs.wirelessStartTime>=trialStart & tneural+L1specs.wirelessStartTime<=trialStop); % add wireless start time to neural time axis
        L1_str.lfp{trialid,1} = neuralData(:,qneural); % collect all channel for each trial
    end

    % compile photodiode data
    trialEvents(trialid).ptdData = photodiodeData(ecubeTrialIndex); 

    % compile IMU data (if available) 
    if(~isempty(IMUdata))
        timu                     = IMUdata.timu + L1specs.wirelessStartTime; % add wireless start time to bring to ecube time axis
        qimu                     = find(timu>=trialStart & timu<=trialStop); 
        L1_str.IMUacc(trialid,:) = IMUdata.acc(:,qimu); 
        L1_str.IMUgyr(trialid,:) = IMUdata.gyr(:,qimu); 
        L1_str.IMUmag(trialid,:) = IMUdata.mag(:,qimu); 
    end

    % compile RTs (numeric only for SameDiff or Search tasks, else NaN) 
    tImageOn = NaN; tImageOnEventCode = NaN; tResponse = NaN;
    switch trialFooter.taskType{trialid}
        case 'Tsd'
            tImageOn = trialEvents(trialid).tEcube(trialEvents(trialid).eventcodes == pic.testOn);
            tImageOnEventCode = pic.testOn; 
        case {'Ssd','Vso'}
            tImageOn = trialEvents(trialid).tEcube(trialEvents(trialid).eventcodes == pic.sampleOn);
            tImageOnEventCode = pic.sampleOn; 
    end
    if(isempty(tImageOn)), tImageOn = NaN; end % avoids code breaking when assigning tImageOn
    if(any(trialEvents(trialid).eventcodes == bhv.respGiven)) % if any response was given
        tResponse = trialEvents(trialid).tEcube(trialEvents(trialid).eventcodes == bhv.respGiven); % check event code for respGiven
    end
    L1_str.tAwaitResponse(trialid,1)          = tImageOn;          % time of starting to await response, in eCube time 
    L1_str.tAwaitResponseEventCode(trialid,1) = tImageOnEventCode; % event code for tAwaitResponse
    L1_str.tResponse(trialid,1)               = tResponse;         % time at which response is made in eCube time
    
    % compile raw eye data (direct input from ISCAN)
    qeye = [L1specs.ecube.analog.eyeX L1specs.ecube.analog.eyeY L1specs.ecube.analog.pupilArea]; % channel IDs in analog data for eye signals
    L1_str.rawEyeData{trialid,1} = analogData(ecubeTrialIndex,qeye); 

    % compile ML eye & touch data (basis for behavior)
    nsamples                        = size(mlData(trialid).AnalogData.Eye,1); 
    tML                             = [0:nsamples-1]*1000/L1specs.mlConfig.AISampleRate; % ML time axis in ms - all eye/touch data is stored on this time axis
    tMLtrialstart                   = mlData(trialid).BehavioralCodes.CodeTimes(find(mlData(trialid).BehavioralCodes.CodeNumbers==trl.start)); 
    tMLtrialstop                    = mlData(trialid).BehavioralCodes.CodeTimes(find(mlData(trialid).BehavioralCodes.CodeNumbers==trl.stop)); 
    MLsampleIDs                     = find(tML>=tMLtrialstart & tML<=tMLtrialstop); % sample ids in eye & touch data between trial start & stop 
    L1_str.MLtime{trialid,1}        = tML(MLsampleIDs)-tML(MLsampleIDs(1)); 
    L1_str.MLeyeData{trialid,1}     = mlData(trialid).AnalogData.Eye(MLsampleIDs,:); 
    L1_str.MLtouchData{trialid,1}   = mlData(trialid).AnalogData.Touch(MLsampleIDs,:); 

    % compile serial eye data 
    % Note that we have no idea about the serial data start time in the ML trial, so we are just
    % storing the serial data as is, along with the obtained system timestamps. If you want to align
    % and use this data, best way would be to cross-correlate ecube eye data with P-CR of eye1. 
    % No guarantees are given here from L1 creators! 
    % But we are storing it anyway just in case someone wants to analyze advanced gaze information. 
    L1_str.serialData(trialid,1).RecordDateTime       = datetime(serialTimeStamp{trialid});
    L1_str.serialData(trialid,1).eye1.pupilX          = RecordedSerialData{trialid}(:,1);
    L1_str.serialData(trialid,1).eye1.pupilY          = RecordedSerialData{trialid}(:,2);
    L1_str.serialData(trialid,1).eye1.crX             = RecordedSerialData{trialid}(:,3);
    L1_str.serialData(trialid,1).eye1.crY             = RecordedSerialData{trialid}(:,4);
    L1_str.serialData(trialid,1).eye1.pupilW          = RecordedSerialData{trialid}(:,5);
    L1_str.serialData(trialid,1).eye1.pupilH          = RecordedSerialData{trialid}(:,6);
    L1_str.serialData(trialid,1).eye1.pupilArea       = RecordedSerialData{trialid}(:,7);
    L1_str.serialData(trialid,1).eye2.gazeX           = RecordedSerialData{trialid}(:,8);
    L1_str.serialData(trialid,1).eye2.gazeY           = RecordedSerialData{trialid}(:,9);
    L1_str.serialData(trialid,1).eye2.pupilArea       = RecordedSerialData{trialid}(:,10);
    L1_str.serialData(trialid,1).vergence             = RecordedSerialData{trialid}(:,11);
    L1_str.serialData(trialid,1).timeStamp            = RecordedSerialData{trialid}(:,12);
    L1_str.serialData(trialid,1).mlTrialDateTime      = datetime(mlData(trialid).TrialDateTime);

    % compile additional useful info from the trial into trialFooter
    L1_str.trialProperties.holdInitPeriod(trialid,1)      = mlData(trialid).TaskObject.CurrentConditionInfo.holdInitPeriod;
    L1_str.trialProperties.fixInitPeriod(trialid,1)       = mlData(trialid).TaskObject.CurrentConditionInfo.fixInitPeriod;
    if(strcmp(trialFooter.taskType{trialid},'Tsd'))
        L1_str.trialProperties.samplePeriod(trialid,1)    = mlData(trialid).TaskObject.CurrentConditionInfo.samplePeriod;
        L1_str.trialProperties.testPeriod(trialid,1)      = mlData(trialid).TaskObject.CurrentConditionInfo.testPeriod;
        L1_str.trialProperties.respPeriod(trialid,1)      = mlData(trialid).TaskObject.CurrentConditionInfo.respPeriod;
    elseif(strcmp(trialFooter.taskType{trialid},'Ssd')||strcmp(trialFooter.taskType{trialid},'Vso'))
        L1_str.trialProperties.searchPeriod(trialid,1)    = mlData(trialid).TaskObject.CurrentConditionInfo.searchPeriod;
        L1_str.trialProperties.respPeriod(trialid,1)      = mlData(trialid).TaskObject.CurrentConditionInfo.respPeriod;
    elseif(strcmp(trialFooter.taskType{trialid},'Fix'))
        L1_str.trialProperties.stimOnPeriod(trialid,1)    = mlData(trialid).TaskObject.CurrentConditionInfo.stimOnPeriod;
        L1_str.trialProperties.stimOffPeriod(trialid,1)   = mlData(trialid).TaskObject.CurrentConditionInfo.stimOffPeriod;
    end
    % Calibration Related
    L1_str.trialProperties.calFixRadius(trialid,1)        = mlData(trialid).VariableChanges.calFixRadius;
end

%% Add the PTD events to trial Events
[trialEvents,L1specs]   = wm_adjustVisualEvents(photodiodeData,trialEvents,L1specs);
L1_str.trialEvents      = trialEvents; 
L1_str.specs            = L1specs; 

%% processing calib trials and storing calib model
L1_str = wm_processCalibrationTrials(L1_str); 

%% Create combined diagnostic plot using L1_str.specs.plotdata
wm_plotdata(L1_str.specs.plotdata); 

%% PLOTTING ALL EVENTS WITH PTD MISMATCH 
ptdmismatchtrials = find([L1_str.trialEvents.PtdMismatchFlag]); 
if(~isempty(ptdmismatchtrials)), wm_plotL1TrialEvents(L1_str,ptdmismatchtrials,'VISUAL-PTD MISMATCH TRIALS'); end

%% 
fprintf('***** wm_createL1str DONE !! ***** \n \n \n'); 

%% L1_str fields 
n=0; 
n=n+1; L1_str.fields{n,1} = 'exptName                = experiment name'; 
n=n+1; L1_str.fields{n,1} = 'exptDate                = experiment date (from ML)'; 
n=n+1; L1_str.fields{n,1} = 'monkey                  = monkey name'; 
n=n+1; L1_str.fields{n,1} = 'images                  = cell array of images used in expt (if stored in ML)'; 
n=n+1; L1_str.fields{n,1} = 'specs                   = structure containing various parameters used in L1 creation'; 
n=n+1; L1_str.fields{n,1} = 'neuronid                = neuron id (unit names: u01 = first sorted unit, u02 = second sorted unit, mua = multi-unit activity)'; 
n=n+1; L1_str.fields{n,1} = 'neuronwf                = {ncells x 1} [nsamples x 2] matrix with mean & std of unit waveform, in mV'; 
n=n+1; L1_str.fields{n,1} = 'neuronwft               = [nsamples x 1] time axis vector for neuronwf, in sec'; 
n=n+1; L1_str.fields{n,1} = 'tspike                  = {ncells x 1}{ntrials x 1} array of spike times in sec, in absolute eCube time'; 
n=n+1; L1_str.fields{n,1} = 'trialProperties         = (ntrials x 1) structure containing trial properties'; 
n=n+1; L1_str.fields{n,1} = 'responseCorrect         = [ntrials x 1] vector of response type (1 if correct, 0 if wrong)';  
n=n+1; L1_str.fields{n,1} = 'tAwaitResponse          = (ntrials x 1) vector of time in sec of starting to wait for response, in absolute eCube time'; 
n=n+1; L1_str.fields{n,1} = 'tAwaitResponseEventCode = (ntrials x 1) vector of tAwaitResponse event codes (ideally its a single code)'; 
n=n+1; L1_str.fields{n,1} = 'tResponse               = Time of response in sec in absolute eCube time (NOT RT)'; 
n=n+1; L1_str.fields{n,1} = '                          tImageOn, tImageOnEventCode, RT will be numeric for Tsd Ssd & Vso tasks and NaN otherwise'; 
n=n+1; L1_str.fields{n,1} = 'rawEyeData              = {ntrials x 1} [nsamples x 3] matrix of raw eye data (eyeX, eyeY, pupilArea) from ISCAN stored in ecube, in Volts'; 
n=n+1; L1_str.fields{n,1} = 'MLtime                  = ML time axis in milliseconds for a trial';
n=n+1; L1_str.fields{n,1} = 'MLeyeData               = {ntrials x 1} [nsamples x 2] matrix of ML eye data (eyeX, eyeY) used by ML for behavior control, in dva';
n=n+1; L1_str.fields{n,1} = 'MLtouchData             = {ntrials x 1} [nsamples x 20] matrix of multitouch data (x1 y1 x2 y2 ...) from touchscreen, in order of touches'; % ****CHECK UNITS
n=n+1; L1_str.fields{n,1} = 'serialData              = (ntrials x 1) structure containing raw serial data recorded from ISCAN (stored without guarantees), in Volts'; 
n=n+1; L1_str.fields{n,1} = 'trialEvents             = (ntrials x 1) structure of event codes & event times during trial';
n=n+1; L1_str.fields{n,1} = 'calibmodel              = structure for model to transform eye signals into dva using calib trials';

n=0; 
if(~isempty(IMUdata)), n=n+1; L1_str.specs.fields{n,1} = 'IMUsensitivity        = IMU sensitivity level (low/med/high) set during recording'; end; 
n=n+1; L1_str.specs.fields{n,1} = 'bhvFileDate           = datetime of bhv file'; 
n=n+1; L1_str.specs.fields{n,1} = 'ecubeFileDate         = datetime of ecube file'; 
n=n+1; L1_str.specs.fields{n,1} = 'neuralFileDate        = datetime of neural file'; 
n=n+1; L1_str.specs.fields{n,1} = 'ecube                 = structure containing fixed properties of ecube'; 
n=n+1; L1_str.specs.fields{n,1} = 'ecubeFolder           = path to ecube file'; 
n=n+1; L1_str.specs.fields{n,1} = 'ecubeDigitalFiles     = nfiles x 1 cell array of filenames of ecube digital files'; 
n=n+1; L1_str.specs.fields{n,1} = 'ecubeTimeStamps       = structure containing timestamps and Nsamples of ecube analog and digital files'; 
n=n+1; L1_str.specs.fields{n,1} = 'ecubeAnalogFiles      = nfiles x 1 cell array of filenames of ecube analog files'; 
n=n+1; L1_str.specs.fields{n,1} = 'mlConfig              = mlConfig structure from bhv file'; 
n=n+1; L1_str.specs.fields{n,1} = 'bhvFilePath           = path to bhv file'; 
n=n+1; L1_str.specs.fields{n,1} = 'bhvFile               = filename of bhv file'; 
n=n+1; L1_str.specs.fields{n,1} = 'neuralFilePath        = path to neural file'; 
n=n+1; L1_str.specs.fields{n,1} = 'neuralFile            = filename of neural file'; 
n=n+1; L1_str.specs.fields{n,1} = 'nchannels             = number of channels in neural file'; 
n=n+1; L1_str.specs.fields{n,1} = 'neuralSamplingRate    = sampling rate of data in neural file'; 
n=n+1; L1_str.specs.fields{n,1} = 'iswireless            = 1 if neural file is wireless, 0 otherwise'; 
if(isfield(L1_str.specs,'neuralBandpassFilterSpecs'))
n=n+1; L1_str.specs.fields{n,1} = 'neuralBandpassFilterSpecs = specs of bandpass filter applied to neural data'; 
end
if(isfield(L1_str.specs,'neuralBandpassFreqs'))
n=n+1; L1_str.specs.fields{n,1} = 'neuralBandpassFreqs   = low and high bandpass frequency cutoffs applied to neural data'; 
end
if(isfield(L1_str.specs,'channelwiseThreshold'))
n=n+1; L1_str.specs.fields{n,1} = 'channelwiseThreshold  = vector of channelwise thresholds applied for quick-and-dirty spikesorting'; 
end
if(isfield(L1_str.specs,'lfpSamplingRate'))
n=n+1; L1_str.specs.fields{n,1} = 'lfpSamplingRate       = LFP sampling rate in Hz'; 
end
n=n+1; L1_str.specs.fields{n,1} = 'netcamStartTime       = start time of netcam in sec, in absolute ecube time, inferred from netcam pulses'; 
n=n+1; L1_str.specs.fields{n,1} = 'plotdata              = structure containing all diagnostic plots for L1 creation'; 
n=n+1; L1_str.specs.fields{n,1} = 'wirelessStartTime     = start time of wireless data in sec, in absolute ecube time, inferred from wireless trig pulse'; 
n=n+1; L1_str.specs.fields{n,1} = 'wirelessPulseDuration = duration of wireless trigger pulse in sec'; 
n=n+1; L1_str.specs.fields{n,1} = 'MLfiles               = structure containing all ML files used to run this experiment'; 
n=n+1; L1_str.specs.fields{n,1} = 'ptdThresholds         = [high2low low2high] vector of user-selected ptd thresholds, in Volts'; 
n=n+1; L1_str.specs.fields{n,1} = 'minPtdEventInterval   = minimum interval between PTD events, in sec (used to reject fake ptd events)'; 
