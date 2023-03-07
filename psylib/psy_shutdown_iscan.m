% -------------------------------------------------------------------
% This function shuts down ISCAN and serial port
% -------------------------------------------------------------------
% psy_shutdown_iscan()
% REQUIRED INPUTS
%  None
% OPTIONAL INPUTS
%  None
% OUTPUTS
%  None
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  psy_shutdown_iscan();
%  will shutdown ISCAN and serial port
% REQUIRED SUBROUTINES
%  None
%
% Zhivago KA
% 07 Dec 2010

function psy_shutdown_iscan()
global expt_str;
iscan = expt_str.specs.iscan;
% Turning off Track Active
%IOPort('Write', iscan.port, iscan.track_off_code); WaitSecs(1e-10);
% Closing all the open serial ports
IOPort('CloseAll');
return;