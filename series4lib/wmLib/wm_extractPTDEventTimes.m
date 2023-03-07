%
% wm_extractPTDEventTimes -> This function extracts event times based on photodiode-flips defined by high-to-low & low-to-high thresholds.
%
% Required Inputs
%       photodiodeData            : (nSamples x 1) vector containing the measured photodiode signal.
%       PTDthresholds             : [high-to-low low-to-high] array of PTD voltage thresholds for defining PTD events
%       fs                        : Scalar indicating the sampling frequency of the photodiode measurement.
% 
% Outputs
%       photodiodeEventTimes      : Vector showing the times at which photodiode flip occured.
%
% Version History:
%    Date               Authors             Notes
%    17-Dec-2022        Arun                First implementation after extensive revamp.
%
% ========================================================================================

function photodiodeEventTimes = wm_extractPTDEventTimes(photodiodeData,PTDthresholds,fs) 

% Find the transition region for each photodiode event
highToLowThreshold      = PTDthresholds(1); % high-to-low threshold for ptd-signal
lowToHighThreshold      = PTDthresholds(2); % low-to-high threshold for ptd-signal
transitionSignalIndex   = (photodiodeData > lowToHighThreshold & photodiodeData < highToLowThreshold);
photoDiodeIndex         = find([0;diff(transitionSignalIndex)]==1); % finding the first index of ptd-flip
photodiodeEventTimes    = photoDiodeIndex/fs; % converting to time.

end
