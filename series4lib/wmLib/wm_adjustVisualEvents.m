%
% wm_adjustVisualEvents  -> adjust visual event times based on PTD times with user iterations
%
% Required Inputs
%       photodiodeData            : (nSamples x 1) vector containing the measured photodiode signal  
%       trialEvents               : struct with trialwise eventcode, eventcodenames, tEcube, tEcubePtd, and ptdEvents  
%       L1specs                   : L1specs structure from wm_createL1str containing ecube properties
% Outputs
%       trialEvents               : trialEvents structure with visual event times adjusted
%       L1specs                   : modified L1specs with additional diagnostic information
% 
% Version History:
%    Date               Authors             Notes
%    03-Dec-2022        Shubho, Surbhi      First Implementation
%    08-Dec-2022        Shubho              minor changes in figures.
%    17-Dec-2022        Arun                Extensive revamp.
%
% ========================================================================================

function [trialEvents,L1specs]= wm_adjustVisualEvents(photodiodeData,trialEvents,L1specs)
fprintf('---- wm_adjustVisualEvents ---- \n'); 

% get initial guess at ptd thresholds
L1specs.ptdThresholds = getPTDhistthresh(photodiodeData); 
% L1specs.ptdThresholds = [4.9 4.7592]; % uncomment for debugging
fprintf('    Initial guess from ptd voltage histogram: [%2.3f %2.3f] V \n',L1specs.ptdThresholds); 

% current ELO monitor frame rate is 60 Hz
% WE define min interval between PTD signals as half of the monitor frame rate (60 Hz)
% this is to be absolutely sure that no event can happen with a half-frame interval
L1specs.minPtdEventInterval = (1/60)/2; 

nTrials = length(trialEvents);
continueflag = 1; 
while(continueflag == 1) % loop till user is satisfied with threshold

    % extract times of ptdEvents across the entire file
    ptdEvents = wm_extractPTDEventTimes(photodiodeData,L1specs.ptdThresholds,L1specs.ecube.specs.samplingRate);

    % sanity check if any PTD time intervals are less than half a monitor frame (set in L1specs.minPtdEventInterval)
    unexpectedPtdEventIDs = find(diff(ptdEvents)<=L1specs.minPtdEventInterval);
    uPtdEvents = []; 
    if(~isempty(unexpectedPtdEventIDs))
        uPtdEvents = ptdEvents(unexpectedPtdEventIDs+1); 
        ptdEvents(unexpectedPtdEventIDs+1)=[];
    end

    % parse ptdEvents into individual trials and add to trialEvents
    for trial=1:nTrials
        trialStartTime  = trialEvents(trial).tEcube(1);
        trialStopTime   = trialEvents(trial).tEcube(end);
        eventIndex      = ptdEvents>=trialStartTime & ptdEvents<=trialStopTime;
        trialEvents(trial).ptdEvents = ptdEvents(eventIndex);
        trialEvents(trial).unexpPtdEvents = uPtdEvents(uPtdEvents>=trialStartTime & uPtdEvents<=trialStopTime); 
        trialEvents(trial).NunexpPtdEvents = length(trialEvents(trial).unexpPtdEvents); 
    end

    % correct visual event times using PTD times
    trialEvents  = wm_correctVisualEvents(trialEvents);
    
    % get diagnostic info
    uPtdEvents = [trialEvents.NunexpPtdEvents]; 
    PtdMismatchFlag = [trialEvents.PtdMismatchFlag]; 
    fprintf('    Total of unexpected PTD events (within monitor flip time) = %d \n',sum(uPtdEvents)); 
    fprintf('    (This can be ignored assuming that some of these are due to photodiode fluctuations) \n'); 
    fprintf('    Number of trials with VisualEvents & PTDEvents mismatch   = %d \n',length(find(PtdMismatchFlag))); 
    numinput = input('    Input new thresholds as [high2low low2high] in Volts, or press Enter to continue: '); 
    if(isempty(numinput))
        continueflag = 0;
    else
        L1specs.ptdThresholds = numinput; 
    end
    fprintf('\n'); 
end

% collect plotdata
L1specs = getPTDwaveforms(photodiodeData,trialEvents,L1specs);

% SUCCESS message
fprintf('SUCCESS! trialEvents.tEcubePTD now contains visual event times set to PTD event times \n');
fprintf('-------------------------- \n'); 

end

% get histogram-based ptd-thresholds
function [histThresholds,xv,hv] = getPTDhistthresh(photodiodeData)  
minVoltageDiffBetweenPeaks = 3; % before = 0.2, updated based on new ptd setup
[hv,xv]             = histcounts(photodiodeData); xv(end)=[]; 
[~, peakLocs]       = findpeaks(hv,xv,'MinPeakDistance',minVoltageDiffBetweenPeaks);
tempThreshold       = mean(peakLocs);
lowToHighThreshold  = tempThreshold - 0.1*diff(peakLocs);
highToLowThreshold  = tempThreshold + 0.1*diff(peakLocs); 
histThresholds      = [highToLowThreshold, lowToHighThreshold];
end

