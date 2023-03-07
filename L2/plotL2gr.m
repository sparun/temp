% To plot ccg for a given set of tracks in L2_str
%
% function plotL2gr(tracks, L2_str, saveflag, spkwindow)
%
% Required inputs
%    tracks        = cell array of track/neuron ids
%    L2_str        = L2 structure
% Optional inputs
%    saveflag      = 1, save the plots to pdfs
%                    0, don't save
%    spkwindow     = start and end of visual response window
% Outputs:
%    None
% Method
%    Plots global rasters for the specified tracks
%
% ChangeLog:
%    09/02/2015 - ZAK - first version

function plotL2gr(tracks, L2_str, saveflag, spkwindow)

if ~exist('saveflag') | isempty(saveflag), saveflag = 0; end
if ~exist('spkwindow') | isempty(spkwindow), spkwindow = L2_str.specs.spk_window; end

neuron_ids = manystrmatch(tracks, L2_str.neuron_id);
if isempty(neuron_ids), disp('No neurons found'); return; end
trackids = unique(cellfun(@(x) x(1:6), L2_str.neuron_id(neuron_ids), 'UniformOutput', false));

for trackid = 1:length(trackids)
    tspikeall = cell(0);
    neuron_ids = manystrmatch(trackids{trackid}, L2_str.neuron_id);
    if isempty(neuron_ids), disp(['GR PLOT: (' trackids{trackid} ') NO RELEVANT TRACK FOUND!!!']); return; end
    channels = str2double(cellfun(@(x) x(10:11), L2_str.neuron_id(neuron_ids), 'UniformOutput', false));
    units = str2double(cellfun(@(x) x(14), L2_str.neuron_id(neuron_ids), 'UniformOutput', false));
    
    % gathering all the spikes for a given neuron
    for i = 1:length(neuron_ids)
        xx = L2_str.spikes{neuron_ids(i)};
        xx = cellfun(@(x) x', xx, 'UniformOutput', false);
        tspikeall{i,1} = cellfun(@(x) cell2mat(x), xx, 'UniformOutput', false);
    end
    
    % initializing plot parameters
    ticksize = 5;
    
    set(gcf, 'Name', 'GLOBAL RASTERS', 'ToolBar', 'none', 'Color', [1 1 1], 'Units', 'normalized', 'Position', [0 0 1 1], 'InvertHardcopy', 'off', 'PaperPositionMode', 'auto');
    clf; grh = create2dplotarray(4, 24, [.98 .9], [.01 .05], [0 0 0 0], [.075 .15]);
    
    ystart = -ticksize;
    for i = unique(channels)'
        
        % retrieving current channel and associated units
        chid = i;
        chunits = units(channels == i);
        
        % checking if mua exists for this channel
        muaflag = 0;
        q = find(isnan(chunits));
        if ~isempty(q) % mua detected
            muaflag = 1;
            chunits(end) = q;
        end
        
        % selecting the first 3 sua channels and mua for plotting
        nunits = length(chunits);
        chunits(chunits>3) = [];
        if muaflag & nunits > 3, chunits(end+1) = chunits(end) + 2; end
        
        % plotting global raster for every neuron
        uid = 1;
        for j = 1:length(chunits)
            % plotting sua or mua
            if muaflag & j == length(chunits)
                uid = 4;
                title(grh(uid,chid), sprintf('%02d,MU', i), 'FontSize', 15, 'FontWeight', 'bold', 'Color', [.7 0 1]);
                % indexing into the full neuron lis
                q = find(channels == i & isnan(units));
            else
                title(grh(uid,chid), sprintf('%02d,U%d', i, j), 'FontSize', 15, 'FontWeight', 'bold', 'Color', [.7 0 1]);
                % indexing into the full neuron lis
                q = find(channels == i & units == chunits(j));
            end
            
            % plotting the global rasters
            hold(grh(uid,chid), 'all');
            set(grh(uid,chid), 'XLim', spkwindow, 'YLim', [-length(tspikeall{q})*ticksize 0], 'XTick', [], 'YTick', []);
            v = axis(grh(uid,chid));
            plot(grh(uid,chid), [0 0], [v(3) v(4)], 'r');
            spkview(grh(uid,chid),tspikeall{q},ystart,ticksize);
            uid = uid + 1;
        end
    end
    
    hh = uicontrol('Style', 'text', 'FontSize', 20, 'Units', 'normalized', 'Position', [.4 .96 .2 .03], 'String', sprintf('%s - %s', upper(L2_str.expt_name), trackids{trackid}), 'BackgroundColor', [.8 1 0]);
    
    if saveflag == 1
        export_fig([L2_str.expt_name '_' trackids{trackid} '__gr.pdf'], '-native', '-nocrop');
    end
end
end