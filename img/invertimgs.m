% invertimgs -> invert the color of all images in a cell array

% SP Arun
% 11 May 2015

function newimgs = invertimgs(imgs)

if(iscell(imgs)),
    for i = 1:length(imgs)
        newimgs{i} = 255-imgs{i}; 
    end
else
    newimgs = 255-imgs; 
end

return