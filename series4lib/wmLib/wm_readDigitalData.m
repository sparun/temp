% 
% wm_readDigitalData ->  reads the data recorded through digital channels
% of eCube box with timestamp. This function is capable of extracting data
% from multiple files containing data recorded from  a continous session. 
% 
% Required Inputs
%       L1specsOrecubeFolder  : Struct containing / full path of folder containing ecube files
% 
% Outputs
%       digitalData           : Concatenated digital data across all digital files (nChannels x nSamples)
%       L1specs               : Updated struct containing digital filenames and timestamps
%  
% Version History:
%    Date               Authors             Notes
%    01-Sep-2021        Georgin             First version
%    19-Oct-2021        Georgin, Thomas     - Corrected the time stamp resolution, 
%                                           - added the functionality to check the 
%                                           - correctness of the recorded files based on time stamp.
%    31-Oct-2022        Jhilik, Surbhi      - Changed function name from "wm_readDigitalFiles.m" to "wm_readDigitalData.m".
%                                           - ecubeDigitalFiles forced vectorized and the transposed. So that the format is always cell(1,n).
%                                               for loop needs input as row vector [cell(1,n) format] to function.
%                                           - Changed documentation format.
%    12-Nov-2022        Jhilik, Surbhi      - added check for length of delayBetweenEcubeDigitalFiles
%    17-Dec-2022        Arun                - revamp.
%
% ========================================================================================

function [digitalData, L1specs] = wm_readDigitalData(L1specsOrecubeFolder)

% check if input is a folder or L1specs
if(isstruct(L1specsOrecubeFolder))
    L1specs = L1specsOrecubeFolder; 
    ecubeFolder = L1specs.ecubeFolder; 
    ecube = L1specs.ecube; 
else
    ecubeFolder = L1specsOrecubeFolder; 
    ecube = wm_ecubeProperties;
end
ecubeDigitalFiles = dir([ecubeFolder '\Digital*']);
L1specs.ecubeDigitalFiles={ecubeDigitalFiles(:).name}';

expectedFileDuration = ecube.specs.expectedRecordDuration; 
digitalData          = []; 
digitalDataTimestamp = [];
digitalDataNsamples = [];
for fileName = L1specs.ecubeDigitalFiles'
    fid = fopen(fullfile(ecubeFolder,fileName{1}), 'r');
    
    % READ eCube 1000MHz (1 nano second resolution) timestamp
    % from start of every file and append to digitalDataTimestamp
    tD                   = fread(fid,1,'uint64=>uint64');
    digitalDataTimestamp = cat(1,digitalDataTimestamp,tD);
    
    % READ digital data from file and append to digitalData
    dD          = fread(fid,'uint64=>uint64');
    digitalData = cat(1,digitalData,dD);

    digitalDataNsamples = cat(1,digitalDataNsamples,length(dD)); 
    fclose(fid);
end

L1specs.ecubeTimeStamps.digitalDataTimeStamp = digitalDataTimestamp; 
L1specs.ecubeTimeStamps.digitalDataNsamples = digitalDataNsamples; 

% CHECK if the ecube digital files are sequential and of 10min each (precision = 1s)
delayBetweenEcubeDigitalFiles = diff(double(digitalDataTimestamp))*(10^-9); % in seconds
if sum(round(delayBetweenEcubeDigitalFiles,1) ~= expectedFileDuration) > 0
    error('FAILURE! Time delay between successive ecube digital files differs by more than 1 sec from %d s!',expectedFileDuration);
end

% SUCCESS message
disp('SUCCESS! Ecube digital data extracted. Continuing.')

end