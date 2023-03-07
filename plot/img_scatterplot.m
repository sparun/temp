%img_scatterplot   -> create a scatterplot with images beside each point
% h = img_scatterplot(x,y,images,plot_size,titlestr,symbol,unityflag);
% Required inputs
%    x,y           = x,y values to be used for scatterplot
%    images        = cell array of images corresponding to the (x,y) coordinates
% Optional inputs:
%    plot_size     = size of image beside each (x,y) value (default = 0.1)
%    titlestr      = title for the x,y scatterplot (default = '')  
% Outputs:
%    h             = plot handle for scatterplot
%         
% Required subroutines --> get_xydata_positions

%  SP Arun
%  May 4 2012

function h = img_scatterplot(x,y,images,plot_size,titlestr,symbol,unityflag)
if(~exist('plot_size')|isempty(plot_size)), plot_size = 0.1; end
if(~exist('titlestr')|isempty(titlestr)), titlestr = ''; end
if(~exist('symbol')|isempty(symbol)), symbol = '.'; end
if(~exist('unityflag')), unityflag = 0; end

x = x(:); y = y(:); 
width = plot_size/1.66; height = plot_size;
set(gca, 'Units', 'normalized');
Y = [x y]; plot(x,y,symbol,'markersize', 10); h = gca; title(titlestr); 
xlabel(inputname(1)); ylabel(inputname(2)); 
if(unityflag),unityslope; end
xy = get_xydata_positions(Y(:,[1,2]));
for i=1:size(Y,1)
    if(ischar(images))
        text(Y(i,1),Y(i,2),images(i,:)); 
    else
        axh(i,1) = axes('Position',[xy(i,1) xy(i,2) width height], 'Units', 'normalized');
        imagesc(images{i}); axis image; colormap gray; axis off;
        set(gca,'XTick',[],'YTick',[]);
    end
end
if(exist('axh')), set(zoom(h),'ActionPostCallback',@(xx,yy) update_simplot(Y, axh, width, height));end; 

end

function update_simplot(Y, axh, width, height)
xy = get_xydata_positions(Y);
for i=1:size(Y,1);
    set(axh(i),'Position',[xy(i,1) xy(i,2) width height]);
end
end