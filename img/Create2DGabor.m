%Create2DGabor    --> Create a 2D gabor patch with specified parameters
% Gabor = Create2DGabor(sigma,freq,theta,phi,n)
% Required inputs
%    sigma         = standard deviation in pixels. If only one
%                    value is given, sigmax = sigmay = sigma. If two values
%                    are given, sigmax = sigma(1), sigmay = sigma(2). 
%    freq          = frequency of sinusoid in cycles per pixel
%    theta         = orientation of the sinusoid (degrees cw from vertical)
% Optional inputs
%    phi           = phase of grating (default = 0)
%    n             = size of the grating patch, default = 64x64 pixels
% Outputs:
%    Gabor         = n x n matrix containing the gabor
%    X             = n x n matrix containing corresponding X values 
%    Y             = n x n matrix containing corresponding Y values
% Notes
%    Note that the Gaussian has a peak of 1, not 1/sqrt(2*pi*sigma^2)

%  Arun Sripati
%  March 20 2008

function [Gabor,X,Y] = Create2DGabor(sigma,freq,theta,phi,n)
if(~exist('n')) n = 64; end; 
if(~exist('phi')) phi = 0; end;
if(length(sigma)==1), sigma = [sigma sigma]; end;

x=[-n/2+1:n/2]; [X,Y] = meshgrid(x,x);
Grating  = Create2DGrating(freq,theta,phi,n); 
Gaussian = Create2DGaussian(sigma,[0 0],n); 
Gabor = Gaussian.*Grating; 

return