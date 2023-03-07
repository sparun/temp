%
% wm_readIMUadcData -> This function read imu data and gives adc value and time axis
% Required Inputs:
%       fullFileName  : give the path to the .bin file being read
%       chId          : give the channel id to read from
%
% Outputs:
%       adc           : outputs the adc value
%       t           : outputs the time axis for adc
% 
% Version History:
%    Date               Authors             Notes
%    Unknown            SP Arun             Created the first version
%    16-Nov-2022        Jhilik, Surbhi      Converted into function
%
% ========================================================================================

function [adc, t] = wm_readIMUadcData(fullFileName, chId)

adc = [];tadc = [];
fid = fopen(fullFileName ,'r');

t = fread(fid,1,'uint64=>uint64'); % read timestamp from start of file
tadc = cat(1,tadc,t);
nch = 10;
fseek(fid,(chId-1)*2,'cof'); % shift in bytes
d = fread(fid, [1,inf], 'int16=>single',(nch-1)*2);

adc = cat(chId,adc,d);
adc = adc * 3.0 / 32768;    % scaling factor given by WM
t = (0:(length(adc)-1));
fclose(fid);
end