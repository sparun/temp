%
% wm_checkEcubeBhvDates  -> checks dates and times of ecube-analog, neural and ml file
% and checks if they are in a sensible order, to reduce human error.
%
% Required Inputs
%       bhvFileFullPath        : full path of .bhv2 file
%       ecubeFolderFullPath    : full path of ecube folder carrying analog and digital files
%       neuralFileFullPath     : full path of neural data file (.bin / .nex)
% Outputs
%       tbhv                   : date and time of .bhv2 file.
%       tecube                 : date and time of ecube analog.bin file.
%       tneural                : date and time of neural .bin/.nex file.
%
% Version History:
%    Date               Authors             Notes
%    08-Dec-2022        Shubho              First Implementation
%    17-Dec-2022        Arun                Extensive revamp
%
% ========================================================================================

function [tbhv,tecube,tneural] = wm_checkEcubeBhvDates(bhvFileFullPath,ecubeFolderFullPath,neuralFileFullPath)

[~,bhvfile] = fileparts(bhvFileFullPath);
q = strfind(bhvfile,'_');
bhvdatetime = bhvfile(q(end-1)+1:end);
tbhv = datetime(bhvdatetime,'InputFormat','yyyyMMdd_HHmmss');

files = dir([ecubeFolderFullPath, '\Analog*.bin']); [~,ecubefilename] = fileparts(files(1).name);
q = strfind(ecubefilename,'_');
ecubedatetime = ecubefilename(q(end-1)+1:end);
tecube = datetime(ecubedatetime,'InputFormat','yyyy-MM-dd_HH-mm-ss');

[~,neuralfile] = fileparts(neuralFileFullPath);
q = strfind(neuralfile,'HSW_'); q=q+4;
if(~isempty(q))
    neuraldatetime = neuralfile(q:q+19);
    tneural = datetime(neuraldatetime,'InputFormat','yyyy_MM_dd__HH_mm_ss');
else
    q = strfind(neuralfile,'int16_'); q=q+6;
    neuraldatetime = neuralfile(q:q+19);
    tneural = datetime(neuraldatetime,'InputFormat','yyyy-MM-dd_HH-mm-ss');
end

% print results
fprintf('---- FILE DATE SANITY CHECK ---- \n');
fprintf('eCube file start   : %s \n',tecube);
fprintf('Neural file start  : %s \n',tneural);
fprintf('ML BHV file start  : %s \n',tbhv);
datediff_ecubeneural = abs(tecube.Day-tneural.Day)+abs(tecube.Month-tneural.Month)+abs(tecube.Year-tneural.Year);
datediff_neuralbhv   = abs(tbhv.Day-tneural.Day)+abs(tbhv.Month-tneural.Month)+abs(tbhv.Year-tneural.Year);
totaldiff = datediff_ecubeneural+datediff_neuralbhv;
if(totaldiff==0)
    fprintf('SUCCESS! ecube, neural, ML files were recorded on the same day :-) \n');
else
    error('FAILURE! ecube, neural & ML file dates are not the same!');
end

if(tecube < tbhv & tecube < tneural & tneural < tbhv)
    fprintf('SUCCESS! File times are as expected: first ecube, then neural, then ML file\n');
else
    fprintf('FAILURE! File times are NOT as expected! Please check your files.\n');
end
fprintf('-------------------------------- \n \n');

end