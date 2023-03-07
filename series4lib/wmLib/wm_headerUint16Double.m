%
% wm_headerUint16Double -> This function takes the header content sent as double and 
% converts it into a structure containing specific file-parts.
% This function does this indirectly by creating a converting the double file to a 
% temporary file with uint16 and then reading it back as double.
% 
% Required Inputs 
%       header_content : header content sent as double from wm_extractExpEventsAndHeader.m
% 
% Output
%       Files    : Decoded matlab data format
% 
% Version History:
%    Date               Authors             Notes
%    1-Sep-2019         Georgin             Initial Version
%    02-Nov-2022        Jhilik, Surbhi      changed documentation, header_content format must be uint16. 
%
% ========================================================================================

function files = wm_headerUint16Double(header_content)

filePointer = fopen('temp_header_file_created.mat', 'w');
fwrite(filePointer, header_content,'uint16'); %writes the header
fclose(filePointer);
tmp=load('temp_header_file_created.mat');
delete('temp_header_file_created.mat')
files=tmp.files;

end
