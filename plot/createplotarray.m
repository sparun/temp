% creates a 2D array of plots with each plot having a maximum of 3 subplots (image/psth/raster)
% nplots          - # of subplots
% nrows           - # of rows
% ncols           - # of columns
% props           - 2-element vector specifying the proportion of the figure window
%                   to be used in the x & y direction
% offsets         - 2-element vector specifying the offsets in the x & y direction
% margins         - 2-element vector specifying the margins in the x & y direction
% spc             - 2-element vector specifying the spacing between the plots
%                   specified as the percentage of the individual plot size
% axis_label_flag - 1:turns on axis labels; turned off by default

function axhandles = createplotarray(nplots, nrows, ncols, props, offsets, margins, spc, axis_label_flag)
stackflag = 0;
if length(nplots) == 2
    nplots = 2;
    stackflag = 1;
end

if length(nplots) == 3
    nplots = 3;
    stackflag = 1;
end

[axl axb axw axh] = computepos(nrows, ncols, props, offsets, margins, spc);
axhandles = zeros(nrows,ncols,nplots);
for i = 1:nrows
    for j = 1:ncols
        pos = [axl(j) axb(i) axw axh];
        switch nplots
            case 1
                axhandles(i,j,1) = axes('Position', pos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5, 'XTickLabel', '', 'YTickLabel', '');
            case 2
                if stackflag == 0
                    w = pos(3)/2;
                    axpos = [pos(1) pos(2) w pos(4)];
                    axhandles(i,j,1) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5, 'XTickLabel', '', 'YTickLabel', '');
                    axpos = [pos(1)+w pos(2) w pos(4)];
                    if axis_label_flag
                        axhandles(i,j,2) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5);
                    else
                        axhandles(i,j,2) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5, 'XTickLabel', '', 'YTickLabel', '');
                    end
                else
                    h = pos(4)/2;
                    axpos = [pos(1) pos(2)+h pos(3) h];
                    axhandles(i,j,1) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5, 'XTickLabel', '', 'YTickLabel', '');
                    axpos = [pos(1) pos(2) pos(3) h];
                    if axis_label_flag
                        axhandles(i,j,2) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5);
                    else
                        axhandles(i,j,2) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5, 'XTickLabel', '', 'YTickLabel', '');
                    end
                end
            case 3
                if stackflag == 0
                    w = pos(3)/2; h = pos(4)/2;
                    axpos = [pos(1) pos(2) w pos(4)];
                    axhandles(i,j,1) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5, 'XTickLabel', '', 'YTickLabel', '');
                    axpos = [pos(1)+w pos(2)+h w h];
                    axhandles(i,j,2) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5, 'XTickLabel', '', 'YTickLabel', '');
                    axpos = [pos(1)+w pos(2) w h];
                    if axis_label_flag
                        axhandles(i,j,3) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5);
                    else
                        axhandles(i,j,3) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5, 'XTickLabel', '', 'YTickLabel', '');
                    end
                else
                    w = pos(3); h = pos(4)/3;
                    axpos = [pos(1) pos(2)+2*h w h];
                    axhandles(i,j,1) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5, 'XTickLabel', '', 'YTickLabel', '');
                    axpos = [pos(1) pos(2)+h w h];
                    axhandles(i,j,2) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5, 'XTickLabel', '', 'YTickLabel', '');
                    axpos = [pos(1) pos(2) w h];
                    if axis_label_flag
                        axhandles(i,j,3) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5);
                    else
                        axhandles(i,j,3) = axes('Position', axpos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5, 'XTickLabel', '', 'YTickLabel', '');
                    end
                end
        end
    end
end