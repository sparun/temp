% decodeL2          --> population decoding dynamics
% Required inputs
%    L2_str         = L2 structure containing spikes
%    qtrain         = ids of train stimuli
%    qtest          = ids of test stimuli
% Optional inputs:
%    catlabels      = {trainlabels testlabels} cell array with category labels of train and test stimuli
%    twindow        = [tstart tend] time window for decoding (default: [0 0.2])
%    binsize        = size of each time bin in seconds (default = 0.02)
%    stepsize       = size of step of each time bin in seconds (default = 0.02)
%    ntrials        = number of trials available for each stimulus (default: 8)
%    pcthresh       = fraction of total data variance to retain via PCA (default: 0.8)
%    classifiertype = type of classifier (default: linear)
%    normflag       = if 1, normalize each cell by the maxrate over the entire twindow (default = 0)
%    qcells         = ncells x 1 of cells to use (indexed into L2_str.neuron_id)
%    niter          = number of bootstrap samples done by sampling cells with replacement
%                     if niter=1, run once for all cells together
%                     if ncells=10, sample cells with replacement 10 times and return a decoding time course for each iteration
%    dispflag       = if 1 (default), display parameters and progress
% Outputs:
%    accuracy       = ntrials x nbins matrix of predicted labels (1 = correct, 0 = wrong)
%    time           = nbins x 1 vector of times
% Method
%    decodeL2 assumes that all data in the first trial of every neuron is
%    collected simultaneously, concatenates the response into a population vector
%    and uses a linear classifier to decode the identity of each object.
%    If train and test stimuli are identical the decoder uses a
%    leave-one-out approach to decode object identity on the left-out trial.
%    If train & test stimuli are disjoint then the decoder trains the
%    classifier on the train stimuli and generates predictions for the test
%    stimuli.
% Example: see debug code below
%
% Required lib subroutines --> pcaproject, looclassify

% SP Arun
% ChangeLog:
%    4 Jul 2016 - SPA     - first version

function [accuracy,time,predlabelsout,obslabelsout]=decodeL2(L2_str,qtrain,qtest,catlabels,twindow,binsize,stepsize,ntrials,pcthresh,classifiertype,normflag,qcells,niter,dispflag)

if(~exist('catlabels')||isempty(catlabels)), catlabels = {[1:length(qtrain)], [1:length(qtest)]}; end;
if(~exist('twindow')||isempty(twindow)),twindow = [0 0.2]; end;
if(~exist('binsize')||isempty(binsize)),binsize = 0.02; end;
if(~exist('stepsize')||isempty(stepsize)), stepsize = binsize; end;
if(~exist('ntrials')||isempty(ntrials)), ntrials = 8; end;
if(~exist('pcthresh')||isempty(pcthresh)),pcthresh = 0.8; end;
if(~exist('classifiertype')||isempty(classifiertype)),classifiertype = 'linear'; end;
if(~exist('normflag')||isempty(normflag)), normflag = 0; end;
if(~exist('qcells')||isempty(qcells)),
    qcells = [1:length(L2_str.neuron_id)];
    if(isfield(L2_str,'qvisual')), qcells = L2_str.qvisual(:)';end
end
if(~exist('niter')||isempty(niter)), niter = 1; end; % by default run on all cells
if(~exist('dispflag')||isempty(dispflag)), dispflag = 1; end; % by default display parameters, progress

qtrain = vec(qtrain); qtest = vec(qtest); trainlabels = vec(catlabels{1}); testlabels = vec(catlabels{2});

if(dispflag); 
fprintf('Running decoding analysis with parameters: \n');
fprintf('    twindow = [%2.3g %2.3g] s, binsize = %2.3g s, step = %2.3g s \n',twindow(1),twindow(2),binsize,stepsize);
fprintf('    ntrials = %d, pcthresh = %2.1g, classifier = %s \n \n',ntrials,pcthresh,classifiertype);
end

[psth,tpsth]=FetchL2TrialPSTH(L2_str,0.001,twindow,qcells);
if(normflag)
    mrates = FetchL2Rates(L2_str,twindow(1),twindow(2),qcells); maxrate = max(mrates,[],2);
    maxrate = repmat(maxrate,[1 size(psth,2) size(psth,3) size(psth,4)]);
    psth = psth./maxrate;
end

ncells = size(psth,1); nstim = size(psth,2);

time = [twindow(1):stepsize:twindow(2)];
for iter=1:niter
    qcellsiter = [1:ncells];
    if(niter~=1),qcellsiter = randsample([1:ncells],ncells,1); end; % sample cells with replacement
    for bin = 1:length(time)
        if(dispflag), fprintf('    t = %2.3f s \n',time(bin));end; 
        t1 = time(bin)-binsize/2; t2 = time(bin)+binsize/2;
        qt = find(tpsth>=t1 & tpsth<=t2);
        rateallbin = squeeze(nanmean(psth(:,:,qt,1:ntrials),3));
        rateall = rateallbin(qcellsiter,:,:); 
        stimall = repmat([1:nstim],[ncells 1 ntrials]);
        popvectors = reshape(permute(rateall,[1 3 2]),[ncells nstim*ntrials])';
        stimlabels = reshape(permute(stimall,[1 3 2]),[ncells nstim*ntrials])'; stimlabels = stimlabels(:,1);
        
        % restrict rateall & stimall to qtrain+qtest
        qtrials = find(ismember(stimlabels,[qtrain qtest]));
        popvectors = popvectors(qtrials,:); stimlabels = stimlabels(qtrials);
        popvectors = pcaproject(popvectors,pcthresh);
        
        [trainids,q1] = ismember(stimlabels,qtrain); trainids = find(trainids); q1 = q1(q1~=0);
        [testids, q2] = ismember(stimlabels,qtest); testids = find(testids); q2 = q2(q2~=0);
        trainvectors = popvectors(trainids,:); alltrainlabels = trainlabels(q1);
        testvectors = popvectors(testids,:); alltestlabels = testlabels(q2);
        
        if(all(qtrain==qtest)) % if train==test then crossvalidate
            predlabels = looclassify(trainvectors,alltrainlabels,pcthresh,classifiertype);
        else % train on one set of labels and test on the other
            predlabels = classify(testvectors,trainvectors,alltrainlabels,classifiertype);
        end
        accuracy(:,bin,iter) = double(predlabels==alltestlabels);
        predlabelsout(:,bin,iter) = predlabels; 
        obslabelsout(:,bin,iter) = alltestlabels; 
    end
end
accuracy = squeeze(accuracy);

return

%% debug code: reproduce view dynamics result for viewct
allclearL2; if(~exist('L2_str')),load ..\L2_viewct; end
[dviewsp,time] = decodeL2(L2_str,[1:2:48],[1:2:48]);
[dviewinv,time] = decodeL2(L2_str,[1:2:48],[2:2:48]);

figure;
y = dviewinv; errorbar(time,nanmean(y,1),nansem(y,1)); hold on;
y = dviewsp; errorbar(time,nanmean(y,1),nansem(y,1),'r');
hold on; plot(time,ones(size(time))/24,'k--');
xlabel('Time, s'); ylabel('Decoding accuracy');

