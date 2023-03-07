% seescatterplot  --> see images/pairs on a scatterplot
%
% Required inputs
%    x             = nx1 vector of xdata
%    y             = nx1 vector of ydata
%    imgs           = nx1 or nx2 cell array of images
%
% Example
%         
% Required subroutines --> 

% SP Arun
% ChangeLog: 
%    17 Nov 2016 - SPA/Aakash - first version

function seescatterplot(x,y,imgs)

figure('Position',[200 200 900 400]); 
nimg = numel(imgs); npts = length(x); flag = 1; 
while flag
    subplot(121); corrplot(x,y,[],1); 
    title('Select point to see image, press Enter to stop'); 
    % get user crosshairs and closest point
    [xsel,ysel] = ginput(1); clf; flag=0; 
    if(~isempty(xsel))
        flag=1; 
        [~, qsel] = min(abs(x - xsel)+abs(y - ysel)); % find point with closest L1 distance
        if(any(size(imgs)==2))
            im1 = imgs{qsel,1}; m1 = max(size(im1));
            im2 = imgs{qsel,2}; m2 = max(size(im2));
            m = max([m1 m2]); im = [padimg(im1,m) padimg(im2,m)];
        else
            im = imgs{qsel};
        end
        subplot(122); imshow(im); axis image; title(sprintf('ID = %d, x = %2.2g, y = %2.2g',qsel,x(qsel),y(qsel)));
        subplot(121); hold on; plot(x(qsel),y(qsel),'o','MarkerSize',10); 
    end
end
close; 

return