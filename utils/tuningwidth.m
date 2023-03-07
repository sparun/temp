% tuningwidth -> for each neuron, calculate the min rank at which response drops below criterion
% twidth = tuningwidth(rates, responselevel)
%
% Required Inputs
%    rate          - ncells x nstim firing rates 
%
% Optional Inputs
%    responselevel - fraction of the maximum response at which tuning width
%                    should be computed.  by default, it is calculated at
%                    half max, responselevel = 0.5
%                    0 < responselevel < 1
%
% Outputs
%    twidth        - tuning width for each neuron
%
% Method
%    for each neuron, the firing rates are sorted from best to worst and
%    the tuning width is computed as the number of stimuli at which the
%    response drops to the level specified by responselevel.  by default,
%    the tuning width is computed as the half max width, the point at which
%    the response drop to half of the max.
%
% Zhivago Kalathupiriyan
%
% Change Log:
%    14/07/2014 - ZAK - first version

function twidth = tuningwidth(rates, responselevel)

if ~exist('responselevel'), responselevel = 0.5; end
if isvector(rates), rates = rates(:)'; end
if(responselevel==1), error('responselevel should be less than 1 and greater than 0'); end;

ncells = size(rates,1);
nstim = size(rates,2);
twidth = NaN(ncells,1);

for i = 1:ncells
    sortedrates = sort(rates(i,:), 'descend');
    y = responselevel*sortedrates(1);
    if y ~= 0
        q = find(sortedrates < y);
        if ~isempty(q), twidth(i) = q(1); end;
    end
end
return
