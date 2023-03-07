% spike_view       --> Display a set of spike trains as a raster plot.
% spike_view(sptimes,ystart,barsize,c);
% Required inputs
%    sptimes       = vector or cell array of spike times
% Optional inputs:
%    ystart        = specifies where to start plotting the rasters on the y-axis (default = 0)
%    barsize       = size of each tick
%    c             = color string OR color vector
% Outputs:
%    Plots the spike train as a raster in the current axes. 


% Arun Sripati, 2/27/03

function [y1 ho] = spkview(h,sptimes,ystart,barsize,c,linewidth)
if(~exist('ystart')|isempty(ystart)) ystart = 0; end;
if(~exist('c','var')) c = 'b'; end;
if(~exist('barsize')) barsize = 1; end;
if(~exist('linewidth')) linewidth = 1; end; 

y1 = ystart;
hold(h,'on'); ho = []; 
if(iscell(sptimes))
    for i = 1:length(sptimes)
        y1 = ystart-(i-1)*barsize;
        if(~isempty(sptimes{i}))
            rplot(h,sptimes{i},y1,barsize,c);
        end
    end
   
    ho = findobj(h,'Type','Line');
    set(ho,'LineWidth',linewidth,'MarkerSize',0.001);
else
    if(~isempty(sptimes))
        rplot(h,sptimes,ystart,barsize,c);
        ho = findobj(h,'Type','Line');
        set(ho,'LineWidth',linewidth,'MarkerSize',0.001);
    end
end

return

function rplot(h,spk,ystart,barsize,c)
for i = 1:length(spk);
    x = spk(i); y1 = ystart; y2 = ystart + 0.9 * barsize;
    plot(h,[x x],[y1 y2],c); 
end
return