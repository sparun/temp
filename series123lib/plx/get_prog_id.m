function prog_id = get_prog_id(prog_name)
global C;
nprogs = length(C.progname);
for i = 1:nprogs
    if strcmp(char(C.progname{i,1}), prog_name) == 1, prog_id = i + C.PROG_ID_START; end
end
end