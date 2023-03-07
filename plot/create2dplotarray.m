% createplotarray -> creates a 2D array of plots
%
% axhandles = createplotarray(nrows, ncols, props, offsets, margins, spc)
%
% Required Inputs
%    nrows     - # of rows
%    ncols     - # of columns
%    props     - 2-element vector specifying the proportion of the figure window
%                to be used in the x & y direction
%    offsets   - 2-element vector specifying the offsets in the x & y direction
%    margins   - 2-element vector specifying the margins in the x & y direction
%    spc       - 2-element vector specifying the spacing between the plots
%                specified as the percentage of the individual plot size
%
% Outputs
%    axhandles - 2D array of handles accessible using a row id and column id
%
% Method
%    uses the axes function to flexibly lay out the axes with specified parameters
%
% Zhivago Kalathupiriyan
%
% Change Log:
%    14/07/2014 - ZAK - first version

function axhandles = createplotarray(nrows, ncols, props, offsets, margins, spc)
xprop = props(1); yprop = props(2);
xoff = offsets(1); yoff = offsets(2);
mleft = margins(1); mright = margins(2); mtop = margins(3); mbottom = margins(4);

xscr = xprop - (mleft + mright) ; yscr = yprop - (mtop + mbottom);
netw = xscr/ncols; neth = yscr/nrows;
xspc = netw * spc(1); yspc = neth * spc(2);
axw = netw - xspc; axh = neth - yspc;

xend = xoff + xprop - netw; yend = 1 - yoff - mtop - neth;
axl = xoff+mleft:netw:xend-mright+.00001; axb = yend:-neth:yend-yprop-mbottom;

axhandles = zeros(nrows,ncols);
for i = 1:nrows
    for j = 1:ncols
        pos = [axl(j) axb(i) axw axh];
        
        axhandles(i,j) = axes('Position', pos, 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 11, 'XTick', [], 'YTick', []);
    end
end