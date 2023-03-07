% modindex          -> compute modulation index (A-B)./(A+B)
%% M = modindex(A,B); 
%% Required inputs
%%    A             = matrix of A values
%%    B             = matrix of B values
%% Outputs:
%%    M             = modulation index (A-B)./(A+B); 

%  Arun Sripati
%  Date: January 16, 2007

function M = modindex(A,B); 
M = (A-B)./(A+B); 
return