% redmap creates a colormap in which red is positive, blue is negative and 0 is white

function c = redmap(n)

if nargin < 1, n = 254; uint16(n);  end
if n>uint16(round(n/2-0.1)*2), n = n-1; end

a=1:-1/n:0;
b=0:1/n:1;
c=ones(n+1,3);
c(:,2)=a;
c(:,3)=a; 

return