function [grp_itms ngrps nitms_per_grp] = prep_grp_itms_map(cnds, cnd_grps)
grp_itms = [];
ngrps = max(max(cnd_grps));
nitms_per_grp = size(cnds,2)/size(cnd_grps,2);
for grp = 1:ngrps
    [row col] = find(cnd_grps == grp, 1);
    start_col = (col - 1) * nitms_per_grp + 1;
    end_col = start_col + nitms_per_grp - 1;
    grp_itms(grp,:) = cnds(row, start_col:end_col);
end
end