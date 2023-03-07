% one-back event related

function [stimorder, isrep, evtid] = fmri_genevtconditions(runid, nfixheadtail, nfixevts,nimages)

% fixation block at the begining of the localizer run
stimorder(1:nfixheadtail,1) = 0;
isrep(1:nfixheadtail,1) = 0;
evtid(1:nfixheadtail,1) = 0;

stimbag = mat2cell(reshape(1:64, 8, 8)', ones(1,8), 8);
q1back = cellfun(@(x) x(runid), stimbag);

xx = num2cell(randperm(nimages))';
yy = cell(nimages,1);
qfix = datasample(1:nimages, nfixevts, 'Replace', false);
for eid = 1:nimages
    yy{eid} = 0;
    if sum(ismember(q1back, xx{eid})), xx{eid} = [xx{eid};xx{eid}]; yy{eid} = [yy{eid}; 1]; end
    if find(qfix == eid), xx{eid} = [0; xx{eid}]; yy{eid} = [0; yy{eid}]; end
end
stimorder = [stimorder; cell2mat(xx)];
isrep = [isrep; cell2mat(yy)];
evtid = [evtid; cell2mat(xx) ~= 0];

% fixation block at the end of the localizer run
stimorder(end+1:end+nfixheadtail,1) = 0;
isrep(end+1:end+nfixheadtail,1) = 0;
evtid(end+1:end+nfixheadtail,1) = 0;

end