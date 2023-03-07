% -------------------------------------------------------------------
% This function purges the read & write buffers of the serial port.
% -------------------------------------------------------------------
% psy_purge_iscan()
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
%  psy_purge_iscan();
%  will purge the serial port read/write buffers
% REQUIRED SUBROUTINES
%  None
%
% Zhivago KA
% 07 Dec 2010

function psy_purge_iscan()
global expt_str;
% Purging the read & write buffers of the serial port
IOPort('Purge', expt_str.specs.iscan.port);
return;