% dprime -> Calculate the individual dprime for neuronal responses to two stimuli
% d = dprime(X1,X2)
% Required inputs
%    X1            = n_trials x n_neurons matrix of neuronal responses to stimulus 1
%    X2            = corresponding matrix for stimulus 2
% Outputs:
%    d             = dprime for each neuron 
% Method:
%    d' is calculated as z(H) - z(FA)
%    To avoid problems when H = 1 or 0, we reduce/increase it by a fraction proportional
%    to the number of samples. 
% Notes
%    I tried to implement a multidimensional case taking into account the entire
%    population. It does not work because in nearly every case in practice, one of the
%    neurons has H = 1 or FA = 0, making the overall dprime = Inf. For the algorithm for 
%    a multidimensional dprime, see below. 

% Arun Sripati
% August 7 2008

function d = dprime(X1,X2)

% compute individual dprimes
nobs = size(X1,1); ncells = size(X1,2); 
group = [ones(nobs,1);2*ones(nobs,1)]; 
for i = 1:size(X1,2)
    if(sum(X1(:,i))==0 & sum(X2(:,i))==0)
        d(i) = NaN; 
    else
        % find H
        class = looclassify([X1(:,i);X2(:,i)],group);
        H = length(find(class==1 & group==1))/length(class);
        % find FA
        class = looclassify([X1(:,i);X2(:,i)],group);
        FA = length(find(class==1 & group==0))/length(class);
        % adjust H & FA in case they are extremes.
        if(H==1), H = H - 1/(2*nobs); end;
        if(H==0), H = H + 1/(2*nobs); end;
        if(FA==0), FA = FA+1/(2*nobs); end;
        if(FA==1), FA = FA-1/(2*nobs); end;
        % calculate dprime
        d(i) = norminv(H,0,1)-norminv(FA,0,1);
    end
end

return; 

% Algorithm for multidimensional dprime -- 
% % 1. compute the best projection 
% S1 = cov(X1); S2 = cov(X2); Sw = S1+S2; 
% w = inv(Sw)*(M1-M2); 
% 
% % 2. project data along w and calculate the dprime 
% y1 = X1*w; y2 = X2*w; 
% % 3. Calculate the dprime based on this
% dprime = abs(mean(y1)-mean(y2))/std(y1); 
