%FetchL2TrialRates -> Fetch firing rates during a spont & stim window in an L2_str
% Required inputs
%    L2orspikes    = L2 structure or cell array {ncellsx1}{nstimx1}{1xntrials} of spikes 
%    t1,t2         = start and end of spike window to be used
% Optional inputs
%    qcells        = indices of neurons to use
%                    defaults:
%                    for L2 input: L2_str.qvisual if present or all neurons
%                    for spikes input: all neurons
% Outputs:
%    rate_all      = ncells x 1 cell array of evoked firing rates 
%                       each cell containing a nstim x ntrials matrix of firing rates
%    qincomplete   = index of neurons with incomplete stimulus set
%    
% Method
%    FetchL2TrialRates fetches the firing rates in each trial for each stim and each neuron. 
%    This is useful for doing stats on firing rate in a given time period

% SP Arun
% ChangeLog: 
%    11/10/2006 - SPA     - first version
%    02/06/2012 - SPA     - added documentation
%    23/05/2013 - ZAK     - added an optional argument (qstim) to specify the stimuli
%    11/06/2013 - ZAK,SPA - modified to account for incomplete data (where only a few stimuli have spikes)
%                           Now the function returns NaNs wherever there
%                           are no trials or stimuli containing responses.
%                           Also returns a list of neurons with incomplete stimulus set
%    18/04/2015 - SPA     - Removed spont period & modified to run only on visual neurons
%    15/12/2015 - ZAK     - Updated to work with L2 or spikes

function [rate_all,qincomplete] = FetchL2TrialRates(L2orspikes,t1,t2,qcells)

if ~iscell(L2orspikes)
    L2spikes = L2orspikes.spikes;
    if ~exist('qcells') | isempty(qcells)
        if(isfield(L2orspikes,'qvisual'))
            qcells = L2orspikes.qvisual(:)';
        else
            qcells = [1:length(L2orspikes.neuron_id)];
        end
    end
else
    L2spikes = L2orspikes;
    if ~exist('qcells') | isempty(qcells)
        qcells = 1:length(L2orspikes);
    end
end

% indices of neurons with incomplete stimuli
qincomplete = [];

% figuring out the maximum number of stimuli by looking at all the neurons
% assumption: (1) at least one neuron will have the full stimulus set
%             (2) no neuron will have data for more stimuli than the actual set
maxstim = max(cellfun('length', L2spikes));

% processing each neuron
count = 1;
for cell_id = vec(qcells)'
    incompleteflag = 0;
    
    % maximum index of stimuli for which data was recorded
    nstim = length(L2spikes{cell_id});
    
    % maximum number of trials collected for any stimulus
    maxtrials = max(cellfun('length', L2spikes{cell_id}));
    
    % initializing the evoked and spont firing rate arrays with NaNs
    rate = NaN(maxstim,maxtrials); spont = rate;
    
    % processing each stimulus
    for stim_id = 1:nstim
        
        % spikes for all the trials
        spikes = L2spikes{cell_id}{stim_id};
        
        % number of trials for which data exists
        ntrials = length(L2spikes{cell_id}{stim_id});
        
        % size of the spike data array for a neuron only indicates the
        % maximum index of the stimulus for which data exists
        % there is a possibility that data may be missing for one or more
        % stimuli in between.  catching such cases
        if ntrials == 0, incompleteflag = 1; end
        
        % processing each trial
        for trial_id = 1:ntrials
            % computing the evoked and spont firing rates
            q = find(spikes{trial_id}>=t1 & spikes{trial_id}<=t2);
            rate(stim_id,trial_id) = length(q)/(t2-t1);
        end
    end
    
    % transferring data to a cell array
    rate_all{count,1} = rate;
    
    % adding the neuron to the incomplete list if data doesn't exist for all the stimuli
    % trials are not being accounted for since there's stimuli with
    % different number of correct trials can exist, eg. L3_dtx_dtxct has
    % dtx stimuli with 8 and dtxct stimuli with 4 correct trials
    if nstim < maxstim | incompleteflag == 1
        qincomplete(end+1,1) = cell_id;
    end
    
    count = count + 1;
end

return