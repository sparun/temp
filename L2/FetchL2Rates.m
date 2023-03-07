% FetchL2Rates     -> Fetch average firing rate for each stimulus in a specified time window
% Required inputs
%    L2orspikes    = L2 structure or cell array {ncellsx1}{nstimx1}{1xntrials} of spikes 
%    t1,t2         = start and end of spike window to be used
% Optional inputs
%    qcells        = indices of neurons to use
%                    defaults:
%                    for L2 input: L2_str.qvisual if present or all neurons
%                    for spikes input: all neurons
% Outputs:
%    rate_all      = ncells x nstim matrix of firing rates (spikes/s)
% Method
%    FetchL2Rates gets the average firing rates across all available trials
%    for each neuron and each stimulus in an L2_str

% SP Arun
% ChangeLog:
%    05/01/2007 - first version
%    02/06/2012 - removed spontaneous firing rates and added documentation
%    18/04/2015 - removed spont period & modified to run only on visual neurons
%    15/12/2015 - updated to work with L2 or spikes

function rate_all = FetchL2Rates(L2orspikes,t1,t2,qcells)

if ~iscell(L2orspikes)
    L2spikes = L2orspikes.spikes;
    if ~exist('qcells')
        if(isfield(L2orspikes,'qvisual'))
            qcells = L2orspikes.qvisual(:)';
        else
            qcells = [1:length(L2orspikes.neuron_id)];
        end
    end
else
    L2spikes = L2orspikes;
    if ~exist('qcells')
        qcells = 1:length(L2orspikes);
    end
end

count=1;
for cell_id = vec(qcells)'
    nstim = length(L2spikes{cell_id});
    rate = zeros(1,nstim); spont = zeros(1,nstim);
    for stim_id = 1:nstim
        spk    = L2spikes{cell_id}{stim_id};
        spikes = cell2mat(spk')';
        if(~isempty(spikes))
            qstim  = find(spikes>=t1 & spikes<=t2);
            rate(stim_id)  = length(qstim)/(length(spk)*(t2-t1));
        end
    end
    rate_all(count,1:length(rate)) = rate;
    count=count+1;
end

return