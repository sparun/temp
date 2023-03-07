% ------------------------------------------------------------------------------------------------
% psy_announce_block function displays the message string on screen and waits for 'space' keypress
% ------------------------------------------------------------------------------------------------
% psy_announce_block(str,wptr,textsize,textcolor)
% 
% INPUTS
%  str            = Text string to be displayed
%  wptr           = window pointer
%  textsize       = Size of the text to be displayed (OPTIONAL)
%  textcolor      = color of the text to be displayed (OPTIONAL)

% Change Log:
% 01/09/2013 (Pramod)          - First version
% 10/11/2017 (Georgin/Zhivago) - Display multiple lines

function psy_announce_block(str,wptr,textsize,textcolor)

black = BlackIndex(wptr);
if (~exist('textsize') || isempty(textsize)), textsize = 30;end
if (~exist('textcolor') || isempty(textcolor)), textcolor = [255 255 255];end % White by default

Screen('TextSize', wptr, textsize);
Screen('FillRect',wptr, black);
str = sprintf('%s\n\n\n\n\n Press spacebar to continue ...', str);
DrawFormattedText(wptr, str, 'center', 'center', textcolor);
Screen('Flip', wptr);
psy_wait(wptr,Inf,KbName('space'),0); % wait for space bar
return
