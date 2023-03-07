% function renameplx()
% INPUTS
%     None
% OUTPUTS
%     None
% USAGE
%     Run 'renameplx' from the folder where the plx files are stored
% DESCRIPTION
%     this function converts the plx filenames to contain the experiment name
%     too:
%     e.g. ro002a_02.plx --> ro002a_02_dtx.plx
function renameplx()
global C;
dbstop if error;
% loading event code definitions
C = load('plxh');
% % loading program names
mkprognames();
nprogs = length(C.progname);
plx_list = dir('*.plx'); n_plx = length(plx_list);
for file_id = 1:n_plx
    plxname = plx_list(file_id).name;
    if strncmp(plxname, 'hu001a_01', 9) | strncmp(plxname, 'hu007a_01', 9) | strncmp(plxname, 'hu007a_04', 9) | strncmp(plxname, 'hu009a_02', 9)
        prog_name = 'srch';
        prog_ver = 'a';
    elseif strncmp(plxname, 'hu007a_02', 9) | strncmp(plxname, 'hu008a_01', 9)
        prog_name = 'ntx';
        prog_ver = 'a';
    elseif strncmp(plxname, 'hu008a_02', 9) | strncmp(plxname, 'hu009a_01', 9)
        prog_name = 'dtx';
        prog_ver = 'a';
    elseif strncmp(plxname, 'hu008a_03', 9)
        prog_name = 'dtxct';
        prog_ver = 'a';
    elseif strncmp(plxname, 'hu007a_03', 9) | strncmp(plxname, 'hu008a_04', 9)
        prog_name = 'dtxrd';
        prog_ver = 'a';
    elseif strncmp(plxname, 'ro025a_04', 9)
        prog_name = 'sizel';
        prog_ver = 'a';
    elseif strncmp(plxname, 'ro028a_01', 9)
        prog_name = 'view';
        prog_ver = 'a';
    elseif strncmp(plxname, 'ro042a_01', 9)
        prog_name = 'ntx';
        prog_ver = 'c';
    elseif strncmp(plxname, 'xa027b_01', 9)
        prog_name = 'viewct';
        prog_ver = 'a';
    elseif strncmp(plxname, 'ro139a_07', 9) | strncmp(plxname, 'xa035a_01', 9)
        prog_name = 'asy';
        prog_ver = 'a';
    elseif strncmp(plxname, 'ro097a_03', 9)
        prog_name = 'srchg';
        prog_ver = 'a';
    else
        % reading event codes from the plx file
        [n_events, event_codes_ts, event_codes] = plx_event_ts(plxname, 257);        
        % extracting program name/id
        q1 = find(event_codes == C.PROG_NAME_START);
        q2 = find(event_codes == C.PROG_NAME_END);
        prog_name = event_codes(q1+1:q2-1);
        prog_name = char(prog_name)';
        for i = 1:nprogs
            if strcmp(char(C.progname{i,1}), prog_name) == 1, prog_id = i; end
        end
        prog_ver = event_codes((event_codes >= C.VERSION_START) & (event_codes <= C.VERSION_END)) - C.VERSION_START;
        prog_ver = char(prog_ver + C.LCASE_ASCII);
        plx_close(plxname);
    end
    q = find(plxname == '.', 1); q = q - 1;
    new_filename = [plxname(1:q) '_' prog_name prog_ver '.plx'];
    fprintf('renaming %s --> %s\n', plxname, new_filename);
    movefile(plxname, new_filename);
end
end