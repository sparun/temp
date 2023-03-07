% wm_plotdata  -> this function plots all plots stored under a plotdata structure
%
% Required Inputs
%       allplotdata   : struct containing plotdata (e.g. from L1_str.specs.plotdata)
% Optional Inputs
%       qplots        : IDs of plots in plotdata that you want to see
% Outputs
%       figures
% 
% Version History:
%    Date               Authors             Notes
%    31-Jan-2023        Arun                First Implementation.
% ========================================================================================

function wm_plotdata(allplotdata,qplots)

nplots = length(allplotdata); nx = ceil(sqrt(nplots)); ny = ceil(nplots/nx); 
if(~exist('qplots')), qplots = [1:nplots]; end
figure;
for plotid = qplots
    plotdata = allplotdata(plotid); 
    subplot(nx,ny,plotid); 
    for i=1:length(plotdata.xdata)
        h = plot(plotdata.xdata{i},plotdata.ydata{i},plotdata.markerspec{i}); hold on;  
        if(~isempty(plotdata.markersize))
            set(h,'MarkerSize',plotdata.markersize{i});
        end
    end
    xlabel(plotdata.xlabel); ylabel(plotdata.ylabel); title(plotdata.name); 
    legend(plotdata.legendstr);
end

end