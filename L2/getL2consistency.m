% getL2consistency -> display a consistency report across & within monkeys
% Usage: getL2consistency(L2_str,twindow,qcells,qstim)
%
% Required Inputs
%    L2_str     - L2_str of the experiment
%    twindow    - time window [tstart tend] in seconds to for firing rate calculation
%
% Optional Inputs
%    qcells     - index of the cells in L2_str.neuron_id to be considered (default = all cells)
%    qstim      - index of the stimuli in L2_str.items to be considered (default = all stim)
%
% Outputs
%    no output
%
% Usage
%    To evaluate consistency in a 50-200 ms window, use:
%       getL2consistency(L2_str, [.050 .200])
%    Following will be output on the matlab command window:
%       Found monkeys ro xa 
%       **** Within-monkey consistency **** 
%       ro: r = 0.48, p = 1.1e-177 (83 cells, 80C2 distances) 
%       xa: r = 0.53, p = 2.5e-232 (39 cells, 80C2 distances) 
%       **** Between-monkey consistency **** 
%       ro-xa correlation: r = 0.60, p = 9.1e-312 (83 vs 39 cells, 80C2 distances
%
% Method
%    This function computes average firing rates for all the specified
%    stimuli in the specified time window and computes distances in the
%    neuronal space between all pairs of stimuli. For within-monkey
%    consistency check, the neurons from a given monkey are split into even
%    and odd groups, and correlation between distances in these two
%    neuronal spaces are reported. For between-monkey consistency check,
%    distance correlations are reported between all possible pairs of
%    neuronal spaces - each neuronal space from one monkey's neurons
%
%    Note that this only indicates whether the data is consistent using 
%    this particular method. You will have to run your actual analysis to 
%    really know whether your specific results work on both monkeys etc. 
%
% Change Log: 
%    8 Oct 2014 - SPA - first version

function getL2consistency(L2_str,twindow,qcells,qstim)
% setting defaults for the optional inputs
if(~exist('qcells')||isempty(qcells)),qcells = [1:length(L2_str.neuron_id)]; end; 
if(~exist('qstim')),qstim = [1:length(L2_str.spikes{end})]; end;

% determining firing rates and monkeys
rates = FetchL2Rates(L2_str,twindow(1),twindow(2)); 
monkeylist = unique(cellfun(@(x) x(1:2),L2_str.neuron_id,'UniformOutput',0)); nmonkeys = length(monkeylist);

fprintf('##### %s EXPERIMENT \n',L2_str.expt_name); 
% correlation between distances from even and odd neurons - for each monkey
fprintf('**** Within-monkey consistency **** \n'); 
for mid = 1:nmonkeys
    qm = manystrmatch(monkeylist{mid},L2_str.neuron_id(qcells)); 
    do = pdist(rates(qm(1:2:end),qstim)','cityblock'); 
    de = pdist(rates(qm(2:2:end),qstim)','cityblock'); 
    [cwithin(mid,1),pwithin(mid,1)] = nancorrcoef(do,de); 
    fprintf('%s: r = %2.2f, p = %2.2g (%d cells, %dC2 distances) \n',monkeylist{mid},cwithin(mid),pwithin(mid),length(qm),length(qstim));
end

% correlation between distances from 2 monkeys at a time
mpairs = nchoosek([1:nmonkeys],2); 
fprintf('**** Between-monkey consistency **** \n'); 
for pid = 1:size(mpairs,1)
    m1 = mpairs(pid,1); m2 = mpairs(pid,2); 

    qm1 = manystrmatch(monkeylist{m1},L2_str.neuron_id(qcells)); 
    d1 = pdist(rates(qm1,qstim)','cityblock');
    qm2 = manystrmatch(monkeylist{m2},L2_str.neuron_id(qcells)); 
    d2 = pdist(rates(qm2,qstim)','cityblock');
    
    [cpair(pid,1),ppair(pid,1)] = nancorrcoef(d1,d2); 
    fprintf('%s-%s correlation: r = %2.2f, p = %2.2g (%d vs %d cells, %dC2 distances) \n',monkeylist{m1},monkeylist{m2},cpair(pid),ppair(pid),length(qm1),length(qm2),length(qstim));     
end

return