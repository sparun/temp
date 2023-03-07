%FetchL2GoodNeurons -> Find visually modulated neurons in an L2_str
% [qsig,psig] = FetchL2GoodNeurons(L2_str,ts1,ts2,t1,t2,criterion,qstim); 
% Required inputs
%    ts1, ts2      = start and end of spontaneous window
%    t1,t2         = start and end of visual response window
% Optional inputs
%    qstim         = ids of stimuli to be used (default: all stimuli)
%    test_type     = type of comparison to use 
%                        1 = concatenate all stimuli
%                        2 = perform a comparison for each stimulus (default)
%    criterion     = statistical criterion (default = 0.05)
% Outputs:
%    qsig          = ids of neurons that have significantly higher firing in the visual window compared to spont. 
%    psig          = p-value of this comparison for each neuron
% Method
%    FetchL2GoodNeurons compares the spike rates across all stimuli between the spont window
%       and the visual window using a t-test. 
% Required programs: FetchL2TrialRates

% SP Arun
% ChangeLog
%    3/5/2012   - first created
%    2/6/2012   - added documentation
  
function [pall,pstim] = FetchL2GoodNeurons(L2_str,ts1,ts2,t1,t2,qstim,test_type,criterion)
if(~exist('qstim')), qstim = [1:length(L2_str.spikes{1})]; end; 
if(~exist('test_type')), test_type = 2; end; 
if(~exist('criterion')), criterion = 0.05; end; 

[rate_cells,spont_cells] = FetchL2TrialRates(L2_str,ts1,ts2,t1,t2);
for cell_id = 1:length(L2_str.neuron_id)
	rate = rate_cells{cell_id}; spont = spont_cells{cell_id};
    if(size(rate,1)>=max(qstim)) % i.e. if all stim are run
        rate = rate(qstim,:); spont = spont(qstim,:);
    end;

    % check whether concatenated rate (across all stim) is greater than spont
    [~,pall(cell_id,1)] = ttest(rate(:),spont(:),0.05,'right'); % test for whether rate is greater than spont

    % check whether rate for each stimulus is greater than spont
    for stimid = 1:length(qstim)
        [~,pstim(cell_id,stimid)] = ttest(rate(stimid,:),spont(stimid,:),0.05,'right');
    end
end

return
