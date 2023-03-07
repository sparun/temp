%
% wm_plotL1TrialEvents  -> plots trial-wise photodiode signal with necessary event markers
%
% Required Inputs
%       L1_str                     : L1_str containing various items as necessary.
%       trialidArray               : trials to plot
%       titlestr                   : title string of plot
%       plotNonVisualEventsFlag    : flag to plot non-visualevents
%
% Version History:
%    Date               Authors             Notes
%    17-Dec-2022        Arun                First Implementation.
%
% ========================================================================================

function wm_plotL1TrialEvents(L1_str,trialidArray,titlestr,plotNonVisualEventsFlag)
if(~exist('titlestr')||isempty(titlestr)), titlestr = ''; end
if(~exist('plotNonVisualEventsFlag')||isempty(plotNonVisualEventsFlag)), plotNonVisualEventsFlag = 0; end
trialidArray = vec(trialidArray)'; 

nplots = length(trialidArray); nx = ceil(sqrt(nplots)); ny = ceil(nplots/nx); 
figure; count=1; 
trialEvents = L1_str.trialEvents; 
for trialid = trialidArray
    subplot(nx,ny,count); count=count+1; 
    ptdData = trialEvents(trialid).ptdData; nptd = length(ptdData);
    high2lowthresh = L1_str.specs.ptdThresholds(1); low2highthresh = L1_str.specs.ptdThresholds(2);
    high2lowstr    = sprintf('high2lowthresh = %.2f',high2lowthresh);
    low2highstr    = sprintf('low2highthresh = %.2f',low2highthresh);
    tptd = [0:nptd-1]/L1_str.specs.ecube.specs.samplingRate;
    plot(tptd,ptdData); hold on; 

    % get visual and photodiode event times relative to trial start
    vT = trialEvents(trialid).tEcube(trialEvents(trialid).isVisualEvent) - trialEvents(trialid).tEcube(1);
    pT = trialEvents(trialid).ptdEvents - trialEvents(trialid).tEcube(1);
    visevent = trialEvents(trialid).eventcodenames(trialEvents(trialid).isVisualEvent);
    for i = 1:length(vT)
        eventName = visevent(i);
        xline(vT(i),'--r',eventName,'LineWidth',2); % plotting visual event
    end
    for i = 1:length(pT)
        xline(pT(i),'--b','LineWidth',2); % plotting ptd event
    end
    if(plotNonVisualEventsFlag)
        oT = trialEvents(trialid).tEcube(~trialEvents(trialid).isVisualEvent) - trialEvents(trialid).tEcube(1); % non-visual events
        otherevent = trialEvents(trialid).eventcodenames(~trialEvents(trialid).isVisualEvent);
        for i = 1:length(oT)
            eventName = otherevent(i);
            xline(vT(i),'--k',eventName,'LineWidth',2); % plotting non-visual event
        end
    end
    yline(high2lowthresh,'r-',high2lowstr,'LineWidth',1.5); hold on;
    yline(low2highthresh,'b-',low2highstr,'LineWidth',1.5); hold on;

    title(sprintf('Trial = %d (nUniqueVisual = %d, nPTDevents = %d)', trialid,trialEvents(trialid).nUniqueVisualEvents,trialEvents(trialid).nPtdEvents));
    xlabel('Time, seconds'); ylabel('PTD signal, Volts');
end
if(~isempty(titlestr)), sgtitle(titlestr); end

end