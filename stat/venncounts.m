% venncounts      -> take two sets of p-values and return the co-occurrence counts
% [counts,pvalue,predcounts]  = venncounts(p1,p2,criterion)
% Required inputs
%    p1            = p-values of first factor
%    p2            = p-values of second factor
% Optional inputs:
%    criterion     = significance criterion (default = 0.05)
% Outputs:
%    counts        = 2x2 matrix containing number of instances as: [YY YN; NY NN]
%                         where the first Y/N refers to the first factor and second to second factor. 
%    pvalue        = output of chi2test, indicating whether the two effects 
%                        are distributed independently
%    predcounts    = 2x2 matrix containing expected number of instances in the same format as counts
%
% Example
%    Suppose you analyzed each neurons' response for two possible effects, 
%    say shape and texture. Each analysis gives you a p-value. You want to know how many neurons
%    show a co-occurrence (or not) of each effect. venncounts will return a matrix which contains: 
%    [shapeY,textureY shapeY,textureN; shapeN,textureY shapeN,textureN]
%
%    In addition you may be interested in knowing whether these two effects of shape and texture 
%    are independently distributed across neurons or not. The p-value returned by venncounts
%    represents the probability that the observed counts could have been obtained from an
%    independent distribution of these two properties. Thus if the p-value is low, it means that 
%    neurons that are selective for shape tend also to be selective for texture. These two
%    properties are NOT distributed independently. 
%
% Required subroutines --> chi2test

%  SP Arun
%  26 Sep 2012

function [counts,pvalue,predcounts] = venncounts(p1,p2,criterion)
if(~exist('criterion')), criterion = 0.05; end; 
dispflag=1; if(nargout>0), dispflag = 0; end;
xname = inputname(1); yname = inputname(2); 
if(isempty(xname)),xname='x';end; if(isempty(yname)),yname='y';end; 

YY = length(find(p1<=criterion & p2<=criterion)); 
YN = length(find(p1<=criterion & p2>criterion)); 
NY = length(find(p1>criterion & p2<=criterion)); 
NN = length(find(p1>criterion & p2>criterion)); 

counts = [YY YN; NY NN]; 
[pvalue,predcounts] = chi2test(counts); 

if(dispflag)
    fprintf('----- venncounts.m ----- \n'); 
    fprintf('Observed overlap between %s and %s (criterion = %2.2f) \n',xname,yname,criterion); 
    fprintf('[YY YN NY NN] = [%d %d %d %d] \n',counts(:));
    fprintf('Predicted distribution if counts are independent \n'); 
    fprintf('[YY YN NY NN] = [%2.1f %2.1f %2.1f %2.1f] \n',predcounts(:));
    fprintf('p-value of chi2test between obs and pred counts: p = %2.2g \n',pvalue); 
end

return
