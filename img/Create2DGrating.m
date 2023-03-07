%Create2DGrating   --> Create a 2D sinusoidal grating with specified parameters
% Grating = Create2DGrating(freq,theta,phi,n)
% Required inputs
%    freq          = frequency of sinusoid in cycles per pixel
%    theta         = orientation of the sinusoid (degrees cw from vertical)
% Optional inputs
%    phi           = phase of grating (default = 0)
%    n             = size of the grating patch, default = 64x64 pixels
% Outputs:
%    Grating       = n x n matrix containing the sinusoidal grating
%    X             = n x n matrix containing corresponding X values 
%    Y             = n x n matrix containing corresponding Y values

%  Arun Sripati
%  March 20 2008

function [Grating,X,Y] = Create2DGrating(freq,theta,phi,n)
if(~exist('n')) n = 64; end; 
if(~exist('phi')) phi = 0; end;

x=[-n/2+1:n/2]; [X,Y] = meshgrid(x,x);
slant = X*(2*pi*freq*cos(theta*pi/180)) + Y*(2*pi*freq*sin(theta*pi/180)); 
Grating = cos(slant+phi*pi/180);

return