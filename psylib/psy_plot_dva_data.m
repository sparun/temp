% -------------------------------------------------------------------
% This function plots a given set of (x,y) dva data as dots whose
% color and size can be specified.
% Also, frame buffer flipping can be specified.
% -------------------------------------------------------------------
% psy_plot_dva_data(xy_dva, dot_color, dot_size, overlay_flag, flip_flag)
% REQUIRED INPUTS
%  xy_dva      = (x,y) dva where the dot has to be centered
% OPTIONAL INPUTS
%  dot_color    = color
%                 Default color = WHITE [255 255 255]
%  dor_size     = size of the dot
%                 default = 1
%  overlay_flag = 1, if this dot should be overlaid with the next drawn image
%                 0, otherwise
%                 default = 1
% flip_flag     = 1, to flip the frame buffer
%                 0, not to flip the frame buffer
% OUTPUTS
%  None
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  psy_plot_dva_data(xy_dva);
%  will all the (x,y) dva points contained in xy_dva
% REQUIRED SUBROUTINES
%  dva_to_pix
%
% Zhivago KA
% 07 Dec 2010

function psy_plot_dva_data(xy_dva, dot_color, dot_size, overlay_flag, flip_flag)

global expt_str;

screen_str = expt_str.specs.screen;

% setting default values
if ~exist('dot_color'), dot_color = [255 255 255]; end
if ~exist('dot_size'), dot_size = 1; end
if ~exist('overlay_flag'), overlay_flag = 1; end
if ~exist('flip_flag'), flip_flag = 1; end

% extracting screen information
wptr     = screen_str.wptr;

% Computing the number of points to plot
num_pts = size(xy_dva,1);

% Converting dva's to coordinates wrt to the center of the display
xy_coor = psy_dva2pix(xy_dva);
    
for rep = 1:num_pts
    % Figuring out the real pixels on the real screen
    x_coor = xy_coor(rep,1);
    y_coor = xy_coor(rep,2);
    Screen('glPoint', wptr, dot_color, x_coor, y_coor, dot_size);
end

% Plotting the points
if flip_flag == 1
    % Xferring frame buffer to the screen
    Screen('Flip', wptr, 0, overlay_flag, 2);
end

return;
