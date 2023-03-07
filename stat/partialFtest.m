%partialFtest      --> Perform the partial F test to compare full and reduced models
% p = partialFtest(robs,rpred_full,rpred_red,nfull,nred); 
% Required inputs
%    robs          = observed data (n x 1 vector)
%    rpred_full    = prediction of the full model
%    rpred_red     = prediction of the reduced model
%    nfull         = number of parameters in the full model
%    nred          = number of parameters in the reduced model
% Outputs:
%    p             = probability that the full model and the reduced model are equivalent
% Example: see below

%  SP Arun
%  Date: October 10, 2007

function [p,F] = partialFtest(robs,rpred_full,rpred_red,nfull,nred)

ss_full = sum((rpred_full-robs).^2);
ss_red  = sum((rpred_red -robs).^2);
ndata = length(robs);
df_full = ndata - nfull; df_red = ndata - nred; df_frac = (df_red-df_full)/df_full;
F = ((ss_red-ss_full)/ss_full)/df_frac;
p = 1 - fcdf(F,df_red-df_full,df_full);

return

%% TESTING
allclear; 
x = [-1:0.01:1];
robs = 0.2*randn(size(x))+polyval(randn(5,1),x); 
xfull = polyfit(x,robs,6);
xred = polyfit(x,robs,5);
rpred_full = polyval(xfull,x);
rpred_red = polyval(xred,x);
[p,F] = partialFtest(robs,rpred_full,rpred_red,length(xfull),length(xred));
plot(x,robs,x,rpred_full,'r',x,rpred_red,'k'); 
legend('data','full model','reduced model'); 
title(sprintf('F-test p = %0.3g, F = %3.3g',p,F)); 
