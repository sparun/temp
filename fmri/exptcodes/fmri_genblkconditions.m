function [stimorder, isrep, blkid] = genblkconditions(nimages, nstimperblk, n1backs, nreps, nfixheadtail, nfixwashout)

% fixation block at the begining of the localizer run
stimorder(1:nfixheadtail,1) = 0;
isrep(1:nfixheadtail,1) = 0;
blkid(1:nfixheadtail,1) = 0;

nblks = length(nimages);

for rid = 1:nreps % repetitions
    blks = randperm(nblks, nblks);
    for bid = blks % localizer blocks
        
        qrep = datasample(1:nstimperblk, n1backs, 'Replace', false);
        qstim = datasample(1:nimages(bid), nstimperblk, 'Replace', false);
        
        for sid = 1:nstimperblk
            blkid(end+1,1) = bid;
            stimorder(end+1,1) = qstim(sid);
            isrep(end+1,1) = 0;
            if any(qrep == sid)
                blkid(end+1,1) = bid;
                stimorder(end+1,1) = qstim(sid);
                isrep(end+1,1) = 1;
            end
        end
        
        % fixation block at the end of one localizer block
        stimorder(end+1:end+nfixwashout,1) = 0;
        isrep(end+1:end+nfixwashout,1) = 0;
        blkid(end+1:end+nfixwashout,1) = 0;
        
    end
end

% fixation block at the end of the localizer run
stimorder(end+1:end+nfixheadtail,1) = 0;
isrep(end+1:end+nfixheadtail,1) = 0;
blkid(end+1:end+nfixheadtail,1) = 0;

end