% wm_extractDigitalBits -> This function extracts single bits from 64 bit representations.
% 
% Required Inputs
%       data        =  (nSamples x 1) Vector of integers between 0 and 2^64-1. 
%                    Each integer represents a 64 bit number.  
%       bitPosition =  Scalar value indicating the position of bit to be extracted. Hardcoded as 3 in "wm_ecubeProperties.m"
% 
% Outputs
%       value       =  (nSamples x 1) vector indicating the value of the bit in the requested position. Values of this vector will be 0 or 1.    
% 
% Version History: 
%    Date               Authors             Notes
%    1-Sep-2021         Georgin             First version
% ========================================================================================

function value = wm_extractDigitalBits(data, bitPosition)

% shift the data so that the desired bit is the rightmost one
if(bitPosition > 1), data = bitshift(data, -(bitPosition-1)); end

value = bitand(data,1); % set as 1 whichever uint64 number has 1 on the rightmost bit
value = double(value);
end


