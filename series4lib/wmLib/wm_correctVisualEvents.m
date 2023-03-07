%
% wm_correctVisualEvents  -> corrects visual events based on actual photodiode flip times
%
% Required Inputs
%       trialEvents    : trialEvents carrying eventcodes, tEcube, ptdEvents
%
% Outputs
%       trialEvents    : updates trialEvents with necessary info after ptd-corection
%
% Version History:
%    Date               Authors             Notes
%    08-Dec-2022        Shubho              First Implementation
%     17-Dec-2022       Arun                Extensive revamp.
%
% ========================================================================================

function trialEvents = wm_correctVisualEvents(trialEvents) 

% get event codes for all visual events 
[~, pic]        = ml_loadEvents;
fieldNames      = fieldnames(pic);
for i=1:length(fieldNames)
    allVisEvents(i) =  pic.(fieldNames{i});
end

% initialise variables
for trialid = 1:length(trialEvents)
    % if(trialid==43), keyboard; end % uncomment for debugging
    trialEventCodes   = trialEvents(trialid).eventcodes;
    tEcube            = trialEvents(trialid).tEcube; 
    isEventVisual     = ismember(trialEventCodes,allVisEvents); % 0/1 array of all visual events in trialEventCodes
    trialPtdEventTime = trialEvents(trialid).ptdEvents; % PTD event times in that trial
    nPtdEvents        = length(trialPtdEventTime); 

    nVisualEvents     = length(find(isEventVisual)); 
    visualEventId     = find(isEventVisual==1);                            % ids of all visual events in trialEventCodes
    repeatId          = find(diff(visualEventId)==1);                      % first id of consecutive visual event indexed into visualEventId
    uniqueId          = vec(setdiff([1:length(visualEventId)], repeatId)); % these will be the trialEventCode ids for unique visual events
    isEventUniqueVisual = isEventVisual; isEventUniqueVisual(visualEventId(repeatId))=0; 
    nUniqueVisualEvents = length(uniqueId); 
        
    if(nUniqueVisualEvents==nPtdEvents)
        ptdEventCount=1; tEcubePtd = tEcube; 
        for codeid = 2:length(trialEventCodes)
            if(isEventVisual(codeid)==1 & isEventVisual(codeid-1)==0) % current event is visual and previous event is not visual
                tEcubePtd(codeid) = trialPtdEventTime(ptdEventCount); % set tEcubePTD to be the PTD event time
                ptdEventCount=ptdEventCount+1; 
            elseif(isEventVisual(codeid)==1 & isEventVisual(codeid-1)==1) % current event and previous event are both visual
                tEcubePtd(codeid) = trialPtdEventTime(ptdEventCount-1); % set tEcubePTD to be the previously set PTD event time
            end
        end
    else
        tEcubePtd = []; 
    end

    % store diagnostic info
    trialEvents(trialid).tEcubePtd = tEcubePtd; 
    trialEvents(trialid).isVisualEvent = isEventVisual; 
    trialEvents(trialid).isUniqueVisualEvent = isEventUniqueVisual; 
    trialEvents(trialid).nUniqueVisualEvents = nUniqueVisualEvents; 
    trialEvents(trialid).nPtdEvents = nPtdEvents; 
    trialEvents(trialid).PtdMismatchFlag = (nUniqueVisualEvents~=nPtdEvents); 
end

