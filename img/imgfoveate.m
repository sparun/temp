% imgfoveate        --> create image with foveal blur
% 
% Required inputs
%    imgin         = input image (grayscale or color) 
% Optional inputs:
%    fovx          = x coordinate of where to foveate in the image (default: img center) 
%    fovy          = y coordinate of where to foveate in the image (default: img center) 
%    decayfactor   = decay factor relative to human peripheral blur 
%                    1  = same as humans (default) 
%                    >1 = more blur than humans
%                    <1 = less blur than humans
%    viewingdist   = viewing distance in m assumed for peripheral blur (default = 1.2 m) 
%    pyrlevels     = number of pyramid levels to use (default = 7) 
% Outputs:
%    imgout        = Foveated image
% Method
%    imgfoveate creates a foveated image based on Gaussian multiresolution pyramid. Uses formula from
%    Geisler and Perry (1998) to determine spatial dropoff around a point of gaze.
% Notes
%    Foveation as it is implemented in the script works on real-world distances and not in pixel
%    units. For example, a 100x100 image may appear bigger on a monitor with a bigger pixel size (or
%    higher dot pitch) in which case a pixel which is on the edge of the image will be blurred more
%    (because it is now physically far from the point of fixation assuming central fixation) than if
%    it was instead presented on a monitor with smaller dot pitch. Therefore you have to change dot
%    pitch according to the monitor being used (default = .233*(10^-3)). 
% References
%    Pramod RT, Katti H & Arun SP (2022) Human peripheral blur is optimal for object recognition,
%    Vision Research, 200: 108083
% Required subroutines --> matlabPyrTools (from Simoncelli) 

% ChangeLog: 
%    20 Oct 2022     PramodRT & Harish Katti      First version
%     1 Dec 2022     SP Arun                       Incorporated into lib

function imgout = imgfoveate(imgin,fovx,fovy,decayfactor,viewingdist,pyrlevels)

% set defaults
if(~exist('fovx')||isempty(fovx)), fovx = floor(size(imgin,1)/2); end 
if(~exist('fovy')||isempty(fovy)), fovy = floor(size(imgin,2)/2); end
if(~exist('spatialdecayfactor')||isempty(decayfactor)), decayfactor = 1; end
if(~exist('pyrlevels')||isempty(pyrlevels)), pyrlevels = 7; end
if(~exist('viewingdist')||isempty(viewingdist)), viewingdist = 1.2; end; % viewing distance in m

CT0 = 1/75; 				          % constant from Geisler&Perry
alpha = (0.106)*1*decayfactor;        % constant from Geisler&Perry
epsilon2 = 2.3; 			          % constant from Geisler&Perry
dotpitch = .233*(10^-3);              % monitor dot pitch in meters (for DELL S2240L)

% read file and store statistics from it
color_img = double((imgin))/255;

% normalize the values to some maximum value; for most MATLAB functions, this value must be one.
max_cval = 1.0;
range = [min(color_img(:)) max(color_img(:))];
img_size = size(color_img(:,:,1));
color_img = max_cval.*(color_img-range(1)) ./ (range(2)-range(1));

% ex and ey are the x- and y- offsets of each pixel compared to
% the point of focus (fovx,fovy) in pixels.
[ex, ey] = meshgrid(-fovx+1:img_size(2)-fovx,-fovy+1:img_size(1)-fovy);

% eradius is the radial distance between each point and the point
% of gaze.  This is in meters.
eradius = dotpitch .* sqrt(ex.^2+ey.^2);

% calculate ec, the eccentricity from the foveal center, for each
% point in the image.  ec is in degrees.
ec = 180*atan(eradius ./ viewingdist)/pi;

% maximum spatial frequency (cpd) which can be accurately represented onscreen:
maxfreq = pi ./ ((atan((eradius+dotpitch)./viewingdist) - ...
    atan((eradius-dotpitch)./viewingdist)).*180);

% calculate the appropriate (fractional) level of the pyramid to use with
% each pixel in the foveated image.

% eyefreq is a matrix of the maximum spatial resolutions (in cpd)
% which can be resolved by the eye
eyefreq = ((epsilon2 ./(alpha*(ec+epsilon2))).*log(1/CT0));

% pyrlevel is the fractional level of the pyramid which must be
% used at each pixel in order to match the foveal resolution
% function defined above.
pyrlevel = maxfreq ./ eyefreq;

% constrain pyrlevel in order to conform to the levels of the
% pyramid which have been computed.
pyrlevel = max(1,min(pyrlevels,pyrlevel));

% show the foveation region matrix:

% create storage for our final foveated image
imgout = zeros(img_size(1),img_size(2),size(color_img,3));

% create matrices of x&y pixel values for use with interp3
[xi,yi] = meshgrid(1:img_size(2),1:img_size(1));

% we'll need to do the foveation procedure 3 times; once for each
% of the three color planes.
for color_idx = 1:size(color_img,3)
    img = color_img(:,:,color_idx);
    
    % build Gaussian pyramid
    [pyr,indices] = buildGpyr(img,pyrlevels);
    
    % upsample each level of the pyramid in order to create a
    % foveated representation
    point = 1;
    blurtree = zeros(img_size(1),img_size(2),pyrlevels);
    for n=1:pyrlevels
        nextpoint = point + prod(indices(n,:)) - 1;
        show = reshape(pyr(point:nextpoint),indices(n,:));
        point = nextpoint + 1;
        blurtree(:,:,n) = ...
            imcrop(upBlur(show, n-1),[1 1 img_size(2)-1 img_size(1)-1]);
    end
    
    clear pyr indices;
    clear show;
    
    % create foveated image by interpolation
    imgout(:,:,color_idx) = interp3(blurtree,xi,yi,pyrlevel, '*linear');
end

end
