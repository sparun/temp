% aicc -> calculate corrected AIC for a model given pred, obs and npars

% Reference: McMahon and Olson, JNeurophys, 2009

% Pramod & Arun
% June 27 2013

function [am,as,ba] = aicc(pred,obs,npars)

am = calculateaic(pred,obs,npars); % mean AIC 

% get bootstrap-derived estimate of standard deviation of AIC
% with nboot equal to the number of samples in the data
ba = bootstrp(length(pred),@calculateaic,pred,obs,npars); 
as = std(ba); 

return


function am = calculateaic(pred,obs,npars)

n = length(pred); 
sse = sum((pred-obs).^2); 
am = n*log(sse/n) + (2*npars) + (2*npars*(npars+1)/(n-npars-1));

% am = n*log(sse/n) + npars*log(n); % use this for BIC 

return