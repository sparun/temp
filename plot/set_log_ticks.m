% set_log_ticks     -> add logarithmic ticks to the plot with handle h

function set_log_ticks(h,xystring)
if(~exist('h')) h = gca; end; 

strformat = '%2.2f'; 

if(xystring(1)=='x')
    xt = get(gca,'XTick');
    for i=1:length(xt); xts{i,1} = sprintf(strformat,10^xt(i)); end;
    set(gca,'XTickLabel',xts);
elseif(xystring(1)=='y')
    yt = get(gca,'YTick');
    for i=1:length(yt); yts{i,1} = sprintf(strformat,10^yt(i)); end;
    set(gca,'YTickLabel',yts);
else 
    xt = get(gca,'XTick');
    for i=1:length(xt); xts{i,1} = sprintf(strformat,10^xt(i)); end;
    set(gca,'XTickLabel',xts);
    yt = get(gca,'YTick');
    for i=1:length(yt); yts{i,1} = sprintf(strformat,10^yt(i)); end;
    set(gca,'YTickLabel',yts);
end

return