% unityslope        --> Draws a line of unit slope in the current axes

function h = unityslope(linewidth,linespec)
if(~exist('linewidth')) linewidth = 1; end; 
if(~exist('linespec')) linespec = 'k'; end; 

v = axis; hold on; 
lb = min(v); ub = max(v); x = [lb ub];
h = plot(x,x,linespec,'LineWidth',linewidth);
axis square; 

return