% -------------------------------------------------------------------
% This function waits for a maximum of timer seconds to check if the
% subject is fixating and also awaits a keypress
% -------------------------------------------------------------------
% [fail_flag, response_flag, key_time] = psy_check_fix(xy_dva, keys, timer)
% REQUIRED INPUTS
%  xy_dva  = (x,y) coordinates of the point to be fixated
%  keys           = allowed set of keys
% OPTIONAL INPUTS
%  timer        = time for which to check for fixation
% OUTPUTS
%  fail_flag    = true or 1 if fixation was detected within the
%                 specified timer value (in seconds)
%                 false or 0, otherwise
%  response_flag = true or 1 if fixation was detected
%                   false or 0, otherwise
%  key_time      = time taken for keypress
% EXAMPLE
%  psy_check_fix_keypress([-15 -10], [KbName('right') KbName('up'],5);
%  will wait for a maximum of 5 seconds for the subject to fixate at [-15 0] or until he presses the
%  right or up keys
% REQUIRED SUBROUTINES
%  psy_decode_bin_stream
%  psy_transform_iscan_data
%
%  Arun Sripati
%  24/3/2011

function [fail_flag,response_flag,key_time] = psy_check_fix_keypress(xy_dva, keys, timer)

global expt_str;
global eye_data_stream;

task  = expt_str.task;
iscan = expt_str.specs.iscan;

% setting default values
if ~exist('timer', 'var'), timer = Inf; end

% initialize stuff for keyboard check
keys = [keys KbName('p') KbName('q')]; RestrictKeysForKbCheck(keys);
flag_keypress = 0; key_time = NaN; 

% initializing variables
fail_flag = 1;
fix_dva_data = [];
iscan_fix_data = [];

n_samples = task.check_fix_samples;
% computing the minimum number of bytes to read from the serial port
min_data = ((n_samples + 2) * iscan.sample_size);

% checking for fixation till the specified time elapses
t = GetSecs(); fail_flag = 0; 
while (GetSecs() - t) < timer
    bytes = 0;
    pktdata = [];
    % reading at least the minimum number of bytes from the
    % serial port in order to check fixation
    while bytes < min_data
        read_data = IOPort('Read', iscan.port);
        pktdata = [pktdata read_data];
        bytes = size(pktdata,2);
        WaitSecs(.004);
    end
    
    % transferring a copy of the read data to the global stream/buffer
    eye_data_stream = [eye_data_stream pktdata];
    
    % decoding and extracting the last 100ms data
    iscan_fix_data = psy_decode_bin_stream(pktdata);
    iscan_fix_data = iscan_fix_data(:,1:2);
    iscan_fix_data = iscan_fix_data(end-n_samples+1:end,:);
    
    % Transforming ISCAN signal to x & y dva's
    fix_dva_data = psy_transform_iscan_data(iscan_fix_data);

    % define condition for fixation break
    flag_break_fix = all(abs(xy_dva(1) - fix_dva_data(:,1)) > task.fix_window) ||...
        all(abs(xy_dva(2) - fix_dva_data(:,2)) > task.fix_window); 

    % If the eye position exceeds fixation window OR there was a keypress
    if(flag_break_fix)
        fail_flag = 1;
        break;
    end
    
    % now check for a key press
    [flag_keypress,kt,key_code] = KbCheck;

    if(flag_keypress)
        key_time = kt; % key press time in seconds
        response = find(key_code);
        response = response(1); % in case two keys are pressed, select the first one
        response_flag = find(keys==response); % 1 if first key was pressed, 2 if second key was pressed, etc.
        break; 
    end
    
end

return;