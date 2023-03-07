% CreateCircularAperture -> Create a circular aperture


function C = CreateCircularAperture(diameter,n)
C = zeros(n,n); 

x=[-n/2+1:n/2]; [X,Y] = meshgrid(x,x); R2 = X.^2 + Y.^2; 
q = find(R2<=diameter^2/4); C(q) = 1; 

return