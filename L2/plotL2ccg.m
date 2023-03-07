% Plots ccg for top 3 units + MUA for each channel in an L2_str
%
% Required inputs
%    tracks        = cell array of track/neuron ids
%    L2_str        = L2 structure
% Optional inputs
%    saveflag      = 1, save the plots to pdfs
%    tpsth         = time bins for spike histogram calculation
%                    0, don't save (default)
% Outputs:
%    Plot containing ccg
% Method
%    For every track, plots the average cross-correlation for every
%    pair of neurons and then plots the ccg for the top 8 pair of units
%    with the highest cross-correlation.
%
% ChangeLog:
%    23/03/2015 - ZAK - first version

function plotL2ccg(tracks, L2_str, saveflag, tpsth)

dbstop if error;

binsize = .005;
if ~exist('tpsth') | isempty(tpsth), tpsth = .05:binsize:.2; end % ccg calculation spike window
if ~exist('saveflag') | isempty(saveflag), saveflag = 0; end

neuronids = manystrmatch(tracks, L2_str.neuron_id);
if isempty(neuronids), disp('No neurons found'); return; end
trackids = unique(cellfun(@(x) x(1:6), L2_str.neuron_id(neuronids), 'UniformOutput', false));

for trackid = 1:length(trackids)
    
    neuronids = manystrmatch(trackids{trackid}, L2_str.neuron_id);
    if isempty(neuronids), disp(['CCG PLOT: (' trackids{trackid} ') NO RELEVANT TRACK FOUND!!!']); return; end
    
    allspks = L2_str.spikes(neuronids);
    ntrials = sum(cellfun('length', allspks{1}));
    
    channels = str2double(cellfun(@(x) x(10:11), L2_str.neuron_id(neuronids), 'UniformOutput', false));
    units = str2double(cellfun(@(x) x(14), L2_str.neuron_id(neuronids), 'UniformOutput', false));
    
    % retaining only 3 sua
    q = find(units>3);
    if ~isempty(q), channels(q) = []; units(q) = []; neuronids(q) = []; end
    
    % renaming mua as unit# 4
    q = find(isnan(units));
    if ~isempty(q), units(q) = 4; end
    
    ncells = length(neuronids);
    nch = 24; nunitsperch = 4;
    actualspks = cell(ntrials,nch*nunitsperch);
    actualspks = cellfun(@(x) NaN, actualspks, 'UniformOutput', false);
    for i = 1:ncells
        cid = channels(i); uid = units(i);
        q = 4*(cid-1) + uid;
        actualspks(:,q) = [allspks{i}{:}]';
    end
    actualspks = cellfun(@(x) trimspktrain(x), actualspks, 'UniformOutput', false);
    
    maxlags = 30;
    [ccg, sccg] = ccgspikes(actualspks, tpsth, maxlags);
    
    maxlags = maxlags*binsize;
    ccg2 = ccg;
    q = isnan(sccg); sccg(q) = 0;
    q = isnan(ccg); ccg(q) = 0;
    
    % shuffle-corrected ccg
    cccg = squeeze(nanmean(ccg) - nanmean(sccg));
    cccge = squeeze(nansem(ccg - sccg));
    
    [xrcccgmax, xcccgpeaklags] = max(cccg); xcccgpeaklags = xcccgpeaklags*binsize - (maxlags + binsize);
    rcccgmax = squareform(xrcccgmax);
    cccgpeaklags = squareform(xcccgpeaklags);
    
    clear allspks actualspks ccg sccg uccg xcccgpeaklags;
    
    % plotting ccg & sccg
    X = ones(size(rcccgmax,1)); qtril = find(tril(X)); qtriu = find(triu(X));
    cccgpeaklags(qtril) = 0;
    rcccgmax(qtril) = 0;
    rcccgmax(isnan(rcccgmax)) = 0;    
    
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
    
    % setting all NaN's to zero since they show up first on a descend sort
    topn = 8;
    xrcccgmax(isnan(xrcccgmax)) = 0;
    [r qmaxr] = sort(vec(xrcccgmax), 'descend');
    r = r(1:topn); qmaxr = qmaxr(1:topn);
    lags = [-maxlags:binsize:maxlags];
    nchoosekpairs = nchoosek(1:nch*nunitsperch,2);
    hccg = create2dplotarray(4, 2, [.35 .85], [.65 .07], [0 0 0 0], [.2 .5]);
    
    for i = 1:numel(r)
        h = hccg(i);
        q = qmaxr(i);
        
        xx = ccg2(:,:,q);
        nnans = sum(isnan(xx));
        xx(isnan(xx)) = 0;
        [maxx ql] = max(mean(xx));
        percentnans = uint8(100*nnans(ql)/size(xx,1));
        
        [xx qq] = max(cccg(:,q));
        peaklag = lags(qq);
        axes(h);
        % plot(h, lags, cccg(:,q));
        errorbar(lags, cccg(:,q), cccge(:,q));
        set(h, 'YLim', [-1 1], 'XLim', [-maxlags maxlags], 'FontSize', 15);
        x1 = nchoosekpairs(q,1); ch1 = ceil(x1/4); u1 = x1 - (ch1-1)*4;
        x2 = nchoosekpairs(q,2); ch2 = ceil(x2/4); u2 = x2 - (ch2-1)*4;
        if u1 == 4, u1str = 'um'; else u1str = ['u' num2str(u1)]; end
        if u2 == 4, u2str = 'um'; else u2str = ['u' num2str(u2)]; end
        title(h, sprintf('PAIR AB (CH%02d_%s, CH%02d_%s)\n%.0f%% NaN peak-r trials set to 0\npeaklag = %.0f ms, r = %.2f', ch1, u1str, ch2, u2str, percentnans, peaklag*1000, r(i)), 'Interpreter', 'none');
        if (i == 4 | i == 8), xlabel(h, 'A lags B      lag, s     A leads B'); end
        if (i <= 4), ylabel(h, 'cross-correlation'); end
    end
    
    h1 = uicontrol('Style', 'text', 'FontSize', 20, 'Units', 'normalized', 'Position', [.65 .96 .3 .03], 'String', sprintf('%s - %s', upper(L2_str.expt_name), trackids{trackid}), 'BackgroundColor', [0 .7 1]);
    h2 = uicontrol('Style', 'text', 'FontSize', 20, 'Units', 'normalized', 'Position', [.65 .93 .3 .03], 'String', sprintf('TOP %d CORRELATED CHANNEL PAIRS', topn), 'BackgroundColor', [1 .7 0]);
    h3 = uicontrol('Style', 'text', 'FontSize', 20, 'Units', 'normalized', 'Position', [.15 .015 .3 .03], 'String', sprintf('SHUFFLE-CORRECTED CORRELOGRAM'), 'BackgroundColor', [1 .9 0]);
    h4 = uicontrol('Style', 'text', 'FontSize', 15, 'Units', 'normalized', 'Position', [.55 .93 .07 .02], 'String', sprintf('A LEADS B'), 'BackgroundColor', [1 0 0], 'ForegroundColor', [1 1 1]);
    h5 = uicontrol('Style', 'text', 'FontSize', 15, 'Units', 'normalized', 'Position', [.55 .03 .07 .02], 'String', sprintf('A LAGS B'), 'BackgroundColor', [0 0 1], 'ForegroundColor', [1 1 1]);
    h5 = uicontrol('Style', 'text', 'FontSize', 30, 'Units', 'normalized', 'Position', [.003 .5 .02 .04], 'String', sprintf('A'), 'BackgroundColor', [.1 1 0], 'ForegroundColor', [1 1 1]);
    h6 = uicontrol('Style', 'text', 'FontSize', 30, 'Units', 'normalized', 'Position', [.3 .957 .02 .04], 'String', sprintf('B'), 'BackgroundColor', [.1 1 0], 'ForegroundColor', [1 1 1]);
    
    % making negative lag correlations negative for display purposes
    % when A leads B, it will be shown in red and blue otherwise
    xx = rcccgmax;
    xx(cccgpeaklags < 0) = xx(cccgpeaklags < 0) * -1;
    
    axh = axes('Position', [.07/aspratio .07 .85/aspratio .85]);
    imagesc(xx, 'Parent', axh); axis(axh, 'square'); caxis(axh, [-1 1]); colormap(blueredmap); colorbar;
    set(axh, 'XAxisLocation', 'top', 'XTick', 4:4:96, 'TickDir', 'out');
    set(axh, 'XTickLabel', {'2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24', ''});
    set(axh, 'YTick', 4:4:96, 'TickDir', 'out');
    set(axh, 'YTickLabel', {'2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24', ''}, 'FontSize', 15, 'FontWeight', 'bold');
    grid(axh, 'on');
    
    h7 = axes('Position', [.1 .15 .3/aspratio .3]); set(h7, 'Color', [1 1 0.5]);
    scatter(h7, cccgpeaklags(qtriu), rcccgmax(qtriu), 'b'); hold(h7, 'on');
    plot(h7, [0 0], [-1 1], 'r--');
    set(h7, 'XLim', [-maxlags maxlags], 'YLim', [-1 1], 'FontSize', 15, 'FontWeight', 'bold', 'Color', [1 1 .5], 'XTick', [-maxlags 0 maxlags], 'YTick', [-1 1]);
    xlabel(h7, 'peak lag, s', 'FontSize', 15, 'Color', 'r', 'FontWeight', 'bold');
    ylabel(h7, 'peak cross-correlation', 'FontSize', 15, 'Color', 'r', 'FontWeight', 'bold');
    
    if saveflag == 1
        export_fig([L2_str.expt_name '_' trackids{trackid} '__ccg.pdf'], '-native', '-nocrop');
    end
    
end

    % to remove spikes outside the spike window stated for ccg computation
    function s = trimspktrain(s)
        s(s < tpsth(1) | s > tpsth(end)) = [];
        if isempty(s), s = NaN; end
    end

end
