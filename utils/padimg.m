%Pad image so that it becomes an n x n array
% X = pad(X,n,val)
% Required inputs
%     X = input image matrix
%     n = maximum dimension of padded image
% Optional inputs:
%    val = value to pad with. (default = 0)
% Outputs: 
%     X = padded image


function X = pad(X,n,val)
if(~exist('val')),val = 0; end;
if(min(size(X)) == n),return; end;

nrows = size(X,1);
ncols = size(X,2);

extra_rows =  n - nrows;
extra_cols =  n - ncols;

hs1 = ceil(extra_rows/2);
hs2 = extra_rows - hs1;

ws1 = ceil(extra_cols/2);
ws2 = extra_cols - ws1;

X = padarray(X,[0 ws1],val, 'pre');
X = padarray(X,[0 ws2],val, 'post');
X = padarray(X,[hs1 0],val, 'pre');
X = padarray(X,[hs2 0],val, 'post');

return