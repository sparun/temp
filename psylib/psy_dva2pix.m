% -------------------------------------------------------------------
% This function converts the x & y dva (degrees of visual angle) to
% x & y coordinates with respect to the top-left of the display
% -------------------------------------------------------------------
% [xy_pix] = psy_dva2pix(xy_dva)
% REQUIRED INPUTS
%  xy_dva     = list of (x,y) dvas
% OPTIONAL INPUTS
%  None
% OUTPUTS
%  xy_pix = (x,y) in pixels with respect to the center of the screen
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  psy_dva2pix(1, xy_dvas);
%  will transform dva values to pixels wrt the center of the subject's screen
% REQUIRED SUBROUTINES
%  None
%
% Zhivago KA
% 07 Dec 2010

function xy_pix = psy_dva2pix(xy_dva)
global expt_str;

screen_str = expt_str.specs.screen;

% Computing the number of data points
num_pts = size(xy_dva,1);
% Pre-allocating for the output variable
xy_pix = zeros(num_pts,2);

X_mm_per_pix = screen_str.X_mm_per_pix;
Y_mm_per_pix = screen_str.Y_mm_per_pix;

ox = screen_str.origin(1);
oy = screen_str.origin(2);
    
for i = 1:num_pts
    % Computing the distance along the width
    x_dist_mm = tand(xy_dva(i,1)) * screen_str.eye_dist_mm;
    % Computing x in pixels wrt center of the display
    x_pix = x_dist_mm/X_mm_per_pix;
    % Computing the distance along the height
    y_dist_mm = tand(xy_dva(i,2)) * screen_str.eye_dist_mm;
    % Computing y in pixels wrt center of the display
    y_pix = y_dist_mm/Y_mm_per_pix;
    % Storing the (x,y) pixel values in the output variable
    xy_pix(i,:) = [(ox + x_pix) (oy - y_pix)];
end
return