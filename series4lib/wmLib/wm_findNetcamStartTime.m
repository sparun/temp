%
% wm_findNetcamStartTime ->This function calculates the netcam start time wrt eCube start time.  Start
% time is calculated by finding the time at which the duty cycle of the
% netcam sync pulse changes from 0.2 to 0.5. 
% 
% Note: By default, netcam recording has:  resolution = '720p30';  codec = 'H264';
% Required Inputs
%       tEcube         : Absolute time recorded in eCube for each netcam sync pulse signal. 
%                        Vector of dim (nSamples x 1) 
%       netcamSync     : Synchrionizing signal sent by netcam to ecube box. Vector of dim (nSamples x 1)
%       L1specs        : struct carrying netcamFrameRate & ecube sampling rate.
% 
% Outputs
%       L1specs       : struct with updated netcamstarttime (in ecube-time). 
% 
% Version History:
%    Date               Authors             Notes
%    Unknown            Georgin             Initial version.
%    16-Nov-2021        Georgin, Thomas     Simplified the code.
%    17-Dec-2022        Arun                Minor modifications to keep in L1_str flow.
%
% ========================================================================================

function L1specs = wm_findNetcamStartTime(tEcube, netcamSync, L1specs)

if(~exist('figFlag','var')), figFlag =1; end
t                  = tEcube;
netcamsync         = netcamSync;
camera_fps         = L1specs.ecube.specs.netcamFrameRate;
samplingRate       = L1specs.ecube.specs.samplingRate;
Threshold          = 0.45; L1_str.specs.netcamDutyCycleThresh = Threshold;

%% Finding approximate start of recording
buffer_time         = 3; % buffer of 3 secs to plot/visualise dutycycle change in netcam after recording starts
nSampleperdutycycle = floor(samplingRate/camera_fps);
windowWidth         = samplingRate;
Nsteps              = length(t)/windowWidth; % 1s steps
energyWithinWindow  = [];
for i=1:Nsteps
    index = (i-1)*windowWidth+(1:windowWidth);
    energyWithinWindow(i) = mean(netcamsync(index));
end
approx_start_time = find(energyWithinWindow>=Threshold,1); % Energy threshold based on duty cycle of netcam

if(~isempty(approx_start_time))
    index = find(t>(approx_start_time-buffer_time) & t<(approx_start_time));
    
    % Approximate Netcam Sync
    selectedNetcamSync = netcamsync(index);
    selectedTime       = t(index);
    
    %% Finding exact start of recording
    prev_value       = selectedNetcamSync(1);
    count            = 0;
    nConstantSamples = [];
    tOfFlip          = [];
    % counting the samples having no prev_value
    for i=1:length(selectedNetcamSync)
        if(prev_value==selectedNetcamSync(i))
            count=count+1;
        else
            prev_value=selectedNetcamSync(i);
            nConstantSamples=[nConstantSamples;count];
            tOfFlip=[tOfFlip;selectedTime(i)];
            count=0;
        end
    end
    
    nConstantSamples(1:2)   = []; tOfFlip(1:2) = []; % first measurement might be wrong.
    normalizedSampleCount   = nConstantSamples./nSampleperdutycycle;
    % Netcam duty cycle changes to ~50% after record start. Based on this, find index when reording started.
    index                   = find(normalizedSampleCount>0.4 & normalizedSampleCount<0.6,1); 
    netcamStartTime         = tOfFlip(index(1)-1); % get the index just before flip happens
    L1specs.netcamStartTime = netcamStartTime; 
    
    % store figure data
    plotdata(1).name        = 'netcam'; 
    plotdata(1).xdata{1}    = selectedTime;                      plotdata.ydata{1} = selectedNetcamSync; plotdata(1).markerspec{1} = 'b'; 
    plotdata(1).xdata{2}    = [netcamStartTime netcamStartTime]; plotdata.ydata{2} = [0 1];              plotdata(1).markerspec{2} = 'r'; 
    plotdata(1).legendstr   = {'Netcam pulse','Netcam Start Time'}; 
    plotdata(1).titlestr    = sprintf('Netcam Video Start time = %2.4f seconds',netcamStartTime);
    plotdata(1).xlabel      = 'eCube Time, s'; plotdata.ylabel = 'Netcam digital pulse'; 
    L1specs.plotdata(1)     = plotdata; 
    
    % SUCCESS message
    disp('SUCCESS! Netcam recording start time extracted. Continuing.')
else
    L1specs.netcamStartTime=[];
    L1specs.plotdata = []; 
    disp('WARNING! Netcam starting pulse not detected. Continuing.')
end