% reads a given ctx conditions file into an array
function cnds = readcndfile(cndfile)
fid = fopen(cndfile);
tline = '';
count = 0;
cnds = [];

while ischar(tline)
    tline = fgetl(fid);
    if tline == -1, break; end
    A = sscanf(tline, '%d%*c%d%*c%d%*c%d%*c%d%*c%d%*c%d%*c%d%*c%d%*c%d%*c%d%*c%d%*S');
    if ~isempty(A) & A(1) >= 4
        count = count + 1;
        non_stim = find(A == -4);
        if ~isempty(non_stim)
            A = A(2:non_stim-1);
        else
            A = A(2:11);
        end
        A(A==0) = [];
        padding = 10 - length(A);
        A = [A;zeros(padding,1)];
        cnds(count,:) = A;
    end
end
cnds = cnds(:,any(cnds));
fclose(fid);
end
