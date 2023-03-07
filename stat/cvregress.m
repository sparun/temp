% cvregress        -> cross-validated regression
% Required inputs
%    y             = quantity to be predicted
%    X             = regressors
%    nfold         = number of splits of the data to perform 
%                    for leave-one-out, set nfold = Inf
% Outputs:
%    ypred         = predicted y after nfold crossvalidation 
% Method
%    cvregress performs cross-validated regression. For 5-fold
%    cross-validation, it splits the data randomly into 5 parts, and for 
%    each part, gets the prediction after training the model on the 
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
%    5 Apr 2020   SPArun   first version

function ypred = cvregress(y,X,nfold)
looflag = 0; if(nfold==Inf),looflag = 1; end

n = length(y); setids = [1:n];
if(~looflag),nperset = floor(n/nfold); pc = [0:nperset:n]; pc(end) = n; end
if(looflag),pc = [0 setids]; end; 

x = randperm(n); 
for pcid = 1:length(pc)-1
	testids = setids(pc(pcid)+1:pc(pcid+1)); 
	qtest = x(testids); qtrain = setdiff(x,qtest); 
	b = regress(y(qtrain),X(qtrain,:)); 
	ypred(qtest,1) = X(qtest,:)*b; 
	yobs(qtest,1) = y(qtest); 
end

if(sum(abs(yobs-y))~=0),error('some partition problem'); end

return