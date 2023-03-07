% binomialtest    -> test whether binomial counts match a particular probability
% Required inputs
%    nH            = number of heads
%    n             = total number of coin tosses
%    pchance       = expected coin toss probability
% Outputs:
%    p             = probability of observing a deviation larger than observed 
%                    given the chance distribution
% Method
%    Suppose you got nH heads from n coin tosses. What is the probability
%    that you get more/less than this number of heads given the chance binomial
%    distribution? If nH is expected given 
%                    i.e. p(k>=nH) if nH >= expected
%                         p(k<=nH) if nH <= expected

% Notes
% 
% Required subroutines --> NONE

% Credits: SPArun
% ChangeLog: 
%    7 Apr 2020 - SPA     - first version

function p = binomialtest(npos,n,pchance)
nexp = n*pchance; 

if(npos>=nexp)
	p = 1 - binocdf(npos-1,n,pchance);
else
	p = binocdf(npos,n,pchance); 
end

return

%% debug
n = 100; 
for npos = 1:n
	p(npos) = binomialtest(npos,n,0.75); 
end
figure; plot(p,'k+-'); 