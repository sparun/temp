% -------------------------------------------------------------------
% This function is used for drawing a cross
% -------------------------------------------------------------------
% t_flip_end = psy_draw_cross(xy_dva, cross_color, size_dva, width, overlay_flag)
% REQUIRED INPUTS
%  xy_dva      = (x,y) dva where the cross has to be centered
% OPTIONAL INPUTS
%  cross_color  = color
%                 Default color = WHITE [255 255 255]
%  size_dva     = size of the cross in dva
%                 this value is used as dva along x & y directions
%                 default = 1
%  width        = width of the lines in the cross
%                 default = 2
%  overlay_flag = 1, if this cross should be overlaid with the next drawn image
%                 0, otherwise
%                 default = 1
% OUTPUTS
%  t_flip_end = the time at which the cross was displayed on the screen
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  psy_draw_cross([-10 10], [0 255 0]);
%  will draw a GREEN cross at [-10 10] with a size of [1,1] dva
% REQUIRED SUBROUTINES
%  psy_dva2pix
%
% Zhivago KA
% 07 Dec 2010

function t_flip_end = psy_draw_cross(xy_dva, cross_color, size_dva, width, overlay_flag)

global expt_str;

screen_str = expt_str.specs.screen;

% setting default values
if ~exist('cross_color') | isempty(cross_color), cross_color = [255 255 255]; end
if ~exist('size_dva') | isempty(size_dva ), size_dva = 1; end
if ~exist('width') | isempty(width), width = 2; end
if ~exist('overlay_flag'), overlay_flag = 1; end

% extracting screen information
wptr = screen_str.wptr;

% converting dvas to pixels
xy_coor = psy_dva2pix(xy_dva);
x_coor = xy_coor(1);
y_coor = xy_coor(2);
half_w = size_dva * screen_str.x_pix_per_dva/2;
half_h = size_dva * screen_str.y_pix_per_dva/2;

% drawing the cross
Screen('DrawLine', wptr, cross_color, (x_coor - half_w), y_coor, (x_coor + half_w), y_coor, width);
Screen('DrawLine', wptr, cross_color, x_coor, (y_coor - half_h), x_coor, (y_coor + half_h), width);
[~, ~, t_flip_end] = Screen('Flip', wptr, 0, overlay_flag, 2);

return;