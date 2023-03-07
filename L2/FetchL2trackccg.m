% FetchL2trackccg  -> gets all ccgs for a given track in an L2 structure
%
% Required inputs
%    trackid       = track id string
%    L2_str        = L2 structure
%    tpsth         = vector of time bins to be used for cross-correlation
% Optional inputs
%    maxlags       = max number of time bins to use for ccg estimate
% Outputs:
%    cccg          = corrected cross-correlogram for all unit pairs
%    tlags         = times at which crosscorrelogram is computed
% 
% ChangeLog:
%    05 Jun 2015 - SPA - first created from plotL2trackccg

function [cccg,tlags,uccg,sccg] = FetchL2trackccg(track,L2_str,tpsth,maxlags)
if ~exist('maxlags')| isempty(maxlags), maxlags = 30; end;
if(~iscell(track)), tracks{1} = track; else tracks = track; end; 

for tid = 1:length(tracks)
    clear allspikes
    cellid = manystrmatch(tracks{tid}, L2_str.neuron_id);
    spikes = L2_str.spikes(cellid)';
    for n = 1:length(spikes)
        allspikes(:,n) = [spikes{n}{:}]';
    end

    allspikes = cellfun(@(x) trimspktrain(x), allspikes, 'UniformOutput', false);
    [uccg,sccg,tlags] = ccgspikes(allspikes, tpsth, maxlags);
    
    % shuffle-corrected ccg
    cccg{tid,1} = squeeze(nanmean(uccg - sccg));
    
    fprintf('Track %s (%d of %d) \n',tracks{tid},tid,length(tracks)); 
end

% function to trim the spikes falling outside the psth window
% nested function to support cellfun on spike cell arrays
    function s = trimspktrain(s)
        s(s < tpsth(1) | s > tpsth(end)) = [];
        if isempty(s), s = NaN; end
    end

end
