% ----------------------------------------------------------------------
% this function unpacks all the dependencies that is stored in the
% specified dependency structure
% ----------------------------------------------------------------------
% unpackdeps(depstr)
%
% INPUTS
%  depstr = dependency structure returned by packdeps
%
% OUTPUTS
% none          
%
% Credits: Georgin/Pramod/Zhivago
% Change log
%     - 12/05/2017 (GPZ) - First version

function unpackdeps(depstr)

f = fieldnames(depstr);
for fid = 1:length(f)
    field = f{fid};
    if strcmp(field, 'vars')
        vf = fieldnames(depstr.vars);
        for vid = 1:length(vf)
            fprintf('creating variable : %s\n', vf{vid});
            assignin('base', vf{vid}, eval(['depstr.vars.' vf{vid}]));
        end
    elseif strcmp(field, 'mfiles')
        ext = '.m';
        mf = fieldnames(depstr.mfiles);
        for iid = 1:length(mf)
            depfile = [mf{iid} ext];
            fprintf('extracting %s\n', depfile);
            eval(['filestr = depstr.mfiles.' mf{iid} ';']);
            fp = fopen(depfile, 'w'); fprintf(fp, '%s', filestr); fclose(fp);
        end
    end
end