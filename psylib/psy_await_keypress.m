% -------------------------------------------------------------------
% This function waits for a maximum of timer_duration seconds to check
% if the subject has pressed a key from the specified set of keys
% -------------------------------------------------------------------
% [response_flag, key_time] = psy_await_keypress(keys,timer_duration)
% REQUIRED INPUTS
%  keys           = keycodes to check or cell array containing keys to check
% OPTIONAL INPUTS
%  timer_duration = time for which to check for keypress
% OUTPUTS
%  response_flag = 0 for no response (keytime is NaN) 
%                = 1,2,3 etc according to keys array 
%                = -1 if "p" was pressed (pause)
%                = -2 if "q" was pressed (quit)
%  key_time      = time taken for keypress
%
% EXAMPLE
%  await_keypress([KbName('up') KbName('down')],5) OR await_keypress({'up','down'},5); 
%  will wait for a maximum of 5 seconds for the subject to
%  press the up/down arrow key
% 
% NOTE
%    Do NOT use psy_await_keypress in conjunction with a visual on/off event. 
%    Use psy_wait instead. For details see psy_wait help
%
% SP Arun
%    07/12/2010 First version
%    25/09/2013 Updated to include cell array of strings
%    17/05/2017 Added psy_wait to be used with any visual event
%    22/09/2017 Added while loop to wait for release of all keys after the first keypress (AA/ZAK)

function [response_flag, key_time] = psy_await_keypress(keys,timer_duration,pqflag,iswarning)
if(~exist('timer_duration')), timer_duration = Inf; end; % if no timer duration provided, then keep waiting
if(~exist('pqflag')), pqflag = 1; end; 
if(~exist('iswarning')),iswarning = 1; end; 
if(iswarning), fprintf('*****WARNING: Do NOT use psy_await_keypress with a image on/off event! Use psy_wait instead \n'); end; 

if(iscell(keys))
    keyall=[]; 
    for i = 1:length(keys)
        keyall = [keyall KbName(keys{i})]; 
    end
    keys = keyall; 
end
if(pqflag) keys = [keys KbName('p') KbName('q')]; end; 
RestrictKeysForKbCheck(keys);

% keep checking for key press
response_flag = 0; key_time = NaN; init_time = GetSecs;
while (GetSecs - init_time) <= timer_duration
    [response_flag,kt,key_code] = KbCheck;
    % get rid of multiple keypresses
    if response_flag
        while response_flag && (GetSecs - init_time) <= timer_duration
            response_flag = KbCheck();
        end
        response_flag = 1; break;
    end
    WaitSecs(0.00025); % wait 0.25 ms to avoid overload
end

if(response_flag)
    key_time = kt; % key press time in seconds
    response = find(key_code); 
    response = response(1); % in case two keys are pressed, select the first one
    response_flag = find(keys==response); % 1 if first key was pressed, 2 if second key was pressed, etc.
    
    if(response_flag == length(keys)-1) % i.e. if p was pressed
        response_flag = -1;
        key_time = NaN;
     end
    if(response_flag == length(keys)) % i.e., if q was pressed
        response_flag = -2;
        key_time = NaN;
    end
end