
function b = svdregress(y,X) 

b = svdinv(X'*X,0.005)*X'*y;

return