function [axl axb axw axh] = computepos(nrows, ncols, props, offsets, margins, spc)

xprop = props(1); yprop = props(2);
xoff = offsets(1); yoff = offsets(2);
mleft = margins(1); mright = margins(2); mtop = margins(3); mbottom = margins(4);

xscr = xprop - (mleft + mright) ; yscr = yprop - (mtop + mbottom);
netw = xscr/ncols; neth = yscr/nrows;
xspc = netw * spc(1); yspc = neth * spc(2);
axw = netw - xspc; axh = neth - yspc;

xend = xoff + xprop - netw; yend = 1 - yoff - mtop - neth;
axl = xoff+mleft:netw:xend-mright+.00001; axb = yend:-neth:yend-yprop-mbottom;
end