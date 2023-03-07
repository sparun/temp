% centre an image by shifting it to its centre of mass

function Xc = cogshift(X)
X = mean(X,3); framey = size(X,1); framex = size(X,2); 

% calculate center of mass and shift so that image is at center
row = sum(X,2); cogx = sum(row.*[1:length(row)]')/sum(row); shiftx = round(framex/2 - cogx);
col = sum(X,1); cogy = sum(col.*[1:length(col)])/sum(col); shifty = round(framey/2 - cogy);
Xc = circshift(X,[shiftx shifty]);

return