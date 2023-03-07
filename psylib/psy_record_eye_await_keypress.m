% -------------------------------------------------------------------
% This function waits for a maximum of timer seconds to during which it stores eye data and 
% awaits a keypress
% -------------------------------------------------------------------
% [response_flag, key_time] = psy_record_eye_await_keypress(xy_dva, keys, timer)
% REQUIRED INPUTS
%  xy_dva  = (x,y) coordinates of the point to be fixated
%  keys           = allowed set of keys
% OPTIONAL INPUTS
%  timer        = time for which to record eye movements and await keypress
% OUTPUTS
%  response_flag = 0 if no key was pressed, 1 if first key was pressed, 2 if second key was pressed, etc
%  key_time      = time of keypress
% EXAMPLE
%  psy_check_fix_keypress([-15 -10], [KbName('right') KbName('up'],5);
%  will wait for a maximum of 5 seconds for the subject to fixate at [-15 0] or until he presses the
%  right or up keys
% REQUIRED SUBROUTINES
%  psy_decode_bin_stream
%  psy_transform_iscan_data
%
%  Arun Sripati
%  27/3/2011

function [response_flag,key_time,fix_dva_data] = psy_record_eye_await_keypress(keys, timer)

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

% collect eye data till the specified timer elapses
t = GetSecs(); response_flag = 0; 
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