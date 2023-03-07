%chi2test         --> perform a chi-squared test on counts with a yates correction
% [p,pred] = chi2test(obs)
% Required inputs
%    obs           = vector of observed counts of effects
% Optional inputs
%    pred          = vector of predicted or expected counts 
% Outputs:
%    p             = p-value of chi2 test
%    pred          = predicted counts
%    df            = degrees of freedom (num of observations - 1) 
% Notes
%    This yields the same p-values as Carl's Excel formula

%  Arun Sripati
%  4/10/2008

function [p,pred,df,chi2stat] = chi2test(obs,pred)

if(~exist('pred'))
    % if obs is a matrix of counts in two different conditions,
    % e.g. counts of x>y and x<=y in two conditions,
    % then expected counts are based on independent distribution of the counts
    if(~isvector(obs))
        pn = sum(obs,1); pn = pn/sum(pn); ps = sum(obs,2); ps = ps/sum(ps);
        pred = sum(obs(:))*ps*pn; % expected counts based on independent variables
    else
        pred = [0.5 0.5]*sum(obs); pred = reshape(pred,size(obs));
    end
end
df = length(pred)-1; 

chi2stat = sum(sum((abs(obs-pred) - 0.5).^2./pred)); % chi2stat with yates correction
p = gammainc(chi2stat/2,df/2,'upper'); % p value line is from chi2gof.m

if(nargout==0)
    fprintf('observed = [%d %d], predicted = [%2.1f %2.1f], chi2stat = %2.1f, p = %2.2g \n',obs(1),obs(2),pred(1),pred(2),chi2stat,p); 
end

return