% v1model -> simulate responses of V1 neurons to an input image
% img_out    = v1model(img_in,img_dva)
% Required inputs
%    img_in        = input image matrix (L x M)
% Optional inputs:
%    img_dva       = size in dva of the image (default scaling: 18.2 pixels/dva)
% Outputs:
%    img_out       = L x M x N - where N is the number of Gabor filters 
%                    (48 is default)
% Method
% V1 responses are obtained in four steps. 
%       1) Each image is first rescaled to the desired dva size and then normalized for intensity
%       and contrast by subtracting its mean and dividing by its standard deviation.
%       2) This normalized image was subjected to divisive normalization: for each 3 x 3
%       pixel window, we subtracted the mean and divided each pixel by the Euclidean norm of the
%       pixels in the window. This normalization was constrained to reduce but not enhance responses
%       (i.e. we divided only if the norm was greater than 1).
%       3) The resulting image was given as input to 96 V1 model neurons each having a linear Gabor
%       kernel. Each filter had a size of 43 x 43 pixels with a standard deviation of 9
%       cycles/pixel. The filters were tuned to 8 equally spaced orientations from 0 to 360
%       degrees, with 6 spatial frequencies (2, 3, 4, 6, 11 and 18 pixels per cycle). We normalized
%       the output of each of the 96 Gabor filters to have zero mean and a norm of 1.
%       4) The output of each Gabor filter was then passed through a response nonlinearity
%       comprising a threshold function (all negative values were set to zero), and response
%       saturation (all values greater than 1 were set to 1).
%       5) Finally, we perform output divisive normalization, where for each filter output, we
%       subtracted the mean of filter outputs in a fixed spatial window of 3 x 3 pixels across all
%       orientations and spatial frequencies and then divided by the Euclidean norm of all values in
%       the spatial window of 864 elements (3 x 3 x 96), if the norm was greater than 1.

% Notes
%    Based on published V1 RF sizes, the conversion from pixels to dva 
%    can be taken as 18.2 pixels/dva (see v1modeldva.pdf)

% References
% Pinto N, Cox DD, DiCarlo JJ (2008) Why is real-world visual object recognition hard? PLoS Comput
% Biol 4:e27

% Krithika Mohan & S P Arun
% December 20 2010

function [img_out,filters] = v1model(img_in,img_dva)
v1pix2dva = 18.2; if(~exist('img_dva')), img_dva = max(size(img_in))/v1pix2dva; end; 
spatial_extent       = 3; % size of local neighborhood for computations (default = 3x3 pixels)

img_out              = normalize_image(img_in,img_dva,v1pix2dva); % manyimagesc(img_out); 
img_out              = divisive_normalization(img_out,spatial_extent); %manyimagesc(img_out);
[img_out,filters]    = apply_gabor_filter(img_out); %manyimagesc(img_out);
img_out              = output_nonlinearity(img_out); %manyimagesc(img_out);
img_out              = output_divisive_normalization(img_out,spatial_extent); %manyimagesc(img_out);

return

function img_out = normalize_image(img_in,img_dva,v1pix2dva)
% this function takes an input matrix, scales it to a standard size and 
% then subtracts its mean and divides by its standard deviation
norm_size = v1pix2dva*img_dva; % scale img_in to the desired dva size

img_in = mean(img_in,3); % convert to grayscale
long_edge = max(size(img_in)); % longest edge
asp_ratio = min(size(img_in))/long_edge; % aspect ratio (will be less than 1)
if(size(img_in,1)==long_edge) %largest edge is resized to a specified length.
    img = imresize(img_in,[norm_size norm_size*asp_ratio], 'bicubic');
else
    img = imresize(img_in,[norm_size*asp_ratio norm_size], 'bicubic');
end
img = (img - mean(img(:)))./std(img(:)); % subtract mean and divide by standard deviation.

img_out = img;

return

function img_out = divisive_normalization(img_in,spatial_extent)
% This function takes an input matrix, subtracts from each pixel its mean and divides by the
% euclidean norm of its neighbors. spatial_extent defines the extent across which to calculate the mean
% and euclidean norm (default = 3x3 pixels i.e. spatial_extent = 3)

if(~exist('spatial_extent')), spatial_extent = 3; end
spatial_win = ones(spatial_extent); 

ndim = size(img_in);
% define div_matrix which defines the number of neighbors for each pixel. This is used to calculate
% the mean across neighbors of each pixel in img_in
% this matrix has 4 at the corners, 6 along the first and last row/column
% and 9 in the remaining entries. 
div_matrix = conv2(ones(ndim),ones(spatial_extent),'same'); 

