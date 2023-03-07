function addplotarray(MM, plottypes, props, offsets, margins, spc)
global itm_names itms qstditems grouped_itms p raster grplot psth ticksize rightclick_flag axis_label_flag imgtitleflag;

% plottypes
% 1 = image
% 2 = raster
% 3 = psth
% 4 = image for current trial;
% 5 = raster for current trial
% 6 = global raster

% [1 2 3] will produce plots with images, rasters and psth
% [1 2] will produce plots with images and rasters only
% [1] will produce plots with images only

if ~exist('axis_label_flag') | isempty(axis_label_flag), axis_label_flag = 0; end

nplots = length(plottypes);
nprows = size(MM,1); npcols = size(MM,2);

if size(plottypes,1) == 2
    axhandles = createplotarray([1;2],nprows, npcols, props, offsets, margins, spc, axis_label_flag);
elseif size(plottypes,1) == 3
    axhandles = createplotarray([1;2;3],nprows, npcols, props, offsets, margins, spc, axis_label_flag);
else
    axhandles = createplotarray(nplots,nprows, npcols, props, offsets, margins, spc, axis_label_flag);
end

if isempty(p)
    count = 0;
else
    count = size(p,1);
end

for i = 1:nprows
    for j = 1:npcols
        for k = 1:nplots
            if MM(i,j) == 0, delete(axhandles(i,j,k)); continue; end
            count = count + 1;
            p(count,1) = MM(i,j);
            p(count,2) = plottypes(k);
            p(count,3) = axhandles(i,j,k);
            axh = p(count,3);
            if plottypes(k) == 1
                if isempty(grouped_itms)
                    if isempty(qstditems)
                        imshow(itms{p(count,1),1}, 'Parent', axh);
                    else
                        imshow(itms{qstditems(p(count,1)),1}, 'Parent', axh);
                    end
                else
                    imshow(grouped_itms{p(count,1),1}, 'Parent', axh);
                end
                colormap(axh,'gray'); axis(axh,'off'); % axis(axh,'image');
                
                if imgtitleflag == 1
                    title(axh, ['STIM# ' num2str(p(count,1))], 'BackgroundColor', [.7 1 .7], 'Color', [0 0 0], 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 8, 'FontWeight', 'bold');
                end
            elseif plottypes(k) == 2
                axis(axh, [psth.starttime psth.endtime -raster.ntrials*ticksize 0]);
                if rightclick_flag == 1
                    fname = char(itm_names{MM(i,j),1});
                    filePath = ['d:\experiments\lib\online\lowresstims\png\' fname(1:end-3) 'png'];
                    filePath = strrep(['file:/' filePath],'\','/');
                    str = ['<html><center><img src="' filePath '"><br>'];
                    % Create a UICONTEXTMENU, and assign a UIMENU to it
                    hcontext = uicontextmenu;
                    hmenu = uimenu('parent', hcontext);
                    % Set the UICONTEXTMENU to the line object
                    set(axh, 'uicontextmenu', hcontext);
                    set(hmenu, 'label', str);
                end
            elseif plottypes(k) == 3
                set(axh, 'XLim', [psth.starttime psth.endtime]);
            elseif plottypes(k) == 5
                axis(axh, [psth.starttime psth.endtime -ticksize 0]);
            elseif plottypes(k) == 6
                axis(axh, [psth.starttime psth.endtime -grplot.max_rasters*ticksize 0]);
            end
            axis(axh, 'manual');
        end
    end
end
end