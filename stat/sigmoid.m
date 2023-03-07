% sigmoid -> transfoms the input data using a sigmoid activation function
% ys = sigmoid(b,x); 
% Required inputs
%    b             = sigmoid parameters:
%                    b(1) = amplitude
%                    b(2) = mean of sigmoid (i.e., x-value at half height)
%                    b(3) = sigma (controls rate of rise)
%    x             = x data points
% Outputs
%    ys            = output of sigmoid

% Arun Sripati
% 6/11/2008

function ys = sigmoid(b,x)

A = b(1); mu = b(2); sigma = b(3); 
ys = A*normcdf(x,mu,sigma); 

return