sum_matrix = conv2(img_in, spatial_win,'same'); %sum of the pixel values surrounding every pixel
avg_matrix =sum_matrix./div_matrix;

sum_square_matrix = conv2(img_in.^2, ones(3,3),'same'); % sum of squares of neighbors
euc_norm = sqrt(sum_square_matrix); 
euc_norm(euc_norm<1) = 1; % force divisive normalization to only reduce activity but not increase it

img_out = (img_in - avg_matrix)./euc_norm; 

return

function [img_out,filters] = apply_gabor_filter(img_in)
% this function convolves the image with a bunch of gabor filters

filters = make_gabors; 
for filter_no = 1:size(filters,3)
    img_out(:,:,filter_no) = conv2(img_in,filters(:,:,filter_no),'same');
end

return

function img_out = output_nonlinearity(img_in)
% this function applies a standard response saturation and threshold
% i.e. all values greater than 1 are set to 1. all negative values are set to 0

img_out = img_in; 
img_out(img_out>1) = 1; img_out(img_out<0) = 0; 
return

function img_out = output_divisive_normalization(img_in,spatial_extent)
% This function implements divisive normalization over the output of gabor filters
% It takes an 3d input matrix (3rd dim = num of filters), subtracts from each pixel its mean and divides by the
% euclidean norm of its neighbors. spatial_extent defines the extent across which to calculate the mean
% and euclidean norm (default = 3x3 pixels i.e. spatial_extent = 3)

if(~exist('spatial_extent')), spatial_extent = 3; end; spatial_win = ones(spatial_extent); 

ndim = size(img_in); nfilters = ndim(3); 
square_img = img_in.^2;

% div_matrix specifies the number of visual field neighbors of each pixel
div_matrix = conv2(ones(ndim(1:2)),ones(spatial_extent),'same'); div_matrix = ndim(3)*div_matrix; 

for layer_num = 1:nfilters
    layer_sum(:,:,layer_num) = conv2(img_in(:,:,layer_num),spatial_win,'same');
    layer_square(:,:,layer_num) = conv2(square_img(:,:,layer_num),spatial_win,'same');
end

total_sum = sum(layer_sum,3);
avg_matrix = total_sum./div_matrix; % this is the average of the neighbors to be subtracted from img_in

img_out = img_in - repmat(avg_matrix,[1 1 nfilters]); % subtract the mean of neighbors from the original matrix

euc_norm = sqrt(sum(layer_square,3)); euc_norm(euc_norm<1) = 1; 
euc_norm = repmat(euc_norm,[1 1 nfilters]); 

img_out = img_out./euc_norm; 

return

function gabor_filter = make_gabors
% this function creates Gabor filters of six different spatial frequencies, 
% for each spatial frequency there are 16 orientations spanning 0 to 180 degrees

spf_array = [1/2 1/3 1/4 1/6 1/11 1/18];
step = 180/8; theta_array = 0:step:180-step;
count = 1; filter_size = 43;
for spf = spf_array
    for theta = theta_array
        [Gabor,X,Y] = Create2DGabor(9,spf,theta,0,filter_size);
        Gabor = Gabor - mean(Gabor(:));
        Gabor = Gabor/sqrt(sum(Gabor(:).^2));
        gabor_filter(:,:,count)=Gabor;
        count=count+1;
    end
end

return

function [Gabor,X,Y] = Create2DGabor(sigma,freq,theta,phi,n)
if(~exist('n')) n = 64; end; 
if(~exist('phi')) phi = 0; end;
if(length(sigma)==1), sigma = [sigma sigma]; end;

x=[-n/2+1:n/2]; [X,Y] = meshgrid(x,x);

Grating  = Create2DGrating(freq,theta,phi,n); 
Gaussian = Create2DGaussian(sigma,n); 
Gabor = Gaussian.*Grating; 

return

function [Grating,X,Y] = Create2DGrating(freq,theta,phi,n)
if(~exist('n')) n = 64; end; 
if(~exist('phi')) phi = 0; end;

x=[-n/2+1:n/2]; [X,Y] = meshgrid(x,x);
slant = X*(2*pi*freq*cos(theta*pi/180)) + Y*(2*pi*freq*sin(theta*pi/180)); 
Grating = cos(slant+phi*pi/180);

return

function [Gaussian,X,Y] = Create2DGaussian(sigma,n)
if(~exist('n')) n = 64; end; 
if(length(sigma)==1) sigma = [sigma sigma]; end;

sigmax = sigma(1); sigmay = sigma(2); 
x=[-n/2+1:n/2]; [X,Y] = meshgrid(x,x);
Gaussian = exp(-(X.^2/(2*sigmax^2) +Y.^2/(2*sigmay^2)));

return