%
% wm_processBinFilename  -> processes .bin filename for various purposes.
%
% Required Inputs
%       binFilename    : string containing the full .bin filename including extension.
%
% Outputs
%       nch            : number of channels present in bin file - from binfilename
%       samplingrate   : sampling rate of bin file - from filename
%       iswireless     : whether the file is a wired (0) or wireless (1) recording - from filename
%
% Version History:
%    Date               Authors             Notes
%    17-Dec-2022        Arun                First Implementation
%
% ========================================================================================

function [nch,samplingrate,iswireless] = wm_processBinFilename(binFilename)

% check if wired or wireless based on binFilename
iswireless = contains(binFilename,'hsamp');
if(iswireless) % its a wireless file
    q1 = strfind(binFilename,'hsamp_'); 
    q2 = strfind(binFilename,'ch'); 
    nch = str2num(binFilename(q1+6:q2-1));
    delimiterPos = strfind(binFilename,'_');
    dotPos = strfind(binFilename,'.');
    samplingrate = str2num(binFilename(delimiterPos(end)+1: (dotPos-4))); 
else
    q1 = strfind(binFilename,'Headstages_'); 
    q2 = strfind(binFilename,'_Channels'); 
    nch = str2num(binFilename(q1+11:q2-1));
    samplingrate = 25000;
end

if(~exist('nch')||isempty(nch)), 
    error('Error: Number of channels not found in binFilename'); 
end

end