% reads event code definitions from plx.h
libdir = which('plx.h'); libdir = libdir(1:end-5); 
fid = fopen([libdir 'plx.h']);
tline = '';
while ischar(tline)
    tline = fgetl(fid);
    if strfind(tline, '#define')
        A = sscanf(tline, '%*s%*c%s%*c%d');
        varname = char(A(1:end-1))';
        if ~isempty(varname)
            varval  = A(end);
            assignin('caller', varname, varval);
        end
    end
end
fclose(fid);
clear fid tline A varname varval;