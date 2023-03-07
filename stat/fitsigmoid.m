% fitsigmoid -> fit sigmoid to data given by (x,y)
% [b,ypred] = fitsigmoid(x,y,b0); 
% Required inputs
%    x             = x data points
%    y             = y data points
% Optional inputs
%    b0            = initial guess at sigmoid parameters 
%                    If no input is supplied, the guess is [max(y) mean(x) std(x)]
% Outputs:
%    b             = sigmoid parameters:
%                    b(1) = amplitude
%                    b(2) = mean of sigmoid (i.e., x-value at half height)
%                    b(3) = sigma (controls rate of rise)
%    ypred         = best-fit values
% Notes
%    Sigmoid = A*normcdf(x,mu,sigma)

%  Arun Sripati
%  6/11/2008

function [b,ypred] = fitsigmoid(x,y,b0) 

if(~exist('b0'))
    b0 = [max(y) mean(x) std(x)];
end

options = statset('nlinfit'); options.MaxIter = 1000; options.Display = 'off'; 
b = nlinfit(x,y,@sigmoid,b0,options); 
ypred = sigmoid(b,x); 

if(0)
    plot(x,y,'.'); hold all; 
    plot(x,ypred,'.'); 
    legend('observed','predicted'); 
end

return
