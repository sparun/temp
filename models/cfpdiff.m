% cfpdiff --> calculates the coarse footprint difference between two images
% dcfp = cfpdiff(I,blurfactor,longdim,framesize)
% Required inputs
%    I             = Cell array of images  
%    blurfactor    = sigma of gaussian blur (relative to longer dimension)
% Optional inputs
%    longdim       = Each image is rescaled so that its longer dimension = longdim
%    framesize     = Each image is padded with zeros to fit in a square of side = framesize
% Outputs:
%    dcoarse       = coarse footprint difference between X & Y at the specified blur level
% Method
%
% Required subroutines --> cfp, NormalizeObject, RemoveZeros, Pad

% Changelog
%    17/11/2011 SPA/first version
%    18/12/2012 SPA/created as lab\lib function Dec 18 2012 (SPA)
%    11/ 8/2013 Now calculates all pairwise distances for a cell array of images (Pramod RT)

function dcfp = cfpdiff(I,blurfactor,longdim,framesize)
if (~iscell(I)), error('Input should be a cell array'); end
nimgs = length(I);
if(nimgs<2), error('The input should contain at least two images'); end

for i = 1:nimgs
    image{i,1} = removezeros(I{i}); imsize(i,:) = size(image{i,1});
end
    
if(~exist('longdim')), longdim = max(max(imsize)); end; 
if(~exist('framesize')), framesize = 2*longdim; end; 

% Getting the Coarse footprint of images
fprintf('Calculating coarse footprints for image: \n'); 
for i = 1:nimgs
    fprintf('%d ',i); if(i/20==floor(i/20)),fprintf('\n');end; 
    I = cfp(image{i,1},blurfactor,longdim,framesize); 
    Ic(i,:) = vec(I); 
end
fprintf('...done! \n'); 

dcfp = pdist(Ic,'cityblock'); 

return
