% ----------------------------------------------------------------------
% psy_fix_cross function displays a fixation cross on the screen
% ----------------------------------------------------------------------
% t_fix_on = psy_fix_cross(wptr,color,size_pix,thickness)
% 
% INPUTS
%  wptr           = window pointer
%  color          = RGB array or a scalar value between 0 and 255 to specify the color. Default = 255.
%  size_pix       = Length of the fixation cross in pixels. Default = 20.
%  thickness      = Thickness of the lines forming the fixation cross. Default = 3.
%  
% OUTPUTS
%  t_fix_on       = time in seconds at which the fixation cross was displayed on the screen.
% 
% Pramod R T
% September 2013

function t_fix_on = psy_fix_cross(wptr,color,size_pix,thickness)

scrnum = Screen('WindowScreenNumber',wptr);
scr = Screen('Resolution',scrnum); screenW = scr.width; screenH = scr.height;

if (~exist('color') || isempty(color)), color = 255;end
if (isscalar(color)), color = [color color color];end
if (~exist('size_pix') || isempty(size_pix)), size_pix = 20;end
if (~exist('thickness') || isempty(thickness)), thickness = 3;end

Screen('DrawLine', wptr, color, (screenW/2 - size_pix/2), (screenH/2), (screenW/2 + size_pix/2), (screenH/2), thickness);
Screen('DrawLine', wptr, color, (screenW/2), (screenH/2 - size_pix/2), (screenW/2), (screenH/2 + size_pix/2), thickness);

[~,t_fix_on] = Screen('Flip',wptr);
end