% anovantimecourse -> calculates strengths of main and interaction effects for
%                     the given factors at each time bin supplied in the psth
%
% [S terms p] = anovantimecourse(psth, qstim, varargin)
%
% Inputs
%    psth     - trial psth rates: {ncells} {nstim} {ntrials x nbins}
%    qstim    - stimuli to be used for anova
%               nstim x 1 for specifying common stimuli for all cells
%               nstim x ncells for specifying specific stimuli for each cell
%    varargin - variable number of factors labels
%               multiple nstim x 1 vectors of factor labels
%
% Outputs
%    S        - strength of each effect (main & interaction)
%               nbins x neffects x ncells
%    terms    - list of main & interaction effects whose strengths are computed
%               neffects x nfactors
%               [1 0
%                0 1
%                1 1]
%               2 columns indicate 2 factors
%               row 1: factor 1 main effect
%               row 2: factor 2 main effect
%               row 3: factor 1 & 2 interaction effect
%    p        - significance value for each effect (main & interaction)
%               nbins x neffects x ncells
%    
% Method
%    anovantimecourse performs extracts the trial rates at each time bin
%    and invokes anovanstrength to compute the effect strengths at each
%    time bin
%
% Functions Called
%    1) anovanstrength: to compute the effect strengths at each time bin
%
% Zhivago Kalathupiriyan
%
% Change Log: 
%    11/02/2014 - ZAK - first version
%    12/02/2014 - ZAK - modified code to consider all the available trials
%                       for a stim and to specify qstim for each cell

function [S terms p] = anovantimecourse(psth, qstim, varargin)

nbins = size(psth{1}{1},2)-1; % number of psth bins (ignoring the last bin because it contains spillovers)

% reformatting psth data as: {ncells} {nbins} (nstim x ntrials) so that it
% is easy to extract trial rates at each bin and pass it to anovanstrength
psthrates = cell(0);
for i = 1:nbins
    for j = 1:length(psth) % neurons
        % considering all trials available for stimuli and
        % filling with NaN where extra trial information is absent
        ntrials = max(cellfun(@(x) size(x,1), psth{j}));
        psthrates{j,1}{i,1} = NaN(size(qstim,1), ntrials);
        for k = 1:length(psth{j}) % stimuli
            ntrials = length(psth{j}{k}(:,i));
            psthrates{j,1}{i,1}(k,1:ntrials) = psth{j}{k}(:,i);
        end
    end
end

% calculating effect strengths for each neuron and time bin
for cellid = 1:length(psth)
    ratecell = psthrates{cellid}; % psth of a neuron
    for i = 1:nbins
        binrates = ratecell{i}; % trial rates in a given time bin
        % checking if qstim is specified for each cell
        if size(qstim,2) == 1
            binrates = binrates(qstim,:);
        else
            binrates = binrates(qstim(:,cellid),:);
        end
        [S(i,:,cellid) terms p(i,:,cellid)] = anovanstrength(binrates, varargin{:});
    end
end

end