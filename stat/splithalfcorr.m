% splithalfcorr   --> calculate split-half consistency in behavioral/neuronal data
% [cavg,ci,pavg,pmax] = splithalfcorr(data,dim,niter,diagflag)
% Required inputs
%    data          = nsubj x nconditions x (....) matrix of data (default) 
%                    nconditions x nsubj x (....) matrix of data
% Optional inputs:
%    dim           = dimension along which to do splithalf (default = 1, else specify 2) 
%    niter         = number of split-half samples to draw (default = 100)
% Outputs:
%    cavg          = average correlation between split halves of the data
%    ci            = estimated split-half on each random iteration
%    pavg          = average p-value across iterations
%    pmax          = least significant p-value across iterations
% Example
%    Say you have RTs from a psych experiment of dimension nsubjects x nconditions.
%    splithalfcorr will randomly split the subjects into two groups and calculate the mean
%    correlation between the average RT of the two groups. This is done a number of times and the
%    function returns the average split-half correlation and average and least significant p-value
%    obtained across reps
% Required subroutines --> nancorrcoef

% ChangeLog: 
%    12/03/2013   Arun       First version
%    12/07/2018   Arun       Made iterations sample with replacement for unbiased estimates
%                              also reordered output arguments from cavg,pavg,pmax,cstd
%    02/12/2022   Arun       Added functionality to average across all other extra dimensions 

function [cavg,ci,pavg,pmax] = splithalfcorr(data,subjectdim,niter,repflag,diagflag)
if(~exist('subjectdim')),subjectdim = 1; end
if(~exist('niter')),niter = 100; end % 100 iterations by default
if(~exist('repflag')), repflag = 0; end
if(~exist('diagflag')),diagflag = 0; end
data = permute(data,[subjectdim setdiff([1:ndims(data)],subjectdim)]); % shuffle the data so that subjects are the first dimension
if(ndims(data)>=3), data = nanmean(data,[3:ndims(data)]); end % average across any extra dimensions (e.g. reps)

nsubj = size(data,1); ncond = size(data,2);
nhalf = floor(nsubj/2);

for iter = 1:niter
    if(repflag), x = randsample(nsubj,nsubj,1); else x = randperm(nsubj); end
    q1 = x(1:nhalf); q2 = x(nhalf+1:end);
    m1 = nanmean(data(q1,:),1);
    m2 = nanmean(data(q2,:),1);
    [ci(iter,1),pi(iter,1)] = nancorrcoef(m1,m2);
end

if(diagflag)
    figure; corrplot(m1,m2,[],1); 
end

cavg = nanmean(ci); % average correlation between split halves
pmax = max(pi,'omitnan'); % least significant p-value obtained (alternatively it could be mean(pi))
pavg = nanmean(pi);
if(repflag), repstr = 'with'; else repstr = 'without'; end
if(nargout==0)
    fprintf('%s (%d reps), sampled %s replacement: ravg = %2.2f (pavg = %2.2g) \n',inputname(1),nsubj,repstr,cavg,pavg); 
end

return
