%manyintersect       --> Computes any finite set intersection :)
%% c = manyintersect(a,b,...); 
%% Required inputs
%%    a,b,...       = vectors
%% Outputs:
%%    c             = intersection of the elements in a,b,...
%% Comments
%%    Don't know why Matlab didn't do this. 

%  Arun Sripati
%  Date: August 8, 2004

function c = manyintersect(varargin)

if(length(varargin)==2)
    c = intersect(varargin{1},varargin{2}); 
else
    c = varargin{1};
    for i = 1:length(varargin)-1
        c = manyintersect(c,varargin{i+1}); 
        i = i+1; 
    end
end

return