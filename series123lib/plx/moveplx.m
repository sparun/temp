% function moveplx(plx_folder, dest_root) 
%
% INPUTS
%       plx_folder : folder where the plx units files are located
%                    default - current folder
%       dest_root  : folder where the files are to be moved
%                    default - parent folder
% OUTPUTS
%    None
%
% USAGE
%
% DESCRIPTION
%     this function moves the plx files with the following naming convention to
%     the appropriate experiment folder (if the folder does not exist, it'll be
%     created.
%     ro002a_02_dtx.plx
function moveplx(plx_folder, dest_root)
global C;
dbstop if error;
if ~exist('plx_folder') | isempty(plx_folder), plx_folder = '.\'; end
if ~exist('dest_root') | isempty(dest_root), dest_root =  '..\'; end
% loading event code definitions
C = load('plxh');
% % loading program names
mkprognames();
nprogs = length(C.progname);
plx_list = dir([plx_folder '\*.plx']); n_plx = length(plx_list);
for file_id = 1:n_plx
    plxname = plx_list(file_id).name;
    % preparing the plx file names with path
    plx_file = [plx_folder plxname];
    q1 = find(plxname == '_', 2); q1 = q1(2) + 1;
    q2 = find(plxname == '.'); q2 = q2 - 2;
    prog_name = plxname(q1:q2);
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
            if strcmp(char(C.progname{i,1}), prog_name) == 1, prog_id = i; end
        end
    end
    dest_folder = sprintf('%s%02d_%s\\units\\', dest_root, prog_id, prog_name);
    if ~exist(dest_folder, 'dir'), mkdir(dest_folder); end
    fprintf('moving %s --> %s\n', plx_file, dest_folder);
    movefile(plx_file, dest_folder);
end
end