% -------------------------------------------------------------------
% This function converts a given (x,y) coordinate wrt to the top-left of the
% display to x & y dva (degrees of visual angle)
% -------------------------------------------------------------------
% [xy_dva] = psy_pix2dva(xy_pix)
% REQUIRED INPUTS
%  xy_pix = (x,y) in pixels with respect to the center of the screen
% OPTIONAL INPUTS
%  None
% OUTPUTS
%  xy_dva     = list of (x,y) dvas
% METHOD
%
% NOTES
%
% EXAMPLE
%  psy_pix2dva(xy_pix);
%  will transform pixel values in xy_pix to dvas
% REQUIRED SUBROUTINES
%  None
%
% Zhivago KA
% 07 Dec 2010

function [xy_dva] = psy_pix2dva(xy_pix)

global expt_str;

screen_str = expt_str.specs.screen;

% Computing the number of data points
num_pts = size(xy_pix,1);

% Pre-allocating for the output variable
xy_dva = zeros(num_pts, 2);

X_mm_per_pix = screen_str.X_mm_per_pix;
Y_mm_per_pix = screen_str.Y_mm_per_pix;

ox = screen_str.origin(1);
oy = screen_str.origin(2);

for i = 1:num_pts
    % Computing the distance of x & y coordinates separately from the center
    % of the display
    x_from_center_mm = (-ox + xy_pix(i,1)) * X_mm_per_pix;
    y_from_center_mm = (+oy - xy_pix(i,2)) * Y_mm_per_pix;
    
    % Computing the x & y dva
    xy_dva(i,1) = atand(x_from_center_mm/screen_str.eye_dist_mm);
    xy_dva(i,2) = atand(y_from_center_mm/screen_str.eye_dist_mm);
end

return;

