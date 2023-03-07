% svdinv            --> Return the generalized SVD inverse of a matrix
% Cinv = svdinv(C,cutoff);
% Required inputs
%    C             = matrix to find inverse
%    cutoff        = min singular value magnitude to retain (default = 0.005)
% Outputs:
%    Cinv          = SVD inverse of matrix C. 
% Method
%    Uses the SVD function in matlab. The cutoff is the magnitude of the smallest singular value
%    that is retained (expressed as a percent of the largest singular value)

% Arun Sripati
% 12/18/2003

function [Cinv,cutoffidx] = svdinv(C,cutoff,flag_fig);
if(~exist('cutoff')) cutoff = 0.005; fprintf('svdinv: cutoff = %3g \n',cutoff); end
if(~exist('flag_fig')) flag_fig = 0; end; 

Nd = size(C,1);
[U S V] = svd(C);
q = diag(S);
cutoffidx = max(find(q>=cutoff*q(1)));
Cinv = V*diag([1./q(1:cutoffidx);zeros(Nd-cutoffidx,1)])*U';

if(flag_fig)
    loglog(diag(S)/S(1,1)); 
end

return