% To plot global rasters, ccg's, and stimplots for neurons in L2_str
%
% function plotL2all(neurons, L2_str, saveflag, spkwindow, MM)
%
% Required inputs
%    neurons       = string pattern of neuron id's
%                    '' plots for all neurons
%    L2_str        = L2 structure
% Optional inputs
%    saveflag      = 1, save the plots to pdfs
%                    0, don't save
%    spkwindow     = start and end of visual response window
%    MM            = arragement of specific stimuli
% Outputs:
%    None
% Method
%    1) Plots global rasters and ccg's first for every track
%    2) Plots stimplots for every neuron
%
% ChangeLog:
%    11/10/2011 - ZAK - first version
%    09/02/2016 - ZAK - Updated to consider multichannel recording and
%                       plotting global rasters and ccg's for every track

function plotL2all(neurons, L2_str, saveflag, spkwindow, MM)

dbstop if error;

if ~exist('saveflag') | isempty(saveflag), saveflag = 0; end
if ~exist('spkwindow') | isempty(spkwindow), spkwindow = []; end
if ~exist('MM') MM = []; end

h = figure;

% plotting all global rasters and ccg's for every unique track
fprintf('plotting global rasters...\n');
plotL2gr(neurons, L2_str, saveflag);
fprintf('plotting ccgs...\n');
plotL2ccg(neurons, L2_str, saveflag);

% plotting stimplots for every unit
fprintf('plotting stimplots...\n'); clf;
plotL2stim(neurons, L2_str, saveflag, spkwindow, MM);

end