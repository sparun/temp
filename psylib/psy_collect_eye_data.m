% -------------------------------------------------------------------
% This function collects eye data
% -------------------------------------------------------------------
% psy_collect_eye_data
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
%  psy_collect_eye_data
%  will collect eye data into the global buffer
% REQUIRED SUBROUTINES
%  None
%
% Zhivago KA
% 07 Dec 2010

function psy_collect_eye_data()

global expt_str eye_data_stream;

read_data = IOPort('Read', expt_str.specs.iscan.port);
eye_data_stream = [eye_data_stream read_data];

return;