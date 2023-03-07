% -------------------------------------------------------------------
% This function changes the specified portion of a given screen to
% the specified color
% -------------------------------------------------------------------
% function psy_change_screen_color(scr_color, rect)
% REQUIRED INPUTS
%  None
% OPTIONAL INPUTS
%  scr_color = color
%              Default color = BLACK [0 0 0]
%  rect      = portion [xlt, ylt, xrb, yrb] of the screen
%              xlt and ylt denote the left-top (x,y) coordinates
%              xrb and yrb denote the right-bottom (x,y) coordinates
%              Default value = whole screen []
% OUTPUTS
%  None
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  psy_change_screen_color([0 255 0]);
%  will change the subject's screen to GREEN.
% REQUIRED SUBROUTINES
%  None
%
% Zhivago KA
% 07 Dec 2010

function psy_change_screen_color(scr_color, rect)
global expt_str;

screen_str = expt_str.specs.screen;
% setting default values
if ~exist('scr_color'), scr_color = [0 0 0]; end
if ~exist('rect'), rect = []; end

% extracting screen information
wptr = screen_str.wptr;

% changing screen color
Screen('FillRect', wptr, scr_color, rect);
Screen('Flip', wptr, 0, 1, 2);

return;