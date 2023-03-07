% -------------------------------------------------------------------
% This function is used for drawing a dot with flash options
% -------------------------------------------------------------------
% t_flip_end = psy_draw_dot(xy_dva, dot_color, size_dva, overlay_flag, flash_flag, flash_time)
% REQUIRED INPUTS
%  xy_dva      = (x,y) dva where the dot has to be centered
% OPTIONAL INPUTS
%  dot_color    = color
%                 Default color = WHITE [255 255 255]
%  size_dva     = size of the dot in dva
%                 this value is used as dva along x & y directions
%                 default = 1
%  overlay_flag = 1, if this dot should be overlaid with the next drawn image
%                 0, otherwise
%                 default = 1
%  flash_flag   = 1, if the dot has to be flashed
%                 0, otherwise
%  flash_time   = time in seconds for which the dot has to be flashed
% OUTPUTS
%  t_flip_end = the time at which the dot was displayed on the screen
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  psy_draw_dot(1, [-10 10], [0 255 0]);
%  will draw a GREEN dot at [-10 10] with a size of [1,1] dva
% REQUIRED SUBROUTINES
%  psy_dva2pix
%
% Zhivago KA
% 07 Dec 2010

function t_flip_end = psy_draw_dot(xy_dva, dot_color, size_dva, overlay_flag, flash_flag, flash_time)

global expt_str;

screen_str = expt_str.specs.screen;

% setting default values
if ~exist('dot_color'), dot_color = [255 255 255]; end
if ~exist('size_dva'), size_dva = 1; end
if ~exist('overlay_flag'), overlay_flag = 1; end
if ~exist('flash_flag'), flash_flag = 0; end
if ~exist('flash_time'), flash_time = 0; end

% extracting screen information
wptr = screen_str.wptr;


% converting dvas to pixels
xy_coor = psy_dva2pix(xy_dva);
x_coor = xy_coor(1);
y_coor = xy_coor(2);
half_w = size_dva * screen_str.x_pix_per_dva;
half_h = size_dva * screen_str.y_pix_per_dva;
orect = [(x_coor-half_w) (y_coor-half_h) (x_coor+half_w) (y_coor+half_h)];

% drawing the dot
Screen('FillOval', wptr, dot_color, orect);
[~, ~, t_flip_end] = Screen('Flip', wptr, 0, overlay_flag, 2);

% flashing the dot
if flash_flag
    WaitSecs(flash_time);
    Screen('FillRect', wptr, [0 0 0], orect);
    Screen('Flip', wptr, 0, overlay_flag, 2);
end

return;