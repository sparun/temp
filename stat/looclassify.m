% looclassify     -> linear classification with a leave-one-out cross-validation
% Required inputs
%    data         = rows are observations, columns are features
%    classlabels  = vector of class labels for each row
% Optional inputs
%    pcthresh     = if provided, projects the data along its principal components and selects the
%                   pcs that account for "pcthresh" fraction of total variance.
%    classifiertype = type of classifier to use (default = linear)
% Outputs
%    class        = predicted class labels
%    pc           = overall percent correct
%    pcm          = 2x2 percent correct matrix containing 
%                   [Hits Misses;
%                    FalseAlarms CorrectRejections]; 
% SP Arun
%    Version history
%       10/4/2013: First created
%        2/9/2013: updated to include percent corrects

function [class,pc,pcm] = looclassify(data,classlabels,pcthresh,classifiertype)
if(~exist('pcthresh')||isempty(pcthresh)), pcaflag = 0; else pcaflag = 1; end; 
if(~exist('classifiertype')), classifiertype = 'linear'; end; 

if(pcaflag)
	[data,npc] = pcaproject(data,pcthresh); 
end

nobs = size(data,1); 
for testid = 1:nobs
	qtrain = setdiff([1:nobs],testid); 
	test = data(testid,:); train = data(qtrain,:); labelsp = classlabels(qtrain); 
	s1 = sum(train,1); q = find(s1==0); train(:,q) = []; test(q) = []; % remove neurons with zero firing rates
	class(testid,1) = classify(test,train,labelsp,classifiertype); 
end
pc = length(find(class==classlabels))/length(classlabels);

pcm = []; ulabels = unique(labelsp); 
if(length(ulabels)==2) % i.e. only two class labels
    CR = length(find(class==ulabels(1)&classlabels==ulabels(1)))/length(find(classlabels==ulabels(1))); 
    H  = length(find(class==ulabels(2)&classlabels==ulabels(2)))/length(find(classlabels==ulabels(2))); 
    FA = length(find(class==ulabels(2)&classlabels==ulabels(1)))/length(find(classlabels==ulabels(1))); 
    M  = length(find(class==ulabels(1)&classlabels==ulabels(2)))/length(find(classlabels==ulabels(2))); 
    pcm = 100*[H M; FA CR]; 
end

return
