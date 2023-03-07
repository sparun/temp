% sorts L2_str
function L2_str = sortL2(L2_str)

f1 = fieldnames(L2_str);
f2 = fieldnames(L2_str.specs); 
f3 = fieldnames(L2_str.specs.data_files); 

[xx, sortid] = sort(L2_str.neuron_id); 
num_neurons = length(L2_str.neuron_id); 

% sorting level 1
for i = 1:length(f1)
    field_val = eval(['L2_str.' f1{i}]);
    % the sort skip list
    if strcmp(f1{i}, 'expt_name') | strcmp(f1{i}, 'items') | strcmp(f1(i), 'groups') | strcmp(f1{i}, 'specs') | strcmp(f1{i}, 'fields')
        continue;
    elseif size(field_val,1) == num_neurons
        eval(['L2_str.' f1{i} '= L2_str.' f1{i} '(sortid,:);']); 
    end
end

% sorting level 2
for i = 1:length(f2)
    field_val = eval(['L2_str.specs.' f2{i}]); 
    % the sort skip list
    if strcmp(f2{i}, 'item_filenames') | strcmp(f2{i}, 'nitms_per_grp') | strcmp(f2{i}, 'spk_window') | strcmp(f2{i}, 'baseline_spk_window') | strcmp(f2{i}, 'data_files') | strcmp(f2{i}, 'fields') | strcmp(f2(i), 'filter_type') == 1 | strcmp(f2(i), 'lowcut_freq') | strcmp(f2(i), 'creation_info') | strcmp(f2(i), 'mfiles') == 1
        continue;
    elseif size(field_val,1) == num_neurons
        eval(['L2_str.specs.' f2{i} '= L2_str.specs.' f2{i} '(sortid,:);']); 
    end
end

% sorting level 3
for i = 1:length(f3)
    field_val = eval(['L2_str.specs.data_files.' f3{i}]);
    % the sort skip list
    if strcmp(f3{i}, 'fields')
        continue;
    elseif size(field_val,1) == num_neurons
        eval(['L2_str.specs.data_files.' f3{i} '= L2_str.specs.data_files.' f3{i} '(sortid,:);']); 
    end
end

[xx, sortid] = sort(L2_str.specs.site_id); 
num_sites = length(L2_str.specs.site_id); 

% sorting level 1
for i = 1:length(f1)
    field_val = eval(['L2_str.' f1{i}]);
    % the sort skip list
    if strcmp(f1{i}, 'expt_name') | strcmp(f1{i}, 'items') | strcmp(f1(i), 'groups') | strcmp(f1{i}, 'specs') | strcmp(f1{i}, 'fields')
        continue;
    elseif size(field_val,1) == num_sites
        eval(['L2_str.' f1{i} '= L2_str.' f1{i} '(sortid,:);']); 
    end
end

% sorting level 2
for i = 1:length(f2)
    field_val = eval(['L2_str.specs.' f2{i}]); 
    % the sort skip list
    if strcmp(f2{i}, 'item_filenames') | strcmp(f2{i}, 'nitms_per_grp') | strcmp(f2{i}, 'spk_window') | strcmp(f2{i}, 'baseline_spk_window') | strcmp(f2{i}, 'data_files') | strcmp(f2{i}, 'fields') | strcmp(f2(i), 'filter_type') == 1 | strcmp(f2(i), 'lowcut_freq') | strcmp(f2(i), 'creation_info') | strcmp(f2(i), 'mfiles') == 1
        continue;
    elseif size(field_val,1) == num_sites
        eval(['L2_str.specs.' f2{i} '= L2_str.specs.' f2{i} '(sortid,:);']); 
    end
end

% sorting level 3
for i = 1:length(f3)
    field_val = eval(['L2_str.specs.data_files.' f3{i}]);
    % the sort skip list
    if strcmp(f3{i}, 'fields')
        continue;
    elseif size(field_val,1) == num_sites
        eval(['L2_str.specs.data_files.' f3{i} '= L2_str.specs.data_files.' f3{i} '(sortid,:);']); 
    end
end

siteids = cellfun(@(x) x(1:6), L2_str.neuron_id, 'UniformOutput', false);
L2_str.specs.qsite = manystrmatch(siteids, L2_str.specs.site_id);

return