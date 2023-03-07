% strip_axes -> Remove all labels and ticks on a plot

function strip_axes(h)

if(~exist('h')); h = gca; end
set(gca,'XTickLabel',[],'YTickLabel',[]);
xlabel(''); ylabel(''); 
legend off; 

return