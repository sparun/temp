% To compute cross-correlogram for a given set of neurons and trials
%
% Required inputs
%    spks        = {ntrials x ncells} each cell is an array of spike times
% Optional inputs
%    tpsth       = spike time bins, in seconds
%    maxlags     = max number of lags for which ccg is to be computed
%                  eg maxlags = 50 means ccg will be computed for -50 to +50 bins
% Outputs:
%    uccg        = [ntrials x nlags x ncells] uncorrected ccg
%    sccg        = [ntrials x nlags x ncells] shuffled ccg
%    tlags       = lag times at which the ccg was calculated
% Method
%    Computes cross-correlation between all pairs of neurons with the
%    actual spikes and also using trial-shuffled spikes.  The shuffled
%    correlogram can be subtracted from the actual unshuffled correlogram
%    to get an estimate of cross-correlation without the contribution of
%    stimulus onset correlation.
% Example
%    To calculate cross-correlogram across responses to all stim for two neurons in an L2_str
%        ccgspikes([[L2_str.spikes{cell1}(:)] [L2_str.spikes{cell2}(:)]]); 
%    To do the same for responses to a particular stimulus: 
%        ccgspikes([L2_str.spikes{cell1}{stim}' L2_str.spikes{cell2}{stim}']); 
% ChangeLog:
%    23/03/2015 - ZAK - first version

function [uccg, sccg, tlags] = ccgspikes(spks, tpsth, maxlags)

% ccg calculation spike window
if ~exist('tpsth') | isempty(tpsth), tpsth = .05:.001:.2; end
if ~exist('maxlags') | isempty(maxlags), maxlags = 50; end

ncells = size(spks,2);
ntrials = size(spks,1);

% indices for extracting cross-correlations in one direction (ab) from xcorr output
% since xcorr returns autocorrelations and cross-correlations in both directions (ab & ba)
allpairs = CombVec(1:ncells, 1:ncells)'; allpairs = allpairs(:,[2,1]);
nchoosekpairs = nchoosek(1:ncells,2);
qab = find(ismember(allpairs, nchoosekpairs, 'rows'));

% shuffling the trials for every cell
for i = 1:ncells
    shflspks(:,i) = spks(randsample(1:ntrials, ntrials), i);
end

% computing spike histograms
actualspkhist = cellfun(@(x) vec(histc(x,tpsth)), spks, 'UniformOutput', false);
shflspkhist = cellfun(@(x) vec(histc(x,tpsth)), shflspks, 'UniformOutput', false);

% cross-correlation between all pairs of neurons for every trial
parfor i = 1:ntrials
    histall = cell2mat(actualspkhist(i,:));
    [c, lags] = xcorr(histall, maxlags, 'coeff'); c = c(:,qab);
    uccg(i,:,:) = c;
    histall = cell2mat(shflspkhist(i,:));
    [c, lags] = xcorr(histall, maxlags, 'coeff'); c = c(:,qab);
    sccg(i,:,:) = c;
end
uccg = squeeze(uccg); sccg = squeeze(sccg);
q = isnan(sccg); sccg(q) = 0; q = isnan(uccg); uccg(q) = 0;
binsize = mean(diff(tpsth)); tlags = [-maxlags:maxlags]*binsize; 

return

%% TEST CODE
allclear;
for tid = 1:10
    common_spikes = poissongen(20,0.2,1)+0.2;
    tspike{tid,1} = sort([poissongen(10,0.2,1);poissongen(100,0.2,1)+0.2;poissongen(10,0.2,1)+0.4;common_spikes+0.1]);
    tspike{tid,2} = sort([poissongen(10,0.2,1);poissongen(100,0.2,1)+0.2;poissongen(10,0.2,1)+0.4;common_spikes]);
end

% ccg
binsize = 0.001; nlags = 200; lags = [-nlags:nlags]*binsize;
tpsth = [0:binsize:1.2];
[uccg,sccg] = ccgspikes(tspike,tpsth,nlags);
scccg = uccg-sccg;

%
figure;
subplot(311); spike_view(tspike(:,1)); xlim([min(tpsth) max(tpsth)]);
subplot(312); spike_view(tspike(:,2)); xlim([min(tpsth) max(tpsth)]);
subplot(313); plot(lags,mean(uccg,1)); hold on; plot(lags,mean(scccg,1),'r');
legend('Uncorrected','Corrected'); xlabel('Lag, s'); ylabel('Corrcoef');
