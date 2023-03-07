% -------------------------------------------------------------------
% This function shuts down the display
% -------------------------------------------------------------------
% psy_shutdown_display()
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
%  psy_shutdown_display();
%  will shutdown the display
% REQUIRED SUBROUTINES
%  None
%
% Zhivago KA
% 07 Dec 2010

function psy_shutdown_display()
% closing all the open windows on the screen
Screen('CloseAll');
% Putting the cursor back on the screen
ShowCursor();
return;