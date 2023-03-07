%Create2DGaussian  --> Create a 2D gaussian with specified parameters
% Gaussian = Create2DGaussian(sigma,n)
% Required inputs
%    sigma         = standard deviation in pixels. If only one
%                    value is given, sigmax = sigmay = sigma. If two values
%                    are given, sigmax = sigma(1), sigmay = sigma(2). 
% Outputs:
%    Gaussian      = n x n matrix containing the gaussian
%    X             = n x n matrix containing corresponding X values 
%    Y             = n x n matrix containing corresponding Y values
% Notes
%    Note that the Gaussian has a peak of 1, not 1/sqrt(2*pi*sigma^2)

%  Arun Sripati
%  March 20 2008

function [Gaussian,X,Y] = Create2DGaussian(sigma,center,n)
if(~exist('n')) n = 64; end; 
if(~exist('center')), center = [0 0]; end; 
if(length(sigma)==1) sigma = [sigma sigma]; end;

cx = center(1); cy = center(2); 
sigmax = sigma(1); sigmay = sigma(2); 
x=[-n/2+1:n/2]; [X,Y] = meshgrid(x,x);
Gaussian = exp(-((X-cx).^2/(2*sigmax^2) +(Y-cy).^2/(2*sigmay^2)));

return