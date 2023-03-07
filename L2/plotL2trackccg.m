% Plots all ccgs for a given track
%    To be used when there are more than 3 units in a given channel
% Required inputs
%    trackid       = track id string
%    L2_str        = L2 structure
% Optional inputs
%    binsize       = time binsize
%    tpsth         = time bins for spike histogram computation
% Outputs:
%    None
% Method
%    Plots average cross-correlation for every pair of neurons in the
%    specified track
%
% ChangeLog:
%    02 Apr 2015 - ZAK - first version
%    05 Jun 2015 - SPA - split into plotL2trackccg and FetchL2trackccg 

function plotL2trackccg(track, L2_str, binsize, tpsth, maxlags)
if ~exist('tpsth') | isempty(tpsth), binsize = .005; tpsth = .05:binsize:.2; end
if ~exist('maxlags'| isempty(maxlags), maxlags = 30; end; 

[cccg, uccg, sccg] = FetchL2trackccg(track,L2_str,binsize,tpsth,maxlags); 

[xrcccgmax, xcccgpeaklags] = max(cccg); xcccgpeaklags = xcccgpeaklags*binsize - (maxlags + binsize);
rcccgmax = squareform(xrcccgmax);
cccgpeaklags = squareform(xcccgpeaklags);

clear allspks ccg sccg xcccgpeaklags;

% plotting ccg & sccg
X = ones(size(rcccgmax,1)); qtril = find(tril(X)); qtriu = find(triu(X));
cccgpeaklags(qtril) = 0;
rcccgmax(isnan(rcccgmax)) = 0;
rcccgmax(qtril) = 0;
rcccgmax(cccgpeaklags < 0) = rcccgmax(cccgpeaklags < 0) * -1;

% creating colormap
cgrad = (0:.1:1)'; nsteps = length(cgrad);
bluescale = [repmat(cgrad, [1 2]) ones(nsteps,1)];
cgrad = (1:-.1:0)'; nsteps = length(cgrad);
redscale = [ones(nsteps,1) repmat(cgrad, [1 2])];
blueredmap = [bluescale; redscale];

clf;
set(gcf, 'Name', 'Site Correlograms', 'ToolBar', 'none', 'Color', [1 1 1], 'Units', 'normalized', 'Position', [0 0 1 1], 'InvertHardcopy', 'off', 'PaperPositionMode', 'auto');
scr = get(0,'screensize');
aspratio = scr(3)/scr(4);

% making negative lag correlations negative for display purposes
% when A leads B, it will be shown in red and blue otherwise
xx = rcccgmax;
xx(cccgpeaklags < 0) = xx(cccgpeaklags < 0) * -1;

axh = axes('Position', [.07/aspratio .07 .85/aspratio .85]);
imagesc(xx, 'Parent', axh); axis(axh, 'square'); caxis(axh, [-1 1]); colormap(blueredmap); colorbar;
set(axh, 'FontSize', 20, 'Color', [0 0 0], 'FontWeight', 'bold', 'XTick', 1:length(xx), 'YTick', 1:length(xx));
xlabel(axh, 'neuron id'); ylabel(axh, 'neuron id'); title(axh, 'CORRELOGRAM');
grid(axh, 'on');

h7 = axes('Position', [.1 .15 .3/aspratio .3]); set(h7, 'Color', [1 1 0.5]);
scatter(h7, cccgpeaklags(qtriu), rcccgmax(qtriu), 'b'); hold(h7, 'on');
plot(h7, [0 0], [-1 1], 'r--');
set(h7, 'XLim', [-maxlags maxlags], 'YLim', [-1 1], 'FontSize', 15, 'FontWeight', 'bold', 'Color', [1 1 .5], 'XTick', [-maxlags 0 maxlags], 'YTick', [-1 1]);
xlabel(h7, 'peak lag, s', 'FontSize', 15, 'Color', 'r', 'FontWeight', 'bold');
ylabel(h7, 'peak cross-correlation', 'FontSize', 15, 'Color', 'r', 'FontWeight', 'bold');

uicontrol('Style', 'text', 'BackgroundColor', [.1 1 .8], 'FontSize', 15, 'Units', 'normalized', 'Position', [.70 .9 .15 .03], 'String', 'NEURON IDS');
for i = 1:length(cellid)
    uicontrol('Style', 'text', 'BackgroundColor', [1 .8 0], 'FontSize', 15, 'Units', 'normalized', 'Position', [.70 .89-i*.03 .15 .03], 'String', sprintf('%02d: %s', i, L2_str.neuron_id{cellid(i)}));
end

end