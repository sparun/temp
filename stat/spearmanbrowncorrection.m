% Spearman-Brown correction for split-half correlation
% rnew = k*r/(1+ (k-1)*r) where k = 2 for split-half, k = 3 for three-way split etc.
% for k = 2, rnew = 2r/(1+r)

function rnew = spearmanbrowncorrection(r,k)

rnew = k*r./(1+(k-1)*r); 

return