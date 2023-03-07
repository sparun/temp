% polarfft -> compute fourier power in spatial frequency and orientation space
% [Pi,Phasei,theta,spfreq] = polarfft(G,theta,spfreq,diag_flag)
% Required inputs
%    G             = Input image 
% Optional inputs:
%    theta         = range of orientations at which fourier power is required
%    spfreq        = corresponding range of spatial frequencies 
%    diag_flag     = if 1, produces figure with image, cartesian and polar FFTs
% Outputs:
%    Pi            = fourier power matrix. Pi(i,j) is the fourier power at theta(i) and spfreq(j)
%    Phasei        = phase of power spectrum. Phase(i,j) = angle at theta(i) and spfreq(j)
%    TH            = matrix containing the values of theta
%    SPF           = matrix containing the values of spatial frequency
% Method
%    polarfft computes a cartesian-to-polar transformation of the 2D FFT. 
%    This image representation has been found useful in describing V4 neuronal responses. 
%    For a rectangular region of frequencies, like in the standard 2D FFT, the polar coordinates (r,theta) 
%    are exactly r = spatial frequency (radius) and theta = orientation of the stimulus. 
% Notes
%    Note that not all (r,theta) combinations are possible within the square. 
%    For example, the maximum frequency in either of x and y directions is 0.5 cyc/pixel 
%    But radial frequency can even go upto 0.5*sqrt(2) (on the diagonal), and there are no points
%    (x,y) corresponding to r = 0.5*sqrt(2) and theta = 0 degrees, etc. 
% Example

% Arun Sripati
% March 19 2008
%    updated to add phase spectrum 6/5/2008

function [Pi,Phasei,TH,SPF] = polarfft(G,theta,spfreq,diag_flag)
if(~exist('diag_flag')) diag_flag = 0; end; 
if(~exist('theta')||isempty(theta)),theta = [-90:1:90]; end; 
nx = size(G,1); ny = size(G,2); nfft = min(nx,ny); 
if(~exist('spfreq')||isempty(spfreq)), spfreq = [0:1/nfft:0.5-1/nfft]; end

% do fft
GF = fftshift(fft2(G)); 
P = abs(GF).^2; % P is spectral power
Phase = angle(GF); 

fx = [-nx/2:nx/2-1]/nx; fy = [-ny/2:ny/2-1]/ny; 
[Fx,Fy] = meshgrid(fy,fx); 

[TH,SPF] = meshgrid(theta,spfreq); 

[Fxi,Fyi] = pol2cart(TH*pi/180,SPF);
Pi = interp2(Fx,Fy,P,Fxi,Fyi,'linear');
Phasei = interp2(Fx,Fy,Phase,Fxi,Fyi,'linear'); 

if(diag_flag) % diagnostic code
    Pi = Pi/max(Pi(:)); P = P/max(P(:)); 
    % compute all the orientation and spatial frequency pairs present in the image
    [TH0,SPF0] = cart2pol(Fx,Fy);

    % display figure with original image, 2D FFT, and two polar versions of the FFT
    figure; colormap hot; 
    subplot(221); imagesc(G); colorbar; title('Original image'); 
    
    subplot(222); contourf(Fx,Fy,log(P)); colorbar; title('Log Fourier transform (Fx,Fy)');
    xlabel('Fx'); ylabel('Fy');
    
    subplot(223); 
    % surf(TH0(:,:)*180/pi,SPF0(:,:),P(:,:)); colorbar
    q = find(fx>=0); 
    contourf(TH0*180/pi,SPF0,P); colorbar; 
    title('Polar form, Raw'); xlabel('Orientation, degrees');
    ylabel('Spatial freq, cyc/pixel');

    subplot(224); contourf(TH,SPF,log(Pi)); colorbar; 
    title('Log Polar form, Interpolated'); xlabel('Orientation, degrees');
    ylabel('Spatial freq, cyc/pixel');
end

return