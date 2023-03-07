% NormalizeRates -> Normalize firing rates for each cell by the max firing rate
% raten = NormalizeRates(rate); 
% Required inputs
%    rate          = ncells x nstim matrix of firing rates 
% Optional inputs
%    maxflag       = if 1 (default), divide each cells response by the max firing rate across stimuli
%                    if 0, divide by the mean instead of max
% Outputs:
%    raten         = ncells x nstim matrix of normalized firing rates such that the firing rate of
%                    each cell is divided by its max firing rate across all stimuli 
% Notes
%    

%  SP Arun
%  12/1/2013

function [raten,normfactor] = NormalizeRates(rate,maxflag)
if(~exist('maxflag')),maxflag = 1; end; 

if(maxflag==1)
	normfactor = max(rate,[],2); 
else
	normfactor = nanmean(rate,2); 
end

ncells = size(rate,1); nstim = size(rate,2); 
raten = rate./(normfactor*ones(1,nstim)); 

end