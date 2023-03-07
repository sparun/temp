% manyimagesc       -> view many images contained in a cell array 
% h = manyimagesc(image_array,titles,nx,ny)
% Required inputs
%    image_array   = cell array or a 3d matrix containing images
% Optional inputs
%    titles        = cell/numeric array containing titles for each image
%    nx            = number of subplot rows
%    ny            = number of subplot columns 

%  Changelog
%      5/1/2007 (SPA) First version

% ChangeLog: 
%    05/01/2007 - SPA     - first version
%    24/08/2018 - SPA     - cleaned up, added support for showing subset of images each time

function h = manyimagesc(image_array,titles,nx,ny,nperfig,whiteflag,figh)

% if image_array is 3D or 4D, convert to cell array of images
if(ndims(image_array)==4),image_array = squeeze(mat2cell(image_array,size(image_array,1),size(image_array,2),size(image_array,3),ones(size(image_array,4),1)));end
if(ndims(image_array)==3),image_array = squeeze(mat2cell(image_array,size(image_array,1),size(image_array,2),ones(size(image_array,3),1)));end

% handle defaults
if(~exist('titles')), titles = []; end
if(~exist('nperfig')||isempty(nperfig)), nperfig = length(image_array); end 
if(~exist('nx')||isempty(nx)), nx = ceil(sqrt(nperfig)); end
if(~exist('ny')||isempty(ny)), ny = ceil(nperfig/nx); end
if(~exist('whiteflag')||isempty(whiteflag)), whiteflag = 0; end
if(~exist('figh')), h(1)=figure; else, h(1) = figh; end

imgid = 1; 
while(imgid<=length(image_array))
    clf; 
    for plotid = 1:nperfig
        h(plotid)=subplot(nx,ny,plotid);
        img = image_array{imgid}; if(whiteflag),img = 255-image_array{imgid}; end
        imagesc(img); axis image; colormap gray; axis off; set(gca,'XTick',[],'YTick',[],'FontSize',8);
        
        if(iscell(titles)),   titlestr = titles{imgid}; end
        if(isempty(titles)),  titlestr = sprintf('img %d',imgid); end
        if(isvector(titles)),titlestr = sprintf('img %d, %3.3g',imgid,titles(imgid)); end
        if(isstring(titles)),   titlestr = sprintf('img %d, %s',imgid,titles(imgid)); end
        title(titlestr); 
        
        imgid = imgid+1; 
    end
    if(nperfig<length(image_array)), drawnow; figure; end
end

return