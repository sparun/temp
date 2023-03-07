%
% wm_extractTrialEventsAndFooter -> This function decodes trial events and footer within a trial. 
% 
% Required Inputs
%       events      : (nEvents x 2) A matrix containing the event codes
%                      send from ML during the experiment with time
%                      stamp.First column is event code and second column
%                      is eCube time stamp.
% 
% Outputs
%       trialEvents : struct with trialwise eventcode, eventcodenames, tEcube, tEcubePtd, and ptdEvents
%       trialFooter : table with trialwise information of trial,. block, error, etc... 
% 
% Version History:
%    Date               Authors             Notes
%    16-Nov-2021        Georgin, Thomas     Initial Version  
%    17-Dec-2022        Arun                Extensive revamp
%    28-Feb-2023        Jhilik              Added condition for not extracting 'trialError', 'expectedResponse',
%                                           'trialFlag', and editables for netcamSync task.
%    06-Mar-2023        Arun                Made StimInfo section common to all tasks 
% ========================================================================================

function [trialEvents,trialFooter]= wm_extractTrialEventsAndFooter(events)
[~, ~, ~, ~, ~, exp, trl, ~, ~] = ml_loadEvents();

tStartInd   =   find(events(:,1) == trl.start);
tStopInd    =   find(events(:,1) == trl.stop);
fStartInd   =   find(events(:,1) == trl.footerStart);
fStopInd    =   find(events(:,1) == trl.footerStop);
nTrials     =   length(tStartInd);

trialFooter = [];
for trial = 1:nTrials
    trialEvents(trial,1).eventcodes     = events(tStartInd(trial):tStopInd(trial),1);
    trialEvents(trial,1).tEcube         = events(tStartInd(trial):tStopInd(trial),2);
    
    % GET trialEvent names from codeNumbers
    trialEvents(trial,1).eventcodenames = ml_getEventName(trialEvents(trial,1).eventcodes)';
    
    % Trial Footer
    footerCodeNumbers = events(fStartInd(trial)+1:fStopInd(trial),1);
    
    % identifying nans
    footerCodeNumbers(footerCodeNumbers==exp.nan)=nan;
    
    %% General trial properties
    % Identify the tasks
    taskType  = ml_getEventName(footerCodeNumbers(1));
    trialFooter.taskType{trial,1} = taskType{1}(5:end);
    
    trialFooter.trial(trial,1)            = footerCodeNumbers(2)-trl.trialShift;
    trialFooter.block(trial,1)            = footerCodeNumbers(3)-trl.blockShift;  
    trialFooter.trialWBlock(trial,1)      = footerCodeNumbers(4)-trl.trialWBlockShift;
    trialFooter.condition(trial,1)        = footerCodeNumbers(5)-trl.conditionShift;

    if strcmp(taskType,'taskSync')==0 % DO NOT EXECUTE this loop for taskSync 
        trialFooter.trialError(trial,1)       = footerCodeNumbers(6)-trl.outcomeShift;
        trialFooter.expectedResponse(trial,1) = footerCodeNumbers(7)-trl.expRespFree ;
        trialFooter.trialFlag(trial,1)        = footerCodeNumbers(8)-trl.typeShift;

        % add ML editable variables into each trial 
        edtStartIndex       = find(footerCodeNumbers==trl.edtStart);
        edtStopIndex        = find(footerCodeNumbers==trl.edtStop);
        editableCodeNumbers = footerCodeNumbers(edtStartIndex+1:edtStopIndex-1);
        trialFooter.goodPause(trial,1)        = editableCodeNumbers(1)-trl.shift;
        trialFooter.badPause(trial,1)         = editableCodeNumbers(2)-trl.shift;
        trialFooter.taskFixRadius(trial,1)    = (editableCodeNumbers(3)-trl.shift)/10;
        trialFooter.calFixRadius(trial,1)     = (editableCodeNumbers(4)-trl.shift)/10;
        trialFooter.rewardVol(trial,1)        = (editableCodeNumbers(5)-trl.shift)/1000;
    end

    %% Extract Stim Info
    stimInfoStartIndex          = find(footerCodeNumbers==trl.stimStart);
    stimInfoStopIndex           = find(footerCodeNumbers==trl.stimStop);
    stimInfoCodeNumbers         = footerCodeNumbers(stimInfoStartIndex+1:stimInfoStopIndex-1);
    N                           = length(stimInfoCodeNumbers);
    stimInfoCodeNumbers         = reshape(stimInfoCodeNumbers,[3,N/3]);  % reshape to get stimID & stimPos easily
    trialFooter.stimID{trial,1} =(stimInfoCodeNumbers(1,:)-trl.shift)';
    trialFooter.stimPos{trial,1}=((stimInfoCodeNumbers(2:3,:)-trl.picPosShift)/1000)';
end 

% SUCCESS message
trialFooter = struct2table(trialFooter);
disp('SUCCESS! Trial events and footer info extracted. Continuing.')
end