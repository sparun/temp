% get depth values for each channel in a Uprobe recording

% Change log
% 09 May 2015 ARM First version
% 26 May 2015 SPA Incorporated into lib, sending depth as output
% 15 Dec 2015 ZAK Updated to handle new L2_str.specs organized as per sites

function newdepth = getL2uprobedepth(L2_str)

chnum = str2num(cell2mat(cellfun(@(x) x(10:11),L2_str.neuron_id,'UniformOutput',false)));

siteids = cellfun(@(x) x(1:6), L2_str.neuron_id, 'UniformOutput', false);
qsite = manystrmatch(siteids, L2_str.specs.site_id);
depth = L2_str.specs.depth(qsite); % depth

% Uprobe specs: ch24 is 800 um from the top, inter electrode distance is 100um
for nid = 1:length(chnum)
    nchid = chnum(nid);
    diff = 800 + 100*abs(24-nchid); % This is the difference from the actual depth
    newdepth(nid,1) = depth(nid,1)-diff; % This is the new depth
end

end

