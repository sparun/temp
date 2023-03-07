% ----------------------------------------------------------------------
% psy_wait function waits for the specified time and optionally checks for keypresses 
% ----------------------------------------------------------------------
% [response_flag, key_time] = psy_wait(wptr, twait, keys, pqflag)
% 
% INPUTS
%  wptr           = window pointer
%  twait          = time to wait in seconds
% OPTIONAL INPUTS
%  keys           = cell array of keynames to check
%  pqflag         = flag to add pause (p) and quit (q) keys
%  
% OPTIONAL OUTPUTS
%  response_flag = 0 for no response (keytime is NaN) 
%                = 1,2,3 etc according to keys array 
%                = -1 if "p" was pressed (pause)
%                = -2 if "q" was pressed (quit)
%  key_time      = time taken for keypress
% 
% NOTE
%    psy_wait should be used in conjunction with any visual on/off event that follows it, because
%    it returns back a little before the flipinterval in order to ensure that the visual event 
%    happens at the designated time. 
% 
% Credits: Georgin/Pramod/Zhivago
% Change log
%     - 12/05/2017 (GPZ) - First version

function [response_flag, key_time] = psy_wait(wptr, twait, keys, pqflag)
response_flag = []; key_time = [];
if ~exist('pqflag'), pqflag = 1; end
[monitorFlipInterval, nrValidSamples, stddev] = Screen('GetFlipInterval', wptr);
twait = twait - monitorFlipInterval/4;
iswarning = 0; 
if exist('keys')
    [response_flag, key_time] = psy_await_keypress(keys, twait, pqflag,iswarning);
else
    WaitSecs(twait);
end

end