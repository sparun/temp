% -------------------------------------------------------------------
% This function waits for a maximum of timeout seconds to check if the
% subject has made a saccade from the specified position
% -------------------------------------------------------------------
% fail_flag = psy_await_saccade(xy_dva, timeout)
% REQUIRED INPUTS
%  xy_dva  = (x,y) coordinates of the point where the current fixation is
% OPTIONAL INPUTS
%  timeout = time for which to check for saccade
% OUTPUTS
%  fail_flag      = true or 1 if a saccade was detected
%                   false or 0, otherwise
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  psy_await_saccade([-15 -10], 5);
%  will wait for a maximum of 5 seconds for the subject to
%  make a saccade from [-15 0]
% REQUIRED SUBROUTINES
%  psy_decode_bin_stream
%  psy_transform_iscan_data
%
% Zhivago KA
% 07 Dec 2010

function fail_flag = psy_await_saccade(xy_dva, timeout)

global expt_str;
global eye_data_stream;

task  = expt_str.task;
iscan = expt_str.specs.iscan;

% Setting the default fixation window to 3 degrees of visual angle
if ~exist('timeout'), timeout = Inf; end

% initializing all the required variables
fix_flag = false;
fail_flag = 1;
saccade_dva_data = [];

% Computing the minimum nymber of bytes to read from the serial port
min_saccade_samples = 3;
min_data = ((min_saccade_samples + 2) * iscan.sample_size);

% Tracking the subject for a saccade
t = GetSecs();
while (GetSecs() - t) < timeout
    bytes = 0;
    pktdata = [];
    % Reading at least minimum number of bytes
    while bytes < min_data
        read_data = IOPort('Read', iscan.port);
        pktdata = [pktdata read_data];
        bytes = size(pktdata,2);
        WaitSecs(.004);
    end
    
    % Storing a copy of the read data in the global buffer/stream
    eye_data_stream = [eye_data_stream pktdata];
    
    % Transforming ISCAN signal to x & y dva's
    iscan_fix_data = psy_decode_bin_stream(pktdata);
    iscan_fix_data = iscan_fix_data(:,1:2);
    iscan_fix_data = iscan_fix_data(end-min_saccade_samples:end-1,:);
    dva_data = psy_transform_iscan_data(iscan_fix_data);
    saccade_dva_data = [saccade_dva_data; dva_data];
    
    % Checking for fixation
    if( ~fix_flag &&...
        any(abs(xy_dva(1) - dva_data(:,1))) <= task.fix_window &&...
        any(abs(xy_dva(2) - dva_data(:,2))) <= task.fix_window )
        fix_flag = true;
    end
    
    % checking for a saccade in any direction
    if(fix_flag &&...
       (abs(xy_dva(1) - dva_data(end,1)) > task.fix_window ||...
        abs(xy_dva(2) - dva_data(end,2)) > task.fix_window))
        fail_flag = 0; 
        break;
    end
end
    
return;
