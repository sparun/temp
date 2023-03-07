% poissongen.m      --> Generates a homogenous Poisson process with specified rate and duration.
%  sptimes = poissongen(rate,T)
%  Required inputs
%    rate         = rate of the poisson process, in spikes/second
%    T            = specifies the length of the spike train in s 
%    ntrials      = number of trials to generate (if ntrials>1, sptimes
%                   is a cell array)
%  Outputs:
%    sptimes      = if ntrials = 1, vector of spike times, between [0 T] of the poisson process
%                   otherwise, cell array of spike times. 
%  Method
%    - Generate uniform random numbers and transform them using the inverse of the poisson pdf.
%      Standard method, see Stochastic Processes, by Ross for more.
%  Example
%    tspike = poissongen(50,1);
%  Required subroutines --> NONE

% Arun Sripati 
% Spring 2002

function sptimes = poissongen(rate,T,ntrials)
if(~exist('ntrials')) ntrials = 1; end;

for i = 1:ntrials
    n_isis = floor(10*T*rate); isis = -(1/rate)*log(rand(n_isis,1));
    spt = cumsum(isis); spt = spt(find(spt<=T));
    sptimes{i} = spt; % store spike times in ms
end
if(ntrials==1) sptimes = sptimes{i}; end;

return