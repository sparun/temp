% GaussianBlur -> Blur an image using a gaussian with specified blur

% Arun Sripati
% July 24, 2008

function [B,h] = GaussianBlur(I,sigma)

if(sigma~=0)
    % create gaussian blur
    n = max(3,ceil(5*sigma)); h = fspecial('gaussian',n,sigma); h = h/sum(h(:)); 
else
    h = 1; 
end

% filter image
B = imfilter(I,h,'conv');

return

%% show the gaussian filter in frequency domain
allclear; 
h = fspecial('gaussian',1000,5.12); 
n = size(h,1); f = 64*[-n/2+1:n/2]/n; 
hf = fftshift(fft2(h)); hfx = mean(abs(hf),2); hfx = hfx/max(hfx); 

plot(f(n/2:end),hfx(n/2:end),'.-'); 
xlabel('Frequency, cyc/obj'); 
ylabel('Filter Amplitude'); 