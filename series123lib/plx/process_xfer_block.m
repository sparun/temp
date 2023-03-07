% processes the xfer block of the plx data and extracts all the information into the header structure
% information and cortex experiment files (itm, cnd, and tim)
%    - plx_file is the name of the plx file being processed
%    - prog_id is the program id, if known
%    - event_codes is the event markers extracted from the plx file
%    - stimfolder is the folder where all the stimuli are stored
%    - ctxfolder is the name of the folder where the extracted ctxfiles should be stored
%    - ishugo = 1 indicates hugo's data, and 0 otherwise
%    - header will contain the header information extracted from the xfer block
function header = process_xfer_block(plx_file, prog_id, event_codes, stimfolder, ctxfolder, ishugo, removeitems, std_item_names)

global C;

header = [];

[matchstart, matchend] = regexp(char(event_codes'),char([C.START_XFER ...
                                                         '.*?' ...
                                                         C.END_XFER]));
xfer_segs = [matchstart' matchend'];
if isempty(xfer_segs), disp('No xfer block detected'); return; end

event_codes = event_codes(xfer_segs(end,1):xfer_segs(end,2));

% creating an intermediate structure to store the information extracted from the transfer block
header = create_header();
header.valid = 1;

save_flag = 1; % to indicate if ctx files should be saved/deleted

if ~exist('ctxfolder') | isempty(ctxfolder), save_flag = 0; ctxfolder = '.'; end;
if ~exist('ishugo') | isempty(ishugo), ishugo = 0; end;
if ~exist('removeitems') | isempty(removeitems), removeitems = 0; end;


if isempty(C)
    % loading event code definitions
    C = load('plxh');
    % adding program names
    mkprognames(ishugo);
end

if ~exist('event_codes') | isempty(event_codes), [n_events, event_codes_ts, event_codes] = plx_event_ts(plx_file, 257); end

% extracting monkey name
monkey_name = event_codes((event_codes >= C.MONKEY_NAME_START) & (event_codes <= C.MONKEY_NAME_END)) - C.MONKEY_NAME_START;
if length(monkey_name) == 2
    header.monkey_name = [char(monkey_name(1) + C.LCASE_ASCII) char(monkey_name(2) + C.LCASE_ASCII)];
else
    header.valid = 0;
end

% extracting track id
track_id = event_codes((event_codes >= C.TRACK_ID_START) & (event_codes <= C.TRACK_ID_END)) - C.TRACK_ID_START;
if length(track_id) == 1, header.track_id    = track_id; else header.valid = 0; end

% extracting track location
track_loc = event_codes((event_codes >= C.TRACK_LOC_START) & (event_codes <= C.TRACK_LOC_END)) - C.TRACK_LOC_START;
if length(track_loc) == 1
    header.track_loc = char(track_loc + C.LCASE_ASCII);
else
    header.valid = 0;
end

% extracting AP/ML
if ishugo == 1
    if strncmp(plx_file, 'hu007', 5), header.AP = -1; header.ML = 0;
    elseif strncmp(plx_file, 'hu008', 5), header.AP = -1; header.ML = 1;
    elseif strncmp(plx_file, 'hu009', 5), header.AP = 0;  header.ML = 1;
    end
else
    AP = event_codes((event_codes >= C.AP0-99) & (event_codes <= C.AP0+99)) - C.AP0;
    if length(AP) == 1, header.AP = AP; else header.valid = 0; end
    ML = event_codes((event_codes >= C.ML0-99) & (event_codes <= C.ML0+99)) - C.ML0;
    if length(ML) == 1, header.ML = ML; else header.valid = 0; end
    if strcmp(header.monkey_name, 'ro') == 1
        if track_id == 93, header.AP = -3; header.ML = 1; end
        if track_id == 117, header.AP = 0; header.ML = 1; end
    end
end

