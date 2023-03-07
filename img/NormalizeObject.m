%NormalizeObject -> zooms and shifts an object into a constant frame
% Xnorm = NormalizeObject(X,longdim,framesize,[shiftflag zoomflag],diagflag)
% Required inputs
%    X             = input image (2d or 3d)
% Outputs:
% Method
%    NormalizeObject zooms and shifts an object to a constant frame using 
%    the following steps: 
%    1) Threshold all low-intensity pixels to zero. 
%    2) Remove all zero rows and columns on either side of the object
%    3) Scale up/down the object so that its longer dimension is longdim
%    4) Shift the center of mass to the centre of the frame
%    5) Pad with zeros till the total frame = framesize x framesize
% Required subroutines --> NormalizeObject, RemoveZeros, padimg

% SP Arun
%   First created June 5 2008
%   Created as lab\lib Dec 19 2012

function Xnorm = NormalizeObject(X0,longdim,framesize,shiftflag,zoomflag,zerothresh,diagflag)
if(~exist('shiftflag')|isempty(shiftflag)) shiftflag = 1; end; 
if(~exist('zoomflag')|isempty(zoomflag)) zoomflag = 1; end; 
if(~exist('zerothresh')), zerothresh = 0; end; 
if(~exist('diagflag')|isempty(diagflag)) diagflag = 0; end; 

X = sum(X0,3)/3; % convert to 2-d array
X(X<=zerothresh*max(X(:))) = 0; % threshold image at zerothresh relative to max
X = removezeros(X); % remove zero columns/rows at the beginning or end of image

if(zoomflag)
    aspectratio = min(size(X))/max(size(X)); % min/max
    % zoom
    if(max(size(X))== size(X,1)) % if longer dimension is 1
        X = imresize(X,[longdim longdim*aspectratio]);
	else % if longer dimension is 2
        X = imresize(X,[longdim*aspectratio longdim]);
    end
end

% pad array to desired size
X = padimg(X,framesize); 

if(framesize>longdim & shiftflag == 1)
    % calculate center of mass and shift so that image is at center
    row = sum(X,2); cogx = sum(row.*[1:length(row)]')/sum(row); shiftx = round(framesize/2 - cogx);
    col = sum(X,1); cogy = sum(col.*[1:length(col)])/sum(col); shifty = round(framesize/2 - cogy);
    X = circshift(X,[shiftx shifty]);
end

% normalize pixels of X so that they have the same total intensity as X0
Xnorm = X*sum(X0(:))/sum(X(:)); 

% --- diagnostics ---------
if(diagflag)
    figure;
    subplot(211); 
    imagesc(X0); axis image; colormap gray; 
    title('Original'); 
    subplot(212);
    imagesc(X); axis image; colormap gray;
    title('Normalized Object'); 
end

return