% get ptd-waveforms
function L1specs = getPTDwaveforms(photodiodeData,trialEvents,L1specs)
samplingRate = L1specs.ecube.specs.samplingRate; 
fcount=1; rcount=1;
for trialid     = 1:length(trialEvents)
    ptdData     = trialEvents(trialid).ptdData; nptd = length(ptdData); % get ptd-data for each trial
    ptdEvents   = trialEvents(trialid).ptdEvents - trialEvents(trialid).tEcube(1); 
    tptd        = [0:nptd-1]/samplingRate; % time-axis for ptd-signal
    for eventid = 1:2:length(ptdEvents)
        qwf     = find(tptd>=ptdEvents(eventid)-0.02 & tptd<=ptdEvents(eventid)+0.02); 
        ptdRisingEdgeWfs(1:length(qwf),rcount) = ptdData(qwf);  % ptd rising edge signal 
        rcount  = rcount+1; 
    end
    for eventid = 2:2:length(ptdEvents)
        qwf     = find(tptd>=ptdEvents(eventid)-0.02 & tptd<=ptdEvents(eventid)+0.02); % storing ptd-wf 20 ms before and after for each ptdEvent
        ptdFallingEdgeWfs(1:length(qwf),fcount) = ptdData(qwf); % ptd falling edge signal (ptd signal starts with falling edge) 
        fcount  = fcount+1; 
    end
end

%% store figure data

% plot all photodiodeData
plotid = length(L1specs.plotdata)+1; 
L1specs.plotdata(plotid).name = sprintf('PTD raw wfs');
L1specs.plotdata(plotid).xdata{1} = [0:length(photodiodeData)-1]/samplingRate; 
L1specs.plotdata(plotid).ydata{1} = photodiodeData;
L1specs.plotdata(plotid).markerspec{1} = 'k'; 
L1specs.plotdata(plotid).markersize{1} = 6; 
L1specs.plotdata(plotid).xdata{2} = [0 length(photodiodeData)-1]/samplingRate; 
L1specs.plotdata(plotid).ydata{2} = [1 1]*L1specs.ptdThresholds(1);
L1specs.plotdata(plotid).markerspec{2} = 'r'; 
L1specs.plotdata(plotid).markersize{2} = 6; 
L1specs.plotdata(plotid).xdata{3} = [0 length(photodiodeData)-1]/samplingRate; 
L1specs.plotdata(plotid).ydata{3} = [1 1]*L1specs.ptdThresholds(2);
L1specs.plotdata(plotid).markerspec{3} = 'r'; 
L1specs.plotdata(plotid).markersize{3} = 6; 
L1specs.plotdata(plotid).legendstr = 'off'; 
L1specs.plotdata(plotid).xlabel = 'Time, s'; L1specs.plotdata(plotid).ylabel = 'PTD signal, Volts';
 
% plot all falling edge waveforms
plotid = length(L1specs.plotdata)+1; 
L1specs.plotdata(plotid).name = sprintf('PTD falling edge wfs');
L1specs.plotdata(plotid).xdata{1} = [0:size(ptdFallingEdgeWfs,1)-2]/samplingRate; 
L1specs.plotdata(plotid).ydata{1} = ptdFallingEdgeWfs(1:end-1,:);
L1specs.plotdata(plotid).markerspec{1} = 'k'; 
L1specs.plotdata(plotid).markersize{1} = 6; 
L1specs.plotdata(plotid).xdata{2} = [0 size(ptdFallingEdgeWfs,1)-2]/samplingRate; 
L1specs.plotdata(plotid).ydata{2} = [1 1]*L1specs.ptdThresholds(1);
L1specs.plotdata(plotid).markerspec{2} = 'r'; 
L1specs.plotdata(plotid).markersize{2} = 6;
L1specs.plotdata(plotid).xdata{3} = [0 size(ptdFallingEdgeWfs,1)-2]/samplingRate; 
L1specs.plotdata(plotid).ydata{3} = [1 1]*L1specs.ptdThresholds(2);
L1specs.plotdata(plotid).markerspec{3} = 'r'; 
L1specs.plotdata(plotid).markersize{3} = 6;
L1specs.plotdata(plotid).legendstr = 'off'; 
L1specs.plotdata(plotid).xlabel = 'Time, s'; L1specs.plotdata(plotid).ylabel = 'PTD signal, Volts';

% plot all rising edge waveforms
plotid = length(L1specs.plotdata)+1; 
L1specs.plotdata(plotid).name = sprintf('PTD rising edge wfs');
L1specs.plotdata(plotid).xdata{1} = [0:size(ptdRisingEdgeWfs,1)-2]/samplingRate; 
L1specs.plotdata(plotid).ydata{1} = ptdRisingEdgeWfs(1:end-1,:);
L1specs.plotdata(plotid).markerspec{1} = 'k'; 
L1specs.plotdata(plotid).markersize{1} = 6;
L1specs.plotdata(plotid).xdata{2} = [0 size(ptdRisingEdgeWfs,1)-2]/samplingRate; 
L1specs.plotdata(plotid).ydata{2} = [1 1]*L1specs.ptdThresholds(1);
L1specs.plotdata(plotid).markerspec{2} = 'r'; 
L1specs.plotdata(plotid).markersize{2} = 6;
L1specs.plotdata(plotid).xdata{3} = [0 size(ptdRisingEdgeWfs,1)-2]/samplingRate; 
L1specs.plotdata(plotid).ydata{3} = [1 1]*L1specs.ptdThresholds(2);
L1specs.plotdata(plotid).markerspec{3} = 'r'; 
L1specs.plotdata(plotid).markersize{3} = 6;
L1specs.plotdata(plotid).legendstr = 'off'; 
L1specs.plotdata(plotid).xlabel = 'Time, s'; L1specs.plotdata(plotid).ylabel = 'PTD signal, Volts';

end