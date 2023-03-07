%MANYSTRMATCH Find possible matches for a pattern.
%   I = MANYSTRMATCH(STR,STRS) looks through the rows of the character
%   array or cell array of strings STRS to find strings that begin
%   with string (or cell array) STR, returning the matching row indices of STRS.  
%   STRMATCH is fastest when STRS is a character array.
%
%   I = STRMATCH(STR,STRS) returns only the indices of the strings in STRS matching STR exactly.
%   
%   See also STRMATCH
%   Created by Arun Sripati

% - modified 9/4/2006: 
%     added "unique_flag" to allow multiple instances of the same id.
%     useful when using the output of manystrmatch to cycle through all
%     instances. 
% - modified 12/29/2006
%     added support for searching only first n characters in cell array of patterns

function q = manystrmatch(pattern,strings,unique_flag,nchar)
if(~exist('unique_flag')) unique_flag = 0; end 

if(iscell(pattern))
    for i=1:length(pattern)
        if(~exist('nchar'))
            q{i,1} = strmatch(pattern{i},strings);
        else
            q{i,1} = strmatch(pattern{i}(1:nchar),strings); 
        end
    end
    q = cell2mat(q); 
else
    q = strmatch(pattern,strings); 
end
if(unique_flag)
    q = unique(q);
end
    
return