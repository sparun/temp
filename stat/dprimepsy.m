% dprimepsy -> Calculate dprime using Hit and False Alarm rates
% d = dprimepsy(H,FA,nsamples)
% Required inputs
%    H            = probability of correct detection (hit)
%    FA           = probability of false alarm 
% Optional inputs
%    nsamples     = number of trials/samples used to calculate H & FA
% Outputs:
%    dprime       = dprime measure of discriminability 
%    bias         = response bias 
%                      bias>0 => subjects tried to minimize FA at the expense of M
%                      bias<0 => subjects tried to minimize M at the expense of FA  
% Method
%    dprime is calculated as z(H) - z(FA)
%    bias is calculated as -0.5*(z(H)+z(FA))
% References
%    http://people.brandeis.edu/~sekuler/stanislawTodorov1999.pdf

% Version Log
%   30 Oct 2014 (SPA) First created
%   18 Dec 2014 (SPA) Included bias & added small-sample correction

function [dprime,bias] = dprimepsy(H,FA,nsamples)

if(exist('nsamples'))
    q = find(H==1); H(q) = H(q) - 1/(2*nsamples); 
    q = find(H==0); H(q) = H(q) + 1/(2*nsamples); 
    q = find(FA==0); FA(q) = FA(q)+1/(2*nsamples); 
    q = find(FA==1); FA(q) = FA(q)-1/(2*nsamples); 
end

dprime = norminv(H,0,1)-norminv(FA,0,1);
bias   = -0.5*(norminv(H,0,1) + norminv(FA,0,1));

return