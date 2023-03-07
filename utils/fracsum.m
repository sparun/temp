% fracsum -> given two numbers calculate each of their contribution to the sum

% ChangeLog: 
%    30 Aug 2015 - SPA   - first version

function [fx,fy] = fracsum(x,y)

fx = x./(x+y); 
fy = 1-fx; 

return