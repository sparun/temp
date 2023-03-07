function itm_grps = prep_grouped_itms(itms, groups, item_ids)
if ~exist('item_ids'), item_ids = []; end
[ngrps nstims_per_grp] = size(groups);
itm_grps = cell(ngrps,1);
for grp = 1:ngrps
    stim_ids = groups(grp,:);
    for s = 1:nstims_per_grp
        d = size(itms{stim_ids(s)});
        if length(d) == 2
            separator = [ones(d(1),1)*255 zeros(d(1),1) ones(d(1),1)*255 zeros(d(1),1) ones(d(1),1)*255];
        elseif length(d) == 3
            separator = [ones(d(1),1,3)*255 zeros(d(1),1,3) ones(d(1),1,3)*255 zeros(d(1),1,3) ones(d(1),1,3)*255];
        end
        if isempty(item_ids)
            img = itms{stim_ids(s)};
        else
            img = itms{item_ids(stim_ids(s))};
        end
        if islogical(img), img = img*255; end
        itm_grps{grp,1} = [itm_grps{grp,1} img separator];
    end
end
end