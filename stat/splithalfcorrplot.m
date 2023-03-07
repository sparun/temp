% splithalfcorrplot --> make a split-half plot for data
% splithalfcorrplot(data,dim)
% Required inputs
%    data          = nreps x nconditions matrix of data
% Optional inputs:
%    dim           = dimension along which to do splithalf
% Output
%    corrplot between odd and even numbered reps of the data 
% Required subroutines --> corrplot

% ChangeLog: 
%    17/11/2020 - Arun       - first version

function [dataodd,dataeven] = splithalfcorrplot(data,dim,figflag,titlestr,linespec)
if(~exist('dim')),dim=1; end
if(dim==2), data = data'; end
if(~exist('figflag')), figure; end
xname = inputname(1); 
if(~exist('titlestr')), titlestr = sprintf('Split-half plot for %s',xname); end
if(~exist('linespec')), linespec = ''; end

dataodd = nanmean(data(1:2:end,:),1); 
dataeven = nanmean(data(2:2:end,:),1); 
corrplot(dataodd,dataeven,titlestr,1,linespec); 

return
