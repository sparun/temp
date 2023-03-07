% ------------------------------------------------------------------------------
% psy_record_keys function records all keys pressed in the specified time period
% ------------------------------------------------------------------------------
% [response_key, key_time] = psy_record_keys(timer_duration)
% 
% REQUIRED INPUTS
%  timer_duration = time in seconds for which to record keypresses
%
% OUTPUTS
%  response_key = cell array of key names
%  key_time     = time taken for each response_key
%
% EXAMPLE
%  [response_key, key_time] = psy_record_keys(5)
%  will record all the keys pressed in 5 seconds after the function is called
% 
% Change log
%     04/01/2018 - Aakash/Pramod/Zhivago - First version

function [response_key, key_time] = psy_record_keys(timer_duration)
response_key = []; key_time = []; init_time = GetSecs;
while (GetSecs - init_time) <= timer_duration
    [ispressed, kt, key_code] = KbCheck;
    if ispressed
        % get rid of multiple keypresses
        while ispressed & (GetSecs - init_time) <= timer_duration
            ispressed = KbCheck();
        end
        q = find(key_code);
        response_key = [response_key; q'];
        key_time = [key_time; kt];
        FlushEvents('keyDown');
        WaitSecs(0.00025); % wait 0.25 ms to avoid overload
    end
end
end