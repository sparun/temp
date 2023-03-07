% adds neuron data from L2_data into L2_str
function L2_str = addL2(L2_data, L2_str, overwriteflag)
if ~exist('overwriteflag') | isempty(overwriteflag), overwriteflag = 0; end
f1 = fieldnames(L2_str);
f2 = fieldnames(L2_str.specs); 
f3 = fieldnames(L2_str.specs.data_files); 
for neuron = 1:length(L2_data.neuron_id)
    num_neurons = length(L2_str.neuron_id);
    neuron_L2 = strmatch(L2_data.neuron_id{neuron},L2_str.neuron_id); 
    if(~isempty(neuron_L2))
        if overwriteflag == 1,
            add_str = 'neuron_L2';
            disp('      Overwriting data in L2_str');
        else
            disp('      Skipping: data already exists in L2_str');
            continue;
        end
    else
        add_str = 'end+1';
        disp('      Updating data in L2_str');
    end
    
    % level 1 addition
    for i = 1:length(f1)
        L2_field = eval(['L2_str.' f1{i} ';']);
        if ischar(L2_field) | strcmp(f1(i), 'items') == 1 | strcmp(f1(i), 'grouped_items') == 1 | strcmp(f1(i), 'groups') == 1 | strcmp(f1(i), 'specs') == 1 | strcmp(f1(i), 'fields') == 1
            continue;
        elseif isvector(L2_field) & size(L2_field,1) == num_neurons
            eval(['L2_str.' f1{i} '(' add_str ',:) = L2_data.' f1{i} '(neuron,:);']);
        elseif size(L2_field,1) == num_neurons
            q = find(eval(['L2_data.' f1{i}]) ~= 0);
            eval(['L2_str.' f1{i} '(' add_str ',q) = L2_data.' f1{i} '(q);']);
        end
    end
    
    % level 2 addition
    for j = 1:length(f2)
        specs_field = eval(['L2_str.specs.' f2{j} ';']);
        if strcmp(f2(j), 'item_filenames') == 1 | strcmp(f2(j), 'data_files') == 1 | strcmp(f2(j), 'nitms_per_grp') == 1 | strcmp(f2(j), 'fields') == 1 | strcmp(f2(j), 'spk_window') | strcmp(f2(j), 'baseline_spk_window') | strcmp(f2(j), 'qsite') == 1 | strcmp(f2(j), 'filter_type') == 1 | strcmp(f2(j), 'lowcut_freq') | strcmp(f2(j), 'creation_info') | strcmp(f2(j), 'mfiles') == 1
            continue;
        elseif isvector(specs_field) & size(specs_field,1) == num_neurons
            eval(['L2_str.specs.' f2{j} '(' add_str ',:) = L2_data.specs.' f2{j} '(neuron,:);']);
        elseif size(specs_field,1) == num_neurons
            q = find(eval(['L2_data.specs.' f2{j}]) ~= 0);
            eval(['L2_str.specs.' f2{j} '(' add_str ',q) = L2_data.specs.' f2{j} '(q);']);
        end
    end
    
    % level 3 addition
    for k = 1:length(f3)
        datafiles_field = eval(['L2_str.specs.data_files.' f3{k} ';']);
        if strcmp(f3(k), 'fields') == 1
            continue;
        elseif size(datafiles_field,1) == num_neurons
            eval(['L2_str.specs.data_files.' f3{k} '(' add_str ',1) = L2_data.specs.data_files.' f3{k} '(neuron);']);
        end
    end
end

for site = 1:length(L2_data.specs.site_id)
    num_sites = length(L2_str.specs.site_id);
    site_L2 = strmatch(L2_data.specs.site_id{site},L2_str.specs.site_id); 
    if(~isempty(site_L2))
        if overwriteflag == 1,
            add_str = 'site_L2';
            disp('      Overwriting data in L2_str');
        else
            disp('      Skipping: data already exists in L2_str');
            continue;
        end
    else
        add_str = 'end+1';
        disp('      Updating data in L2_str');
    end
    
    % level 1 addition
    for i = 1:length(f1)
        L2_field = eval(['L2_str.' f1{i} ';']);
        if ischar(L2_field) | strcmp(f1(i), 'items') == 1 | strcmp(f1(i), 'grouped_items') == 1 | strcmp(f1(i), 'groups') == 1 | strcmp(f1(i), 'specs') == 1 | strcmp(f1(i), 'fields') == 1
            continue;
        elseif isvector(L2_field) & size(L2_field,1) == num_sites
            eval(['L2_str.' f1{i} '(' add_str ',:) = L2_data.' f1{i} '(site,:);']);
        elseif size(L2_field,1) == num_sites
            q = find(eval(['L2_data.' f1{i}]) ~= 0);
            eval(['L2_str.' f1{i} '(' add_str ',q) = L2_data.' f1{i} '(q);']);
        end
    end
    
    % level 2 addition
    for j = 1:length(f2)
        specs_field = eval(['L2_str.specs.' f2{j} ';']);
        if strcmp(f2(j), 'item_filenames') == 1 | strcmp(f2(j), 'data_files') == 1 | strcmp(f2(j), 'nitms_per_grp') == 1 | strcmp(f2(j), 'fields') == 1 | strcmp(f2(j), 'spk_window') | strcmp(f2(j), 'baseline_spk_window') | strcmp(f2(j), 'qsite') == 1 | strcmp(f2(j), 'filter_type') == 1 | strcmp(f2(j), 'lowcut_freq') | strcmp(f2(j), 'creation_info') | strcmp(f2(j), 'mfiles') == 1
            continue;
        elseif isvector(specs_field) & size(specs_field,1) == num_sites
            eval(['L2_str.specs.' f2{j} '(' add_str ',:) = L2_data.specs.' f2{j} '(site,:);']);
        elseif size(specs_field,1) == num_sites
            q = find(eval(['L2_data.specs.' f2{j}]) ~= 0);
            eval(['L2_str.specs.' f2{j} '(' add_str ',q) = L2_data.specs.' f2{j} '(q);']);
        end
    end
    
    % level 3 addition
    for k = 1:length(f3)
        datafiles_field = eval(['L2_str.specs.data_files.' f3{k} ';']);
        if strcmp(f3(k), 'fields') == 1
            continue;
        elseif size(datafiles_field,1) == num_sites
            eval(['L2_str.specs.data_files.' f3{k} '(' add_str ',1) = L2_data.specs.data_files.' f3{k} '(site);']);
        end
    end
end

L2_str = sortL2(L2_str);
return