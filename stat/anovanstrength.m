% anovanstrength -> performs anovan with given n factors and calculates the
%                   strengths of main effects snd interaction effects
%
% [S terms panova] = anovanstrength(rate, varargin)
%
% Inputs
%    rate     - trial firing rates for each stim: nstim x ntrials
%    varargin - variable number of factors labels
%               multiple nstim x 1 vectors of factor labels
%
% Outputs
%    S        - strength of each effect (main & interaction)
%               neffects x 1
%    terms    - list of main & interaction effects whose strengths are computed
%               neffects x nfactors
%               [1 0
%                0 1
%                1 1]
%               2 columns indicate 2 factors
%               row 1: factor 1 main effect
%               row 2: factor 2 main effect
%               row 3: factor 1 & 2 interaction effect
%    panova   - significance value for each effect (main & interaction)
%               neffects x 1
%    
% Method
%    anovanstrength performs n-way anova on the odd & even trials and
%    computes the strength of each effect (main & interaction) as the
%    average of the strengths calculated by the two following ways in order
%    to account for noise, if any:
%       1) mean(direction_from_odd_trials * amplitude_from_even_trials)
%       2) mean(direction_from_even_trials * amplitude_from_odd_trials)
%
% Zhivago Kalathupiriyan
%
% Change Log: 
%    11/02/2014 - ZAK - first version

function [S terms panova] = anovanstrength(rate, varargin)

ntrials = size(rate,2); % number of trials
nfactors = length(varargin); % number of factors
qodd = 1:2:ntrials; qeven = 2:2:ntrials; % odd & even indices

alllabels = []; oddlabels = []; evenlabels = []; % trial labels
for i = 1:nfactors
    labels{i} = varargin{i};
    levels{i} = unique(labels{i});
    triallabels = labels{i}*ones(1,ntrials);
    alllabels = [alllabels vec(triallabels)];
    oddlabels = [oddlabels vec(triallabels(:,qodd))];
    evenlabels = [evenlabels vec(triallabels(:,qeven))];
end

% odd trial analysis
[p table stats terms] = anovan(vec(rate(:,qodd)), oddlabels, 'model', 'full', 'display', 'off');

neffects = size(terms,1); % number of effects for the given number of factors

% computing the indices to acces the coefficients related to each effect (main & interaction)
bounds = [cumsum(stats.termcols(1:end-1))+1 cumsum(stats.termcols(1:end-1))+stats.termcols(2:end)];

% effect direction & strength from odd trials
for i = 1:neffects
    C = stats.coeffs(bounds(i,1):bounds(i,2)); odddir{i} = sign(C); oddmag{i} = C;
end

% even trial analysis
[p table stats terms] = anovan(vec(rate(:,qeven)), evenlabels, 'model', 'full', 'display', 'off');

% effect direction & strength from even trials
for i = 1:neffects
    C = stats.coeffs(bounds(i,1):bounds(i,2)); evendir{i} = sign(C); evenmag{i} = C;
end

% effect strengths using dats from both odd and even trials
for i = 1:neffects
    pred1 = mean(odddir{i}.*evenmag{i});
    pred2 = mean(evendir{i}.*oddmag{i});
    S(i,1) = .5*(pred2+pred1);
end

% all trials anova
panova = anovan(vec(rate), alllabels, 'model', 'full', 'display', 'off');

end