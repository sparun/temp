% get_xydata_positions -> convert x-y values in an axis into normalized figure coordinates
%% fig_XY_dist = get_xydata_positions(XYdata,axis_handle); 
%% Required inputs
%%    XYdata        = (x,y) values from a given axis
%% Optional inputs:
%%    axis_handle   = axis handle which contains the x,y values
%% Outputs:
%%    fig_XY_dist   = (x,y) values converted into absolute (normalized) figure positions in matlab

% Arun Sripati
% March 6 2005

function fig_XY_dist = get_xydata_positions(XYdata,axis_handle)
if(~exist('axis_handle')) axis_handle = gca; end; 
if(isvector(XYdata)) XYdata = XYdata(:); end; 

v = axis(axis_handle); pos = get(axis_handle,'Position'); 
norm_x_dist = (XYdata(:,1)-v(1))/(v(2)-v(1)); % normalized x-units in the current axes
fig_x_dist = norm_x_dist*pos(3) + pos(1);
fig_y_dist = []; 
if(~isvector(XYdata))
    norm_y_dist = (XYdata(:,2)-v(3))/(v(4)-v(3)); % normalized y-units in the current axes
    fig_y_dist = norm_y_dist*pos(4) + pos(2);
end

fig_XY_dist = [fig_x_dist fig_y_dist]; 
return