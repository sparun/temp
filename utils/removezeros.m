% RemoveZeros -> Remove any zero columns or rows at the beginning or end of an image

% Updates
%     5/6/2008 - Arun - original version 
%     4/8/2011 - Zhivago - cleaned up 
%    28/3/2013 - Arun - updated to work for cell arrays

function X = removezeros(X)

if(iscell(X))
	for i = 1:length(X)
		X{i} = removeimgzeros(X{i}); 
	end
else
	X = removeimgzeros(X); 
end

return

function X = removeimgzeros(X)
[nrows ncols] = size(X);
r = []; c = [];
for i = 1:nrows
    if any(X(i,:)), break; end
    r = [r i];
end
for i = nrows:-1:1
    if any(X(i,:)), break; end
    r = [r i];
end
for i = 1:ncols
    if any(X(:,i)), break; end
    c = [c i];
end
for i = ncols:-1:1
    if any(X(:,i)), break; end
    c = [c i];
end
X(r,:) = [];
X(:,c) = [];
return; 
