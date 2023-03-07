% CalculateResponseLatency  --> Calculate the latency of the neuronal response
% [latency,width,latencypars] = CalculateResponseLatency(tspike1,ts1,ts2)
% Required inputs
%    tspike          = Cell array of spike times for each trial
%    ts1,ts2         = Start and end points of window for spontaneous activity
% Optional inputs
%    win_start_array = time window start times
%    win_width_array = time window widths
% Outputs
%    latency         = starting time of window during which firing 
%                       (rate1-rate2) is the most significantly different from spont
%    width           = width of the best time window
%    latencypars     = array of starting points and widths used to search for best window
% Method
%    Perform repeated t-tests on the two signals using windows with varying starting 
%    points and widths. The response latency is taken as the starting point of the window 
%    that gave the most significant difference in firing rates. Note that we are
%    converting the spike counts into rates in order to compare counts from different
%    time windows. 

%  Arun Sripati
%  First version: 16 Aug 2008
%  Last updated: 21 Feb 2013 (converted time units to secs, updated documentation)

function [latency,width,latencypars] = CalculateResponseLatency(tspike,ts1,ts2,win_start_array,win_width_array)

spk = cell2mat(tspike(:)); % concatenate spike times of all the trials
tmax = max(.100,max(spk(:)));  % max spike time or 100 ms whichever is more
t = [0:.001:tmax];

if ~exist('win_start_array') | isempty(win_start_array)
    win_start_array = [.050:.001:.200]; % time bin start
end

if ~exist('win_width_array') | isempty(win_width_array)
    win_width_array = [.010:.001:.200]; % time bin width
end

latencypars.win_start = win_start_array;
latencypars.win_width = win_width_array;

spkcount = zeros(length(tspike),length(t)); % to store spike count for each trial at various times
spont = zeros(length(tspike),1); % to store spontaneous firing rate for each trial

for i = 1:length(tspike) % processing each trial
    if(~isempty(tspike{i}))
        spkcount(i,:) = hist(tspike{i},t);
        
        q = find(tspike{i}>=ts1 & tspike{i}<ts2); 
        spont(i) = length(q)/(ts2-ts1); 
    end
end

latency = NaN; % latency of neuronal response
width = NaN; % width of the bin with the highest t-test significance
% significance values of t-test for each bin start and width combination
p = NaN(length(win_start_array),length(win_width_array));

if(sum(spkcount(:))~=0) % don't proceed if there are zero spikes
    count1 = 1; % to count bin starts
    for win_start = win_start_array % processing each bin start
        count2 = 1; % to count time bin widths
        for win_width = win_width_array % processing each bin width
            win_end = win_start+win_width; % bin end time
            q = find(t>=win_start & t<win_end); % times at which spikes happened
            r1 = sum(spkcount(:,q),2)/(win_end-win_start); % firing rate for that bin start and width
            p(count1,count2) = NaN;
            if(sum(r1)+sum(spont)~=0) % don't do t-test if both firing rates are zero
                [h,p(count1,count2)] = ttest2(r1,spont); % storing the significance
            end
            count2=count2+1;
        end
        count1 = count1+1;
    end
    [i,j] = find(p==min(p(:))); % bin start and width with the highest significance
    if(min(p(:))<=0.05) % if the highest significance is less than the criterion
        latency = mean(win_start_array(i));
        width = mean(win_width_array(j));
    end
end

return
