% Stimplots for neurons in L2_str
%
% plotL2stim(neurons, L2_str, MM, saveflag, spkwindow)
%
% Required inputs
%    neurons       = string pattern of neuron id's
%                    '' plots for all neurons
%    L2_str        = L2 structure
% Optional inputs
%    MM            = arragement of specific stimuli
%    saveflag      = 1, save the plots to pdfs
%                    0, don't save
%    spkwindow     = start and end of visual response window
% Outputs:
%    None
% Method
%    Plots stimplots for every neuron
%
% ChangeLog:
%    11/10/2011 - ZAK - first version
%    09/02/2015 - ZAK - Updated to consider multichannel recording and
%                       plotting global rasters and ccg's for every track
%    09/02/2015 - ZAK - Updated to consider multichannel recording and
%    07/05/2015 - ZAK - Added YTickLabel to the unit waveform axis on top-right
%    23/06/2015 - ZAK - updated for plotting multiple instances of the same stimuli
%                       and plotting rasters for all the trials in the L2_str for a stimuli
%    15/12/2015 - ZAK - updated to work with new L2 specs organized according to sites

function plotL2stim(neurons, L2_str, saveflag, spkwindow, MM)

close all; dbstop if error;
clear global p C psth ticksize itms grouped_itms expt_cfg;
global p C psth raster axis_label_flag ticksize itms grouped_itms itm_names qstditems expt_cfg;

stimflag = 0;
if exist('MM') & ~isempty(MM), stimflag = 1; end
if ~exist('saveflag') | isempty(saveflag), saveflag = 0; end
ticksize = 5;

% loading event code definitions and program names
C = extractplxhinfo();
mkprognames();

prog_name = L2_str.expt_name;
prog_id = get_prog_id(prog_name);

if stimflag == 0
    expt_cfg = load_expt_cfg(prog_id);
end

itms = L2_str.items;
itm_names = L2_str.specs.item_filenames;
nitms_per_grp = L2_str.specs.nitms_per_grp;

neuron_ids = manystrmatch(neurons,L2_str.neuron_id);
if isempty(neuron_ids), disp('No neurons found'); return; end

hf1 = gcf;

