% -------------------------------------------------------------------
% This function waits for a maximum of timeout seconds to check if the
% subject has fixated at the specified position
% -------------------------------------------------------------------
% fail_flag = psy_await_fix(xy_dva, timeout)
% REQUIRED INPUTS
%  xy_dva  = (x,y) coordinates of the point fixation is to be checked
% OPTIONAL INPUTS
%  timeout = time for which to check for fixation
% OUTPUTS
%  fail_flag      = true or 1 if fixation was detected
%                   false or 0, otherwise
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  psy_await_fix([-15 -10], 5);
%  will wait for a maximum of 5 seconds for the subject to
%  fixate at [-15 0]
% REQUIRED SUBROUTINES
%  psy_decode_bin_stream
%  psy_transform_iscan_data
%
% Zhivago KA
% 07 Dec 2010

function [fail_flag, fix_dva_data] = psy_await_fix(xy_dva, timeout)

global expt_str;
global eye_data_stream;

task  = expt_str.task;
iscan = expt_str.specs.iscan;

% setting default values
if ~exist('timeout'), timeout = Inf; end

% initializing variables
fail_flag = 1;
fix_dva_data = [];
iscan_fix_data = [];

n_samples = task.check_fix_samples;

% computing the minimum number of bytes to read from the serial port
min_data = ((n_samples + 2) * iscan.sample_size);

% checking for fixation till the specified time elapses
t = GetSecs();
while (GetSecs() - t) < timeout
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
    
    % Verifying if the eye position is around the fixation point
    if( all(abs(xy_dva(1) - fix_dva_data(:,1)) <= task.fix_window) &&...
        all(abs(xy_dva(2) - fix_dva_data(:,2)) <= task.fix_window) )
        fail_flag = 0;
        break;
    end
end

return;