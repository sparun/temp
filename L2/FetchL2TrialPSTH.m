%FetchL2TrialPSTH  -> Fetches psth for each trial as a function of time for every stim & neuron
% Required inputs
%    L2orspikes    = L2 structure or cell array {ncellsx1}{nstimx1}{1xntrials} of spikes 
%    binsize       = binsize in seconds used to calculate psth
% Optional inputs
%    window        = time window [tstart tend] to use for psth
%                    defaults:
%                    if L2 is input: whatever is in L2_str.specs.spk_window
%                    if soikes is input: whatever is in L2_str.specs.baseline_spk_window
%    qcells        = indices of neurons to use
%                    defaults:
%                    for L2 input: L2_str.qvisual if present or all neurons
%                    for spikes input: all neurons
% Outputs:
%    psth_all      = nested cell array - psth_all{n}{k} contains an
%                      ntrials x tpsth matrix for the nth neuron, kth stimulus
% Method
%    FetchL2PSTH fetches the average post-stimulus time histogram (psth) of
%    for each neuron and each stimulus in an L2_str.

% SP Arun
% ChangeLog:
%    04/12/2008 - SPA - first version
%    02/06/2012 - SPA - added documentation
%    18/04/2015 - ZAK - modified to run only on visual neurons
%    15/12/2015 - ZAK - updated to work with L2 or spikes
%    30/06/2016 - SPA - updated to return psth as a ncells x nstim x nbins x ntrials matrix 

function [psthall,tpsth] = FetchL2TrialPSTH(L2orspikes,binsize,window,qcells)

if ~iscell(L2orspikes)
    L2spikes = L2orspikes.spikes;
    if ~exist('qcells') | isempty(qcells)
        if(isfield(L2orspikes,'qvisual'))
            qcells = L2orspikes.qvisual(:)';
        else
            qcells = [1:length(L2orspikes.neuron_id)];
        end
    end
    if(~exist('window') | isempty(window)), window = [L2orspikes.specs.spk_window(1,1) L2orspikes.specs.spk_window(1,2)]; end
else
    L2spikes = L2orspikes;
    if ~exist('qcells') | isempty(qcells)
        qcells = 1:length(L2orspikes);
    end
    if(~exist('window') | isempty(window)), window = [0 .5]; end
end

tpsth = [window(1):binsize:window(2)]';
maxstim = max(cellfun('length', L2spikes));
for cellid=1:length(qcells)
    maxtrials(cellid)= max(cellfun('length', L2spikes{qcells(cellid)}));
end
maxtrials = max(maxtrials);     

count = 1; psthall = NaN(length(qcells),maxstim,length(tpsth),maxtrials); 
for cell_id = qcells(:)'
    nstim = length(L2spikes{cell_id});
    maxtrials = max(cellfun('length', L2spikes{cell_id}));
    for stim_id = 1:nstim
        spikes = L2spikes{cell_id}{stim_id};
        if(~isempty(spikes))
            p = zeros(length(tpsth),maxtrials);
            for trial_id = 1:length(spikes)
                spk = spikes{trial_id};
                if(~isempty(spk))
                    tmp = histc(spk,tpsth)/binsize;
                    p(:,trial_id)=tmp; 
                end
            end
            psthall(count,stim_id,:,1:size(p,2))=p;
        end
    end
    count = count + 1;
end
tpsth = tpsth+binsize/2;

return