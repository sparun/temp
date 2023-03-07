function plxstats(plx_filespec, exptname, hugo)
global C;
dbstop if error;
delete('plxinfo.xls');
if ~exist('hugo') | isempty(hugo), hugo = 0; end
% loading event code definitions
C = load('plxh');
% loading program names
mkprognames(hugo);
% processing the plx file specification
plx_list = dir(plx_filespec); n_plx = length(plx_list);
q = strfind(plx_filespec, '\'); plx_folder = '.\'; if ~isempty(q), plx_folder = plx_filespec(1:q(end)); end
% processing each plx file
plxinfo = {'Monkey', 'Track ID', 'Track Location', 'Neuron ID', 'AP', 'ML', 'Depth', 'Experiment', 'Version', 'PLX File'};
nexpts = length(C.progname);
nfiles = zeros(nexpts,1);
nunits = zeros(nexpts,1);
for file_id = 1:n_plx
    plxname = plx_list(file_id).name;
    % preparing the plx file names with path
    plx_file = [plx_folder plxname];
    % reading event codes from the plx file
    [n_events, event_codes_ts, event_codes] = plx_event_ts(plx_file, 257);
    % processing experiment-specific plx files, if that option has been used
    if exist('exptname') & ~isempty(exptname)
        q1 = find(event_codes == C.PROG_NAME_START); q2 = find(event_codes == C.PROG_NAME_END);
        plxexptname = event_codes(q1+1:q2-1);
        plxexptname = char(plxexptname)';
        if strcmp(plxexptname, exptname) ~= 1, continue; end
    end
    disp(plxname);
    header = process_xfer_block(plx_file, event_codes);
    prog_id = header.prog_id - C.PROG_ID_START;
    nfiles(prog_id,1) = nfiles(prog_id,1) + 1;
    plxinfo{end+1,1} = header.monkey_name;
    plxinfo{end,2} = header.track_id;
    plxinfo{end,3} = header.track_loc;
    plxinfo{end,4} = header.neuron_id;
    plxinfo{end,5} = header.AP;
    plxinfo{end,6} = header.ML;
    plxinfo{end,7} = header.depth;
    plxinfo{end,8} = header.prog_name;
    plxinfo{end,9} = header.version;
    plxinfo{end,10} = plxname;
    
    % determining the # of channels and units
    wcounts = plx_info(plx_file, 1);
    [ix iy]  = find(wcounts ~= 0);
    channels = unique(iy(iy ~= 1) - 1);
    for channel = channels'
        units = find(wcounts(:,channel+1)~=0)';
        nunits(prog_id,1) = nunits(prog_id,1) + length(units);
    end
end
xlswrite('plxinfo.xls', plxinfo, 'PLX Info');

exptsummary = {'Experiment Name', 'Number of plx files', 'Number of Units'};
for i = 1:nexpts
    exptsummary{end+1,1} = C.progname{i,1};
    exptsummary{end,2} = nfiles(i,1);
    exptsummary{end,3} = nunits(i,1);
end
xlswrite('plxinfo.xls', exptsummary, 'Experiment Summary');
 end