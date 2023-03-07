% reads a given ctx items file and loads the stimuli images/names into a cell arrays
function [itms itm_names item_ids] = readitmfile(itmfile, stimfolder, removeitems, splitem_flag, std_item_names)
if ~exist('removeitems') | isempty(removeitems), removeitems = 0; end;
if ~exist('std_item_names') | isempty(std_item_names), std_item_names = []; end;

item_ids = [];
itms = [];
itm_names = cell(1,1);
fid = fopen(itmfile);
tline = '';
count = 0;
while ischar(tline)
    tline = fgetl(fid);
    if tline == -1, break; end
    if strfind(tline, '.bmp')
        count = count + 1;
        A = sscanf(tline, '%*d%*c%d%*c%s%S');
        itm_names{count, 1} = char(A(2:end))';
        if ~isempty(std_item_names)
            item_ids(count,1) = find(strcmp(std_item_names, itm_names{count, 1}));
        end
    end
end
fclose(fid);
if isempty(std_item_names)
    nitms = size(itm_names,1);
    itms = cell(nitms,1);
    for i = 1:nitms
        fname = [stimfolder itm_names{i,1}];
        itms{i,1} = imread(fname);
    end
    matfolder = [stimfolder '\mats'];
    if ~exist(matfolder), mkdir(matfolder); end
    save([stimfolder '\mats\itms_' itmfile(find(itmfile == uint8('\'), 1, 'last')+1:end-4) '.mat'], 'itms', 'itm_names');
    if removeitems == 1 && splitem_flag == 0
        for i = 1:nitms
            fname = [stimfolder itm_names{i,1}]; if exist(fname), delete(fname); end
        end
    end
end
end