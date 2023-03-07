% function orgrawplx(dest_root)
%
% INPUTS
%       dest_root  : folder where the files are to be moved
%                    default - parent folder
% OUTPUTS
%    None
%
% USAGE
%
% DESCRIPTION
%     this function copies the plx files from the recorded folder to the
%     appropriate experiment folder
%     assumption here is that the plx filenames contain the experiment name:
%     e.g. ro002a_02_dtx.plx
function orgrawplx(dest_root)
global C;
dbstop if error;
if ~exist('dest_root') | isempty(dest_root), dest_root =  '..\'; end
% loading event code definitions
C = load('plxh');
% % loading program names
mkprognames();
nprogs = length(C.progname);
plx_list = dir('*.plx'); n_plx = length(plx_list);
for file_id = 1:n_plx
    plxname = plx_list(file_id).name;
    % deducing experiment name from the plx filename
    q = find(plxname == '_', 2); q1 = q(1) + 1; q2 = q(2) - 1; q3 = q(2) + 1;
    q = find(plxname == '.', 1); q4 = q - 1;
    prog_num = str2double(plxname(q1:q2));
    prog_name = plxname(q3:q4-1);
    ctxname = [plxname(1:q1-2) '.' num2str(prog_num)];
    if strncmp(plxname, 'hu001a_01', 9) | strncmp(plxname, 'hu007a_01', 9) | strncmp(plxname, 'hu007a_04', 9) | strncmp(plxname, 'hu009a_02', 9)
        prog_id = 2;
    elseif strncmp(plxname, 'hu007a_02', 9) | strncmp(plxname, 'hu008a_01', 9)
        prog_id = 3;
    elseif strncmp(plxname, 'hu008a_02', 9) | strncmp(plxname, 'hu009a_01', 9)
        prog_id = 4;
    elseif strncmp(plxname, 'hu008a_03', 9)
        prog_id = 5;
    elseif strncmp(plxname, 'hu007a_03', 9) | strncmp(plxname, 'hu008a_04', 9)
        prog_id = 6;
    else
        for i = 1:nprogs
            if strcmp(char(C.progname{i,1}), prog_name) == 1, prog_id = i; break; end
        end
    end
    dest_folder1 = sprintf('%s%02d_%s\\raw\\', dest_root, prog_id, prog_name);
    dest_folder2 = sprintf('%s%02d_%s\\ctxdata\\', dest_root, prog_id, prog_name);
    if ~exist(dest_folder1, 'dir'), mkdir(dest_folder1); end
    if ~exist(dest_folder2, 'dir'), mkdir(dest_folder2); end
    fprintf('copying %s --> %s\n', plxname, [dest_folder1 plxname]);
    copyfile(plxname, [dest_folder1 plxname]);
    fprintf('copying %s --> %s\n', ['..\ctxdata\' ctxname], [dest_folder2 ctxname]);
    movefile(['..\ctxdata\' ctxname], [dest_folder2 ctxname]);
end
end