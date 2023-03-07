% randomwalk -> simulate many trials of a random walk to threshold

% Changelog
%   17/12/2013 : First created (SPArun)

function RT = randomwalk(ntrials,drift,noise)

threshold = 1; nsteps = ceil(threshold/drift); 
for i = 1:ntrials
    x = drift + noise*randn(50*nsteps,1);
    c = cumsum(x);
    RT(i,1) = min(find(c>=threshold));
end

return
