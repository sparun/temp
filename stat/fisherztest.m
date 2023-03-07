%fisherztest         --> statistical comparison of two correlation coefficients
% p = fisherztest(r1,n1,r2,n2); 
% Required inputs
%    r1            = correlation coefficient 1
%    n1            = number of samples used for calculation of corrcoef1
%    r2,n2         = corresponding numbers for correlation coefficient 2
% Outputs:
%    p             = p-value (probability that two correlations are equal)
%    z             = corresponding z-score
% References
%    Apparently Fisher was the first to formulate this problem.
%    http://core.ecu.edu/psyc/wuenschk/docs30/CompareCorrCoeff.docx

%  S P Arun
%  10/12/2011

function [p,z] = fisherztest(r1,n1,r2,n2)

% transform corrcoefs into a normal distribution
r1p = 0.5*log((1+r1)/(1-r1)); 
r2p = 0.5*log((1+r2)/(1-r2)); 

z = abs(r1p-r2p)/sqrt(1/(n1-3) + 1/(n2-3));  % z-score
p = 2*(1-normcdf(z)); % two-tailed

return
