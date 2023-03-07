% data = nobs x nfeatures
% 
% Changelog -
%   14 Jun 2018 - Thomas - Replaced 'princomp' with 'pca'(function name updated in Matlab)

function [proj,npc,ve] = pcaproject(data,pcthresh)
if(~exist('pcthresh')), pcthresh = 0.99; end
if(pcthresh>1), npc = pcthresh; end

[~,proj,ev] = pca(data);
cumvar = cumsum(ev/sum(ev)); % cumulative percent variance explained
if(~exist('npc')), npc = min(find(cumvar>pcthresh));end
ve = cumvar(npc); 
proj = proj(:,1:npc);

return