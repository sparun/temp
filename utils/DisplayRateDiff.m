% DisplayRateDiff -> Display the difference in firing rate between two sets of spikes
% [diffrate,p] = DisplayRateDiff(tspike1,tspike2,tpsth,fig_flag)
% Required inputs
%    tspike1       = Cell array of spike times for stimulus 1, across trials
%    tspike2       = Cell array of spike times for stimulus 2, across trials
%    tpsth         = vector of time bins at which to calculate firing rates
% Optional inputs
%    fig_flag      = if 1, plot a figure with firing rate difference
% Outputs:
%    diffrate      = Firing rate of best - worst stimulus
%    p             = vector containing for each time bin, the probability that 
%                    the two firing rates are same (ttest2) 
% Method
%    DisplayRateDiff takes two sets of spike trains evoked under two
%    conditions and produces a figure with the two firing rates, and a
%    significance value indicating the p-value that the two firing rates
%    are the same. 

%  SP Arun
%  First version: 16 April 2008
%  Last updated : 18 May 2012 (converted times to seconds, housekeeping)

function [diffrate,p] = DisplayRateDiff(tspike1,tspike2,tpsth,fig_flag)
if(~exist('fig_flag')), fig_flag = 1; end; 

binsize = mean(diff(tpsth)); 

rate1 = get_psth(tspike1,tpsth); rate2 = get_psth(tspike2,tpsth); 

for i = 1:length(tpsth)
    [~,p(i)] = ttest2(rate1(:,i),rate2(:,i)); 
end
qsig = find(p<=0.05); 

mrate1 = nanmean(rate1,1); mrate2 = nanmean(rate2,1); 
stdrate1 = std(rate1)/sqrt(size(rate1,1)); stdrate2 = std(rate2)/sqrt(size(rate2,1)); 

S = sign(sum(mrate1)-sum(mrate2)); % find the sign of the total rate difference
diffrate = (mrate1 - mrate2)*S; 

if(fig_flag)
    figure;
    plot(tpsth,mrate1,'b'); hold on; 
    plot(tpsth,mrate2,'r'); 
    plot(tpsth,diffrate,'k');
    %plot(tpsth,mrate1+stdrate1,'b:',tpsth,mrate1-stdrate1,'b:'); 
    %plot(tpsth,mrate2+stdrate2,'r:',tpsth,mrate2-stdrate2,'r:'); 
    plot(tpsth(qsig),1*ones(length(qsig)),'ks');
    legend('Rate1','Rate2','Difference'); 
    xlabel('Time, seconds'); ylabel('Firing rate, Hz');
end

return

function rate = get_psth(tspike,tpsth)
binsize = mean(diff(tpsth)); 

rate = zeros(length(tspike),length(tpsth)); 
for trial_id = 1:length(tspike)
    spk = tspike{trial_id};
    if(~isempty(spk))
        rate(trial_id,:) = histc(spk,tpsth)/binsize; 
    end
end

return