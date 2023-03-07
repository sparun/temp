% simplot         -> visualize similarity relations between images
% [c,p] = simplot(data,imgs,plot_size)
% Required inputs
%    data          = nimgs x ncells vector of firing rates
%                              OR 
%                    npairs x 1 vector of pair-wise distances between imgs
%                         where npairs = nchoosek(nimgs,2)
%    imgs          = nimgs x 1 cell array of images
% Optional inputs:
%    plot_size     = size of plot (default = 0.1)
% Outputs:
%    c             = correlation between 2d distances & data
%    p             = p-value indicating significance of correlation
%    Y             = 2d coordinates of each image as returned by MDS
% Method
%    - simplot takes either a set of firing rates OR a set of pair-wise
%        distances, and finds 2D coordinates whose distances match the input
%        distances. By default these 2D coordinates are found using
%        classical multi-dimensional scaling (MDS). 
% Required subroutines --> img_scatterplot

%  SP Arun
%  Revision history
%    May 5 2012 - Original version
%    May 3 2013 - Removed PCA option, and changed to mdscale instead of cmdscale. This is because
%                 mdscale produces less distortion for arbitrary non-Euclidean distances (based on
%                 Pramod's investigations) 

function [c,p,Y] = simplot(data,imgs,plot_size)
if(~exist('plot_size')),plot_size = 0.1; end;
nimgs = length(imgs); npairs = nchoosek(nimgs,2); 

% check whether data is a feature vector or pair-wise distance
if(any(size(data)==nimgs))
    rate = data; if(size(rate,2)==nimgs), rate = rate'; end; 
    dobs = pdist(rate,'cityblock')/size(rate,2); % mean pair-wise distances |r1-r2|
elseif(any(size(data)==npairs))
    dobs = data(:)'; 
else
    error('Error: Mismatch between imgs and data'); 
end

% perform multidimensional scaling
D = squareform(dobs); [Y,e] = mdscale(D,2);

% calculate match between 2d and observed distances
dpred = pdist(Y); [c,p]=nancorrcoef(dobs,dpred);

% create a scatterplot with the 2d coordinates and images beside them
titlestr = sprintf('MDS, Match with data: r = %0.2f (p = %3.2g)',c,p);
img_scatterplot(Y(:,1),Y(:,2),imgs,plot_size,titlestr);

return