% extracting electrode depth
depth_first3 = event_codes((event_codes >= C.DEPTH_FIRST3_START) & (event_codes <= C.DEPTH_FIRST3_END)) - C.DEPTH_FIRST3_START;
depth_last3 = event_codes((event_codes >= C.DEPTH_LAST3_START) & (event_codes <= C.DEPTH_LAST3_END)) - C.DEPTH_LAST3_START;
if length(depth_first3) == 1 & length(depth_last3) == 1
    header.depth = depth_first3 * 1000 + depth_last3;
else
    header.valid = 0;
end

% using the plx file name as neuron id in the absence of one in the header
if header.valid == 1
    header.site_id   = sprintf('%02s%03d%1s', header.monkey_name, track_id, header.track_loc);
else
    % header.site_id = plx_file(1:6);
    return;
end

% extracting program name/id
if ishugo ~= 1
    q1 = find(event_codes == C.PROG_NAME_START);
    q2 = find(event_codes == C.PROG_NAME_END);
    prog_name = event_codes(q1+1:q2-1);
    prog_name = char(prog_name)';
    prog_ver = event_codes((event_codes >= C.VERSION_START) & (event_codes <= C.VERSION_END)) - C.VERSION_START;
    prog_ver = char(prog_ver + C.LCASE_ASCII);
    header.prog_name = prog_name;
    header.version = prog_ver;
    nprogs = length(C.progname);
    for i = 1:nprogs
        if strcmp(char(C.progname{i,1}), prog_name) == 1, header.prog_id = i + C.PROG_ID_START; end
    end
else
    header.prog_id = prog_id;
    header.prog_name = C.progname{prog_id - C.PROG_ID_START,1};
    header.version = [];
end

% extracting ctx filenames/files
namebegs = find(event_codes == C.FILENAME_BEGIN);
nameends = find(event_codes == C.FILENAME_END);
databegs = find(event_codes == C.FILE_BEGIN);
dataends = find(event_codes == C.FILE_END);
assert(length(namebegs) == length(nameends));
assert(length(namebegs) == length(databegs));
assert(length(databegs) == length(dataends));
nfiles = length(namebegs);
fprintf('%d files detected\n', nfiles);
timcounter = 1;
xfer_bytes = 0;
for i = 1:nfiles
    filename = char(event_codes(namebegs(i)+1:nameends(i)-1))';
    beg = find(filename == '\'); if(length(beg) > 1), beg = beg(end); end;
    if beg == 0, beg = 1; end
    filename = filename(beg+1:end);
    fid = fopen([ctxfolder '\' filename],'w');
    filedata = event_codes(databegs(i)+1:dataends(i)-1);
    fwrite(fid,filedata);
    fclose(fid);
    xfer_bytes = xfer_bytes + length(filedata);
    ext = filename(end-2:end);
    switch ext
        case 'itm'
            header.itmfile = filename;
            if exist('stimfolder') & ~isempty(stimfolder)
                [header.itms header.itm_names header.item_ids] = readitmfile([ctxfolder '\' filename], stimfolder, removeitems, 1, std_item_names);
            end
        case 'cnd'
            header.cndfile = filename;
            header.cnds = readcndfile([ctxfolder '\' filename]);
        case '.t4'
            header.timfile{timcounter,1} = filename;
            timcounter = timcounter + 1;
        case 'tim'
            header.timfile{timcounter,1} = filename;
            timcounter = timcounter + 1;
    end
    if save_flag == 0, delete([ctxfolder '\' filename]); end
end
header.plxfile = plx_file;
end

% defines/creates the header structure
function header = create_header()
header = struct(...
    'valid', [],...
    'monkey_name', [],...
    'track_id', [],...
    'track_loc', [],...
    'AP', [],...
    'ML', [],...
    'depth', [],...
    'site_id', [],...
    'prog_name', [],...
    'version', [],...
    'prog_id', [],...
    'itms', [],...
    'itm_names', [],...
    'cnds', [],...
    'cnd_grps', [],...
    'plxfile', [],...
    'itmfile', [],...
    'cndfile', [],...
    'timfile', [],...
    'grpfile', []);
end
