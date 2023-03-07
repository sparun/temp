% plot a bunch of triangle stimuli according to their locations in parameter space. 

% limits of parameter values:
% c < 1, p > 0.5

% S P Arun
% February 14 2011

allclear; 

base = 10; npoints = 9; 
prange = [0.75 2]; pstep = diff(prange)/(npoints-1); pointiness = [prange(1):pstep:prange(2)]; 
crange = [-0.75 0.75]; cstep = diff(crange)/(npoints-1); curvature = [crange(1):cstep:crange(2)]; 

count=1; 
for p = pointiness
    for c = curvature
        Y(count,:) = [c p]; 
        Images{count,1} = CreateCurvedTriangle(base,p,c); 
        count=count+1;
    end
end
%%
figure('Position',[880 89 900 900]); 
plot(Y(:,1),Y(:,2),'.'); v = axis; axis([-0.83 0.83 0.69 2.075]); 
plot_size = 0.1; xy = get_xydata_positions(Y(:,[1,2]));
xlabel(sprintf('Curvature')); ylabel(sprintf('Pointiness'));

xplot_size = plot_size/1.66; yplot_size = plot_size; 
for i=1:size(Y,1)
    axes('Position',[xy(i,1)-0.5*xplot_size xy(i,2)-0.5*yplot_size xplot_size yplot_size]);
    imagesc(Images{i}); axis image off; colormap gray; 
    set(gca,'XTick',[],'YTick',[]);
end
axis off; 
