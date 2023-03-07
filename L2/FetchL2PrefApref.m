% FetchL2PrefApref -> Calculate preferred and non-preferred PSTHs for two stimulus sets
% Required inputs
%    L2_str        = L2_str containing data across all neurons
%    binsize       = binsize at which to calculate PSTH
%    q1, q2        = stimulus ids over which to calculate psth
%    t1, t2        = time window between which to define preference
% Outputs:
%    pref          = ncells x time array of preferred firing rate
%    apref         = ncells x time array of non-preferred firing rate
%    t             = array of times of the psth
%    qpref         = ncells x 1 array specifying the preferred stim 
%                    qpref = 1 for set 1 and 2 for set 2
% Method
%    FetchL2PrefApref calculates the preferred and non-preferred firing rates based on
%    half the trials and the PSTH based on the other half of trials. This ensures that the
%    PSTH of preferred and non-preferred stimuli is unbiased (i.e., will hover around
%    zero for pure noise). 
% 
% Required subroutines ---> FetchL2TrialPSTH

% Change log
%    30/01/2009 (SPA) - Original version
%    24/02/2014 (SPA) - Removed qp1, qp2 as they seemed redundant

function [pref,apref,tpsth,qpref] = FetchL2PrefApref(L2_str,binsize,qp1,qp2,t1,t2)

[psth_cells,tpsth] = FetchL2TrialPSTH(L2_str,binsize); 
qt = find(tpsth>=t1 & tpsth<=t2);
for cell_id = 1:length(psth_cells)
    psth = psth_cells{cell_id}; % stim x trial x time

    % calculate firing rate based on even-numbered trials 
    psth1 = cell2mat(psth(qp1)); psth2 = cell2mat(psth(qp2)); 
    p1o = mean(psth1(1:2:end,:),1); p2o = mean(psth2(1:2:end,:),1);
    p1e = mean(psth1(2:2:end,:),1); p2e = mean(psth2(2:2:end,:),1);
    r1o = mean(p1o(qt)); r2o = mean(p2o(qt)); 
    r1e = mean(p1e(qt)); r2e = mean(p2e(qt)); 
    
    % pref & apref signals
    % define pref based on odd trials , store corresponding psth from even trials
    % define pref based on even trials, store corresponding psth from odd trials
    pref1 = p1e; apref1 = p2e; if(r2o>r1o), pref1 = p2e; apref1 = p1e; end
    pref2 = p1o; apref2 = p2o; if(r2e>r1e), pref2 = p2o; apref2 = p1o; end;
    
    pref(cell_id,:) = 0.5*(pref1+pref2); apref(cell_id,:)= 0.5*(apref1+apref2); 
    
    % store the preferred stimulus id based on all (even & odd) trials
    qpref(cell_id,1) = 1; if(mean(vec(psth1(:,qt)))<mean(vec(psth2(:,qt)))),qpref(cell_id,1)=2; end;     
end

return

%% Testing 
allclear; 
% Create a L2_str with two stim with 16 trials each 
for cell_id = 1:100
    L2_str.neuron_id{cell_id,1} = num2str(cell_id); 
    
    stim_id = 1;
    for trial_id = 1:16
        tspike = [poissongen(5,0.1);0.1+poissongen(50,0.3)];
        L2_str.spikes{cell_id}{stim_id}{trial_id} = tspike; 
    end
    stim_id = 2; 
    for trial_id = 1:16
        tspike = [poissongen(5,0.1);0.1+poissongen(50,0.3)];
        L2_str.spikes{cell_id}{stim_id}{trial_id} = tspike; 
    end
end
L2_str.spike_window = [0 0.4];
[pref,apref,t] = FetchL2PrefApref(L2_str,0.010,1,2,0.05,0.25); 

figure; 
plot(t,nanmean(pref,1),'LineWidth',2); hold on; 
plot(t,nanmean(apref,1)); 
legend('pref','apref'); 
