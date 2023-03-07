%cfp  --> calculates coarse footprint of a given image
% Xcoarse    = cfp(X,blurfactor)
% Required inputs
%    X             = input image (2d or 3d)
%    blurfactor    = sigma of gaussian blur (relative to longer dimension)
%    longdim       = image is rescaled so that its longer dimension = longdim
%    framesize     = image is padded with zeros so that the overall dim is framesize x framesize
% Outputs:
%    Xcoarse       = Coarse footprint of X (normalized, rescaled) 
% Method
%
% Required subroutines --> NormalizeObject, RemoveZeros, Pad

% SP Arun
%    First written Nov 17 2011
%    Created as lab\lib function Dec 18 2012

function Xcoarse = cfp(X,blurfactor,longdim,framesize)
if(~exist('longdim')), longdim = max(size(RemoveZeros(X))); end; 
if(~exist('framesize')), framesize = 2*longdim; end; 

X = sum(X,3)/3; sigma = longdim*blurfactor; 
Xn = NormalizeObject(X,longdim,framesize); % normalize to fixed frame
Xb = GaussianBlur(Xn,sigma);   % blur image 
Xcoarse = Xb/sum(abs(Xb(:))); % normalize so that abs sum is 1

return