% plotting stimplots for every unit
for cell_L2 = neuron_ids'
    
    neuronid = L2_str.neuron_id{cell_L2}(1:6);
    track_L2 = cell_L2;
    if isfield(L2_str.specs, 'site_id')
        track_L2 = manystrmatch(neuronid, L2_str.specs.site_id);
    end
    tspikeall = cell(0);
    %     set(hf, 'Name', ['Offline Analysis - ' upper(L2_str.expt_name) ' - N' num2str(cell_L2) '  DATAFILE: ' L2_str.specs.data_files.plxfile{cell_L2,1}], ...
    %         'ToolBar', 'none', 'Color', [1 1 1], 'Units', 'normalized', 'Position', [0 0 1 1], 'InvertHardcopy', 'off', 'PaperPositionMode', 'auto');
    set(hf1, 'Name', 'Offline Analysis', 'ToolBar', 'none', 'Color', [1 1 1], 'Units', 'normalized', 'Position', [0 0 1 1], 'InvertHardcopy', 'off', 'PaperPositionMode', 'auto');
    global p;
    
    if isfield(L2_str, 'item_ids')
        qstditems = L2_str.item_ids{cell_L2,1};
    end
    
    if isfield(L2_str, 'groups')
        grouped_itms = prep_grouped_itms(L2_str.items, L2_str.groups, L2_str.item_ids{cell_L2,1});
    end
    
    if stimflag == 0
        eval(expt_cfg.preplayout_cmd);
    else
        axis_label_flag = 1; version_str = 'a'; rightclick_flag = 0; imgtitleflag = 0; raster.ntrials = 8; psth.binsize = .01; psth.starttime = -0.1; psth.endtime = 0.4;
        addplotarray(MM, [1;3;2], [.8 .8], [.1 .1], [0 0 0 0], [.05 .05]);
    end
    nplots = 1; if iscell(MM), nplots = length(MM); end
    
    xx = [];
    for plotid = 1:nplots
        if iscell(MM), X = MM{plotid}; else X = MM; end
        ngrps = size(X,1)*size(X,2); % should be number of stim
        for i = 1:ngrps
            stim_id = X(i);
            if stim_id > size(L2_str.spikes{cell_L2},1)
                continue;
            end
            if ~exist('spkwindow') | isempty(spkwindow)
                if size(L2_str.specs.spk_window,1) > 1
                    spkwindow = L2_str.specs.spk_window(stim_id,:);
                else
                    spkwindow = L2_str.specs.spk_window;
                end
            end
            
            psth.starttime = spkwindow(1); psth.endtime = spkwindow(2);
            psth.t = psth.starttime:psth.binsize:psth.endtime;
            xlimits = [psth.starttime psth.endtime];
            
            % correct_trials = L2_str.response_correct{cell_L2}{stim_id} == 1;
            tspike = L2_str.spikes{cell_L2}{stim_id}(:);
            if ~any(xx == stim_id)
                xx = [xx stim_id];
                tspikeall = [tspikeall; tspike];
            end
            h{plotid,i} = p(p(:,1) == stim_id & p(:,2) == 3,3);
            hh = h{plotid,i};
            % correct_trials = L2_str.response_correct{cell_L2}{stim_id} == 1;
            for j = 1:length(hh)
                
                ntrials = length(tspike);
                spk = sort(cell2mat(tspike(:)));
                spk = spk(spk >= psth.starttime & spk <= psth.endtime);
                FR = hist(spk,psth.t)/(ntrials*psth.binsize);
                bar(hh(j), psth.t,FR); hold(hh(j), 'all');
                set(hh(j), 'Box', 'on', 'XLim', xlimits, 'Units', 'Normalized', 'FontName', 'Arial', 'FontSize', 6, 'XTickLabel', '', 'YTickLabel', '', 'XLimMode', 'manual', 'YLimMode', 'manual');
            end
            % v = axis(h(i));
            maxy(i) = max(FR);
            
            meanFR = mean(FR(psth.t >= .05 & psth.t <= .3));
            
            ystart = -ticksize;
            axh = p(p(:,1) == stim_id & p(:,2) == 2,3);
            for k = 1:length(axh)
                if isempty(tspike), break; end
                set(axh(k), 'Box', 'on', 'YLim', [ystart*length(tspike) 0]);
                spkview(axh(k),tspike,ystart,ticksize);
                set(axh(k), 'XLim', xlimits, 'XLimMode', 'manual');
                v = axis(axh(k));
                for j = 1:nitms_per_grp
                    startindex = (j-1)*4 + 1;
                    t_on = L2_str.specs.onoff_stats{track_L2}(stim_id,startindex);
                    t_off = L2_str.specs.onoff_stats{track_L2}(stim_id,startindex+1);
                    plot(axh(k), [t_on t_on], [v(3) v(4)], 'r-');
                    plot(axh(k), [t_off t_off], [v(3) v(4)], 'r-');
                end
            end
        end
        yrange(plotid) = max(maxy);
    end
    maxpsth = max(yrange);
    for plotid = 1:nplots
        if iscell(MM), X = MM{plotid}; else X = MM; end
        ngrps = size(X,1)*size(X,2); % should be number of stim
        for i = 1:ngrps
            stim_id = X(i);
            if stim_id > size(L2_str.spikes{cell_L2},1)
                continue;
            end
            for k = 1:length(h{plotid,i})
                hh = h{plotid,i};
                v = axis(hh(k));
                axis(hh(k), [v(1) v(2) v(3) maxpsth]);
                for j = 1:nitms_per_grp
                    startindex = (j-1)*4 + 1;
                    t_on = L2_str.specs.onoff_stats{track_L2}(stim_id,startindex);
                    t_off = L2_str.specs.onoff_stats{track_L2}(stim_id,startindex+1);
                    plot(hh(k), [t_on t_on], [v(3) maxpsth], 'r-');
                    plot(hh(k), [t_off t_off], [v(3) maxpsth], 'r-');
                end
            end
        end
    end
    global_title([], [], [num2str(cell_L2, 'NEURON %04d') ' - ' upper(L2_str.expt_name) ' - ' L2_str.neuron_id{cell_L2,1} ' - ' L2_str.specs.data_files.plxfile{track_L2,1}]);
    
    wh = axes('Position', [.91 .91 .08 .08], 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5);
    errorbar(wh, L2_str.specs.waveforms{cell_L2}(1,:), L2_str.specs.waveforms{cell_L2}(2,:))
    set(wh, 'XTickLabel', '', 'FontSize', 12); axis(wh, 'tight');
    
    grh = axes('Position', [.91 .01 .08 .89], 'Box', 'on', 'DrawMode', 'fast', 'FontSize', 5);
    spkview(grh,tspikeall,ystart,ticksize);
    set(grh, 'XLim', xlimits, 'YLim', [-ticksize*length(tspikeall) ystart], 'Box', 'on', 'XTick', [], 'YTick', [], 'XTickLabel', '', 'YTickLabel', '');
    
    clear global p;
    hf1 = findobj('Name', 'Offline Analysis');
    hf2 = findobj('Name', 'O2');
        
    if(saveflag)
        if ~isempty(hf1), figure(hf1); export_fig([L2_str.expt_name '_' L2_str.neuron_id{cell_L2,1} '.pdf'], '-native', '-nocrop'); end
        if ~isempty(hf2), figure(hf2); export_fig([L2_str.expt_name '_' L2_str.neuron_id{cell_L2,1} '_P2.pdf'], '-native', '-nocrop'); end
    end
    
    clf(hf1);
    if ~isempty(hf2), clf(hf2); end
    figure(hf1);
end
close all;
end

function C = extractplxhinfo()
readplxh;
save plxh;
C = load('plxh');
end