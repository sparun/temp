% header = xtractfilesfromplx(plxfile)
%
% INPUTS
%   plxfile : a .plx or .pl2 file
%
% OUTPUTS
%    header : header structure with information extracted from the xfer
%             block, like monkey name, track info, AP/ML, etc.
%
% USAGE
%    xtractfilesfromplx('ro041a_08_ntxc_units.plx');
%    xtractfilesfromplx('ka061a_04_seltolb.pl2');
%
% DESCRIPTION
%      Extracts all the files transmitted from cortex during the xfer block
%      and stores them in the current folder
%
% Zhivago Kalathupiriyan
% 18 Sep 2014


function header = xtractfilesfromplx(plxfile)

% reading event code definitions
readplxh;

% extracting the xfer block
[~, ~, event_codes] = plx_event_ts(plxfile, 257);
[matchstart, matchend] = regexp(char(event_codes'),char([START_XFER '.*?' END_XFER]));
xfer_segs = [matchstart' matchend'];
if isempty(xfer_segs), disp('No xfer block detected'); return; end
event_codes = event_codes(xfer_segs(end,1):xfer_segs(end,2));

% extracting header information from the xfer block
monkey_name = event_codes((event_codes >= MONKEY_NAME_START) & (event_codes <= MONKEY_NAME_END)) - MONKEY_NAME_START;
header.monkey_name = [char(monkey_name(1) + LCASE_ASCII) char(monkey_name(2) + LCASE_ASCII)]
header.track_id = event_codes((event_codes >= TRACK_ID_START) & (event_codes <= TRACK_ID_END)) - TRACK_ID_START;
track_loc = event_codes((event_codes >= TRACK_LOC_START) & (event_codes <= TRACK_LOC_END)) - TRACK_LOC_START;
header.track_loc = char(track_loc + LCASE_ASCII);
header.AP = event_codes((event_codes >= AP0-99) & (event_codes <= AP0+99)) - AP0;
header.ML = event_codes((event_codes >= ML0-99) & (event_codes <= ML0+99)) - ML0;
depth_first3 = event_codes((event_codes >= DEPTH_FIRST3_START) & (event_codes <= DEPTH_FIRST3_END)) - DEPTH_FIRST3_START;
depth_last3 = event_codes((event_codes >= DEPTH_LAST3_START) & (event_codes <= DEPTH_LAST3_END)) - DEPTH_LAST3_START;
header.depth = depth_first3 * 1000 + depth_last3;

q1 = find(event_codes == PROG_NAME_START);
q2 = find(event_codes == PROG_NAME_END);
prog_name = event_codes(q1+1:q2-1);
prog_name = char(prog_name)';
prog_ver = event_codes((event_codes >= VERSION_START) & (event_codes <= VERSION_END)) - VERSION_START;
prog_ver = char(prog_ver + LCASE_ASCII);
header.prog_name = prog_name;
header.version = prog_ver;

% extracting all the files from the xfer block
namebegs = find(event_codes == FILENAME_BEGIN);
nameends = find(event_codes == FILENAME_END);
databegs = find(event_codes == FILE_BEGIN);
dataends = find(event_codes == FILE_END);
nfiles = length(namebegs);
xfer_bytes = 0;
for i = 1:nfiles
    filename = char(event_codes(namebegs(i)+1:nameends(i)-1))';
    beg = find(filename == '\'); if(length(beg) > 1), beg = beg(end); end;
    if beg == 0, beg = 1; end
    filename = filename(beg+1:end);
    fid = fopen(filename,'w');
    filedata = event_codes(databegs(i)+1:dataends(i)-1);
    fwrite(fid,filedata);
    fclose(fid);
    xfer_bytes = xfer_bytes + length(filedata);
end
header.plxfile = plxfile;
end