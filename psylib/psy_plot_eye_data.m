% -------------------------------------------------------------------
% This function decodes a given ISCAN data stream and plots it.
% -------------------------------------------------------------------
% psy_plot_eye_data(data_stream, dot_color, overlay_flag)
% REQUIRED INPUTS
%  data_stream = ISCAN data stream
% OPTIONAL INPUTS
%  dot_color    = color
%                 Default color = WHITE [255 255 255]
%  overlay_flag = 1, if this dot should be overlaid with the next drawn image
%                 0, otherwise
%                 default = 1
% OUTPUTS
%  None
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  psy_plot_eye_data(data_stream);
%  will decode and plot the data in data_stream
% REQUIRED SUBROUTINES
%  psy_decode_bin_stream
%  psy_transform_iscan_data
%  psy_plot_dva_data
%
% Zhivago KA
% 07 Dec 2010

function psy_plot_eye_data(data_stream, dot_color, overlay_flag)
% setting default values
if ~exist('dot_color'), dot_color = [255 255 255]; end
if ~exist('overlay_flag'), overlay_flag = 1; end

% decoding, tranforming, and plotting the data
iscan_fix_data = psy_decode_bin_stream(data_stream);
iscan_fix_data = iscan_fix_data(:,1:2);
fix_dva_data = psy_transform_iscan_data(iscan_fix_data);
psy_plot_dva_data(fix_dva_data, dot_color, 1, overlay_flag);
end