
%
% wm_readBinData -> reads eCube .bin file specified by the fileName and return the recorded voltage in each channel
%
% Required Inputs
%       filespec       : folder of wired / wireless *.bin files OR single bin file specified with path+filename
%
% Optional inputs
%       chid           : ID of channel for which data is sought
%
% Outputs
%       hsdata         : nch x nsamples matrix of channel voltages (in Volts)
%                        nsamples = samplingrate*recordingduration
%       hsts           : nfiles x 1 array of eCube timestamps 
%       samplingrate   : sampling rate (in Hz) for the .bin file.
%       iswireless     : whether the file is a wired (0) or wireless (1) recording - from filename
% 
%  Notes:
%    The format of each bin file of WM is 
%       [eCubeFileTimestamp T1_ch1 T1_ch2 ...T1_chM T2_ch1 T2_ch2... T2_chM TN_ch1 TNch2...TN_chM]
% 
% Version History:
%    Date               Authors             Notes
%    Unknown            Georgin             Initial version
%    12-Jan-2021        Sini Simon M        Changes for converting to a lib function
%    01-Nov-2021        Georgin             Fixed the bug, uint16-> int16 
%    31-Oct-2022        SP Arun, Sini       Reconfirmed with Jerome/Tim (email dated 20-Oct-2022)
%                                           Renamed from wm_readWirelessData to wm_readBinData
%                                           Modified to include reading a particular channel 
%                                           Removed sampling rate
%    14-Nov-2022        Shubho              Added sampling rate as output for wired / wireless files
%
% ========================================================================================

function [hsdata,hsts,samplingrate,iswireless] = wm_readBinData(filespec,chid)
if(isfolder(filespec))
    files = dir([filespec '*.bin']);
else
    files = dir(filespec);
end

% check if wired or wireless based on filename
fileName = files(1).name; % assuming all files are like files(1)
[nch,samplingrate,iswireless] = wm_processBinFilename(fileName); 

hsdata = []; hsts = [];
for fileid = 1:length(files)
    fp = fopen([files(fileid).folder '\' files(fileid).name], 'r');

    ts = fread(fp, 1, 'uint64=>uint64'); % read eCube 1000 MHz timestamp from start of every file
      
    if(exist('chid'))
        fseek(fp,(chid-1)*2,'cof'); % shift in bytes to get to selected channel
        Dchxs = fread(fp, [1,inf], 'int16=>single',(nch-1)*2); % skip is in bytes
    else
        Dchxs = fread(fp, [nch,inf], 'int16=>single');
    end
    Dchxs = double(Dchxs)*6.25e-3/32768; % convert to double (scale to Volts)

    % concatenate across files 
    hsts = cat(1, hsts, ts); 
    hsdata = cat(2, hsdata, Dchxs); 
end

return