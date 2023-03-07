% splithalfcorrd   --> a simple hack of splithalfcorr to use RT data to get splithalf correlation on 1/RTs
% [cavg,ci,pavg,pmax] = splithalfcorrd(data)
% Required inputs
%    data          = nreps x nconditions matrix of RT data
% Optional inputs:
%    niter         = number of split-half samples to draw (default = 100)
% Outputs:
%    cavg          = average correlation between split halves of the dissimilarities
%    ci            = estimated split-half on each random iteration
%    pavg          = average p-value across iterations
%    pmax          = least significant p-value across iterations
% Example
%    Say you have RTs from a psych experiment of dimension nsubjects x nconditions.
%    splithalfcorrd will randomly split the subjects into two groups and calculate the mean
%    correlation between the average 1/RT of the two groups. This is done a number of times and the
%    function returns the average split-half correlation and average and least significant p-value
%    obtained across reps
% Required subroutines --> nancorrcoef

% ChangeLog: 
%    30/10/2015 - Pramod     - first version
%    12/07/2018 - Arun       - made iterations sample with replacement for unbiased estimates
%                              also reordered output arguments from cavg,pavg,pmax,ci

function [cavg,ci,pavg,pmax] = splithalfcorrd(data,niter,diagflag)
if(~exist('niter')),niter = 100; end % 100 iterations by default
if(~exist('diagflag')),diagflag = 0; end
if(size(data,3)>1),error('Input should be a 2d matrix'); end

nreps = size(data,1); ncond = size(data,2);
nhalf = floor(nreps/2);

for iter = 1:niter
    %x = randperm(nreps); 
    x = randsample(nreps,nreps,1); 
    q1 = x(1:nhalf); q2 = x(nhalf+1:end);
    m1 = nanmean(data(q1,:),1);
    m2 = nanmean(data(q2,:),1);
    m1 = 1./m1; m2 = 1./m2;
    [ci(iter,1),pi(iter,1)] = nancorrcoef(m1,m2);
end

if(diagflag)
    figure; corrplot(m1,m2,[],1); 
end

cavg = mean(ci); % average correlation between split halves
pmax = max(pi); % least significant p-value obtained (alternatively it could be mean(pi))
pavg = mean(pi);
if(nargout==0)
    fprintf('%s (%d reps): ravg = %2.2f (pavg = %2.2g) \n',inputname(1),nreps,cavg,pavg); 
end

return
