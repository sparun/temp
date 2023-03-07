% cvclassify       -> cross-validated classification
% Required inputs
%    data          = nobs x nfeatures matrix of data
%    labels        = nobs x 1 vector of numeric class labels for the data
%    nfold         = number of splits of the data to perform 
%                    for leave-one-out, set nfold = Inf
% Outputs:
%    predlabels    = predicted class labels after n-fold cross-validation
% Method
%    cvclassify performs cross-validated regression. For 5-fold
%    cross-validation, it splits the data randomly into 5 parts, and for 
%    each part, gets the predicted labels after training the classifier on the 
%    remaining parts, and concatenates all the predictions. For example, 
%    the predictions for the 1st part are based on training on the 
%    parts 2-5. Predictions for part 2 are based on training parts 
%    1,3,4,5. Etc. 
% Notes
%    - The output will differ each time because the function does a random
%      partition of the data into nfolds each time you run it. 
%    - The last partition will have extra elements if the number of
%      observations is not perfectly divisible by nfold :) 
% Required subroutines --> NONE
% ChangeLog: 
%    7 Apr 2020   SPArun   first version

function [predlabels, pc] = cvclassify(data,labels,nfold,classifiertype)
looflag = 0; if(nfold==Inf),looflag = 1; end

n = length(labels); setids = [1:n];
if(~looflag),nperset = floor(n/nfold); pc = [0:nperset:n]; pc(end) = n; end
if(looflag),pc = [0 setids]; end; 

x = randperm(n); 
for pcid = 1:length(pc)-1
	testids = setids(pc(pcid)+1:pc(pcid+1)); 
	qtest = x(testids); qtrain = setdiff(x,qtest); 	
	predlabels(qtest,1) = classify(data(qtest,:),data(qtrain,:),labels(qtrain),classifiertype); 
end

pc = length(find(predlabels==labels))/length(labels); 

return