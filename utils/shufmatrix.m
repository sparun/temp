% shufarray -> randomly shuffles entries in an arbitrary matrix

function sM = shufmatrix(M)

vm = vec(M); q = randperm(length(vm)); 
vmshuf = vm(q); % shuffled vectorized matrix

sM = reshape(vmshuf,size(M)); % reshape to size of input matrix

return