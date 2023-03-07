%FetchL2PSTH     -> Fetch psth for each stimulus using a specified binsize
% Required inputs
%    L2orspikes    = L2 structure or cell array {ncellsx1}{nstimx1}{1xntrials} of spikes 
%    binsize       = binsize in seconds used to calculate psth
% Optional inputs
%    twindow       = time window [tstart tend] to use for psth
%                    defaults:
%                    if L2 is input: whatever is in L2_str.specs.spk_window
%                    if soikes is input: whatever is in L2_str.specs.baseline_spk_window
%    qcells        = indices of neurons to use
%                    defaults:
%                    for L2 input: L2_str.qvisual if present or all neurons
%                    for spikes input: all neurons
% Outputs:
%    psth_all      = ncells x nstim x tpsth matrix of firing rates in each time bin
% Method
%    FetchL2PSTH fetches the average post-stimulus time histogram (psth) of 
%    for each neuron and each stimulus in an L2_str. 

% SP Arun
% ChangeLog: 
%    11/10/2006 - SPA - first version
%    18/04/2015 - ZAK - modified to run only on visual neurons
%    15/12/2015 - ZAK - updated to work with L2 or spikes

function [psth_all,t_psth] = FetchL2PSTH(L2orspikes,binsize,twindow,qcells)

if ~iscell(L2orspikes)
    L2spikes = L2orspikes.spikes;
    if ~exist('qcells') | isempty(qcells)
        if(isfield(L2orspikes,'qvisual'))
            qcells = L2orspikes.qvisual(:)';
        else
            qcells = [1:length(L2orspikes.neuron_id)];
        end
    end
    if(~exist('twindow') | isempty(twindow)), twindow = [L2orspikes.specs.spk_window(1,1) L2orspikes.specs.spk_window(1,2)]; end
else
    L2spikes = L2orspikes;
    if ~exist('qcells') | isempty(qcells)
        qcells = 1:length(L2orspikes);
    end
    if(~exist('twindow') | isempty(twindow)), twindow = [0 .5]; end
end

t_psth = [twindow(1):binsize:twindow(2)];

count = 1;
for cell_id = qcells
    nstim = length(L2spikes{cell_id}); 
    for stim_id = 1:nstim
        spikes = L2spikes{cell_id}{stim_id};
        p = zeros(size(t_psth))'; 
        if(~isempty(spikes))
            for trial_id = 1:length(spikes)
                spk = spikes{trial_id}; 
                if(~isempty(spk))
                    tmp = histc(spk,t_psth)/binsize; 
                    p = p + tmp(:)/length(spikes);
                end
            end
            psth(stim_id,:) = p; 
        end
    end
    psth_all(count,:,:) = psth; 
    count = count + 1;
end
t_psth = t_psth + binsize/2; 

% remove last bin because histc the number of elements that fall exactly here
psth_all(:,:,end) = []; t_psth(end) = []; 

return