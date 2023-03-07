% generates a nxn matrix in which any row or column will have all the
% n numbers once, without any repetition
function X = rdm(n)
X = zeros(n,n);
j = 1;
for i = 1:n
    while(1)
        while(1)
            % all the existing elements in that row & column
            constraints = union(X(1:i-1,j)', X(i,1:j-1));
            % remaining numbers to choose from
            choices = setdiff(1:n, constraints);
            if ~isempty(choices), break; end
            j = 1;
        end
        % choosing a number at random
        if length(choices) ~= 1
            X(i,j) = randsample(choices,1);
        else
            X(i,j) = choices;
        end
        if j == n, j = 1; break; end
        j = j + 1;
    end
end
csX = sort(X,1);
for col = 1:n
    if any((csX(1:n, col)' - [1:n])), disp 'col error'; break; end
end
rsX = sort(X,2);
for row = 1:n
    if any((rsX(row, 1:n) - [1:n])), disp 'row error'; break; end
end
end