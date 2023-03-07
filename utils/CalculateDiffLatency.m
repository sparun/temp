%CalculateDiffLatency  --> Calculate the latency of a discriminative signal
% Required inputs
%    tspike1       = Cell array of spike times for stimulus 1, across trials
%    tspike2       = Cell array of spike times for stimulus 2, across trials
% Optional inputs
%    winstart      = array of window start times (default: 0.05:0.001:0.2
%    fig_flag      = if 1, plot a figure with estimated latency and firing rate difference
% Outputs:
%    latency       = starting time of window during which signal
%                   (rate1-rate2) is the most significant
%    width         = width of the best time window
%    latencypars   = array of starting points and widths used to search for best window
% Method
%    - CalculateLatency performs repeated tpsth-tests on the two signals using windows with
%      varying starting points and widths. The latency of the discriminative signal is taken
%      as the starting point of the window that gave the most significant difference in firing rates.
%    - Based on empirical testing, I find that estimated latency does not differ
%      for low vs high firing rate differences

%  SP Arun
%  First version: 16 April 2008
%  Last updated : 18 May 2012 (converted time units to seconds)

function [latency,width,latencypars] = CalculateDiffLatency(tspike1,tspike2,winstart,winwidth,fig_flag)
if(~exist('fig_flag')), fig_flag = 1; end;
if(~exist('winstart')), winstart = [.05:.001:.200]; end; 
if(~exist('winwidth')), winwidth = [.010:.001:0.200]; end; 
warning off Matlab:DivideByZero

latencypars.win_start = winstart;
latencypars.win_width = winwidth;

tpsth = [winstart:0.001:winstart(end)+winwidth(end)];
rate1 = zeros(length(tspike1),length(tpsth)); count=1; 
for i = 1:length(tspike1)
    if(~isempty(tspike1{i}))
        rate1(count,:) = hist(tspike1{i},tpsth);
        count=count+1; 
    end
end

rate2 = zeros(length(tspike2),length(tpsth)); count=1; 
for i = 1:length(tspike2)
    if(~isempty(tspike2{i}))
        rate2(count,:) = hist(tspike2{i},tpsth);
        count=count+1;
    end
end

count1 = 1;
for win_start = winstart
    count2 = 1;
    for win_width = winwidth
        win_end = win_start+win_width;
        q = find(tpsth>=win_start & tpsth<win_end);
        r1 = sum(rate1(:,q),2); r2 = sum(rate2(:,q),2);
        [h,p(count1,count2)] = ttest2(r1,r2);
        count2=count2+1;
    end
    count1 = count1+1;
end

[i,j] = find(p==min(p(:)));
if(min(p(:))>0.05)
    latency = NaN; width = NaN; % indicates that no effect was significant
else
    latency = mean(winstart(i));
    width = mean(winwidth(j));
end
latencypars.minp = min(p(:)); 

if(fig_flag)
    t = [tpsth(1):0.010:tpsth(end)];
    DisplayRateDiff(tspike1,tspike2,t);    
    v = axis; y = [v(3):v(4)];
    plot(latency*ones(size(y)),y,'k');
    plot((latency+width)*ones(size(y)),y,'k');
end

% keyboard
return