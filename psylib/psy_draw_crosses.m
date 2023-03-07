% -------------------------------------------------------------------
% This function is used for drawing multiple crosses
% -------------------------------------------------------------------
% psy_draw_crosses(xy_dva, cross_color, size_dva, width, overlay_flag)
% REQUIRED INPUTS
%  xy_dva      = (x,y) dva where the crosses have to be centered
% OPTIONAL INPUTS
%  cross_color  = color
%                 Default color = WHITE [255 255 255]
%  size_dva     = size of the cross in dva
%                 this value is used as dva along x & y directions
%                 default = 1
%  width        = width of the lines in the cross
%                 default = 1
%  overlay_flag = 1, if this cross should be overlaid with the next drawn image
%                 0, otherwise
%                 default = 1
% OUTPUTS
%  t_flip_end = the time at which the crosses were displayed on the screen
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  psy_draw_crosses(1, [-10 10; 23 6; 17 -10], [0 255 0]);
%  will draw GREEN crosses at the specified points with a size of [1,1] dva
% REQUIRED SUBROUTINES
%  psy_dva2pix
%
% Zhivago KA
% 07 Dec 2010

function t_flip_end = psy_draw_crosses(xy_dva, cross_color, size_dva, width, overlay_flag)

global expt_str;

screen_str = expt_str.specs.screen;

% setting default values
if ~exist('size_dva'), size_dva = 1; end
if ~exist('cross_color'), cross_color = [255 255 255]; end
if ~exist('width'), width = 1; end
if ~exist('overlay_flag'), overlay_flag = 1; end

% converting dvas to pixels
wptr = screen_str.wptr;
half_w = size_dva * screen_str.x_pix_per_dva/2;
half_h = size_dva * screen_str.y_pix_per_dva/2;
    
% Computing the number of points to plot
[num_pts, ~] = size(xy_dva);

% Converting dva's to coordinates wrt to the center of the display
xy_coor = psy_dva2pix(xy_dva);
for rep = 1:num_pts
    % Computing the (x,y) coordinates wrt to the center of the screen
    xy(1, (rep-1)*4+1) = xy_coor(rep,1) - half_w;
    xy(2, (rep-1)*4+1) = xy_coor(rep,2);
    xy(1, (rep-1)*4+2) = xy_coor(rep,1) + half_w;
    xy(2, (rep-1)*4+2) = xy_coor(rep,2);
    xy(1, (rep-1)*4+3) = xy_coor(rep,1);
    xy(2, (rep-1)*4+3) = xy_coor(rep,2) - half_h;
    xy(1, (rep-1)*4+4) = xy_coor(rep,1);
    xy(2, (rep-1)*4+4) = xy_coor(rep,2) + half_h;
end

% drawing the crosses
Screen('DrawLines', wptr, xy, width, cross_color);
[~, ~, t_flip_end] = Screen('Flip', wptr, 0, overlay_flag, 2);

return;