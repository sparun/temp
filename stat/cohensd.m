
function d = cohensd(x1,x2)

xpool = [vec(x1);vec(x2)]; 
d = (nanmean(x1)-nanmean(x2))/nanstd(xpool); 

end