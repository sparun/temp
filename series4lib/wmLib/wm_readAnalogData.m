% 
% wm_readAnalogData -> This function reads the data recorded through multiple analog channels
% of eCube box with timestamp. This function is capable of extracting data
% from multiple files containing data recorded from  a continous session. 
% 
% Required Inputs
%       L1specsOrecubeFolder  : Struct containing / full path of folder containing ecube files
% 
% Outputs
%       analogData            : Concatenated analog data across all digital files (nChannels x nSamples)
%       L1specs               : Updated struct containing digital filenames and timestamps 
% 
% Version History:
%    Date               Authors             Notes
%    01-Sep-2021        Georgin             - First version
%    19-Oct-2021        Georgin, Thomas     - Corrected the time stamp resolution, 
%                                           - added functionality to check correctness of recorded files using on time stamp.
%    27-Oct-2022        SP Arun             - Changed name from wm_readAnalogFiles to wm_readAnalogData
%    31-Oct-2022        Jhilik, Surbhi      - ecubeAnalogFiles forced vectorized and the transposed. So that the format is always cell(1,n).
%                                               for loop needs input as row vector [cell(1,n) format] to function.
%                                           - Changed documentation format.
%    12-Nov-2022        Jhilik, Surbhi      - added check for length of delayBetweenEcubeAnalogFiles
%    17-Dec-2022        Arun                - revamp.
%
% ========================================================================================

function [analogData, L1specs] = wm_readAnalogData(L1specsOrecubeFolder)

% check if input is a folder or L1specs
if(isstruct(L1specsOrecubeFolder))
    L1specs = L1specsOrecubeFolder; 
    ecubeFolder = L1specs.ecubeFolder; 
    ecube = L1specs.ecube; 
else
    ecubeFolder = L1specsOrecubeFolder; 
    ecube = wm_ecubeProperties;
end
ecubeAnalogFiles  = dir([ecubeFolder '\Analog*']);
L1specs.ecubeAnalogFiles ={ecubeAnalogFiles(:).name}';

expectedFileDuration = ecube.specs.expectedRecordDuration; 

% EXTRACT number of channels from filenames
tempFileParts = strsplit(L1specs.ecubeAnalogFiles{1}, {'int16_' '_' '-'});
nChannels     = str2double(tempFileParts{2});
L1specs.ecube.nAnalogChannels = nChannels; 

% READ ANALOG data 
ecubeAnalogVoltsPerBit = ecube.specs.analogVoltPerBit;
analogData             = []; 
analogDataTimestamp    = [];
analogDataNsamples     = []; 
for fileName = L1specs.ecubeAnalogFiles'
    fid = fopen(fullfile(ecubeFolder,fileName{1}), 'r');
    
    % READ eCube 1000MHz (1 nano second resolution) timestamp
    % from start of every file and append to digitalDataTimestamp
    tA                  = fread(fid, 1, 'uint64=>uint64'); 
    analogDataTimestamp = cat(1, analogDataTimestamp, tA);
    
    % READ analog data from file and append to analogData
    dA         = fread(fid, [nChannels,inf], 'int16=>single');
    analogData = cat(2, analogData, dA*ecubeAnalogVoltsPerBit);

    analogDataNsamples = cat(1,analogDataNsamples,length(dA)); 

    fclose(fid);
end
analogData = analogData';

L1specs.ecubeTimeStamps.analogDataTimeStamp = analogDataTimestamp; 
L1specs.ecubeTimeStamps.analogDataNsamples = analogDataNsamples; 

% CHECK if the ecube analog files are sequential and of 10min each (precision = 1s)
delayBetweenEcubeAnalogFiles = diff(double(analogDataTimestamp))*(10^-9); % in seconds
if sum(round(delayBetweenEcubeAnalogFiles,1) ~= expectedFileDuration) > 0
    error('FAILURE! Time delay between successive ecube analog files differs by more than 1 sec from %d s!',expectedFileDuration);
end 

% SUCCESS message
disp('SUCCESS! Ecube analog data extracted. Continuing.')
end