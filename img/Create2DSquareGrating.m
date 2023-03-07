%Create2DSquareGrating --> Create a 2D square wave grating 
% Grating = Create2DSquareGrating(bar_width,orient,offset,n)
% Required inputs
%    bar_width     = bar width in pixels
%    orient        = orientation of grating(degrees cw from vertical)
% Optional inputs
%    offset        = phase of grating in pixels (default = 0)
%    n             = size of the grating patch, default = 64x64 pixels
% Outputs:
%    Grating       = n x n matrix containing the square-wave grating
%    X             = n x n matrix containing corresponding X values 
%    Y             = n x n matrix containing corresponding Y values

%  Arun Sripati
%  November 16 2009

function [Grating,X,Y] = Create2DSquareGrating(bar_width,orient,offset,n)
if(~exist('offset')) offset = 0; end;
if(~exist('n')) n = 64; end; 
offset = round(offset); bar_width = round(bar_width); 

basic_unit = [ones(2*n,bar_width) zeros(2*n,bar_width)]; 
nrep = floor(2*n/size(basic_unit,2)); 
G = repmat(basic_unit,[1 nrep]); 
G = circshift(G,[0 offset]); 
Grating = imrotate(G,-orient,'crop'); 
x=[-n/2+1:n/2]; [X,Y] = meshgrid(x,x);
Grating = Grating(n+x,n+x); 

return