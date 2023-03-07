% -------------------------------------------------------------------
% This function tranforms the ISCAN data into dva's using the
% transformation coefficient matrix computed during calibration.
% -------------------------------------------------------------------
% [xy_dva] = psy_transform_iscan_data(iscan_xy_data)
% REQUIRED INPUTS
%  iscan_xy_data = ISCAN data
% OPTIONAL INPUTS
%  None
% OUTPUTS
%  xy_dva     = (x,y) dvas
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  psy_transform_iscan_data(iscan_sig);
%  will tranform ISCAN signal values to (x,) dvas
% REQUIRED SUBROUTINES
%  None
%
% Zhivago KA
% 07 Dec 2010

function [xy_dva] = psy_transform_iscan_data(iscan_xy_data)

global expt_str;

cal     = expt_str.specs.calibration;
num_pts = size(iscan_xy_data,1);
xy_data = [iscan_xy_data ones(num_pts,1)];

% Applying the transformation coefficients to ISCAN signal
% in order to compute the dvas
xy_dva = [(xy_data * cal.x_transform) (xy_data * cal.y_transform)];

return;