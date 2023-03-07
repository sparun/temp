% adds neuron data from L2_data into L2_str
function L2_str = delL2(neuron_id, L2_str)
if(ischar(neuron_id))
    tmp = neuron_id; neuron_id = [];
    neuron_id{1} = tmp;
end
f1 = fieldnames(L2_str);
f2 = fieldnames(L2_str.specs);
f3 = fieldnames(L2_str.specs.data_files);

qneurons = manystrmatch(neuron_id,L2_str.neuron_id); % ids of neurons to remove
qremainingneurons = setdiff(1:length(L2_str.neuron_id), qneurons);
remainingneurons = L2_str.neuron_id(qremainingneurons);
qremainingsites = manystrmatch(unique(cellfun(@(x) x(1:6), L2_str.neuron_id(qremainingneurons), 'UniformOutput', false)), L2_str.specs.site_id);
qsites = setdiff(1:length(L2_str.specs.site_id), qremainingsites);  % ids of sites to remove

num_sites = length(L2_str.specs.site_id);
num_neurons = length(L2_str.neuron_id);

% level 1 deletion
for i = 1:length(f1)
    L2_field = eval(['L2_str.' f1{i} ';']);
    if ischar(L2_field) | strcmp(f1(i), 'items') == 1 | strcmp(f1(i), 'grouped_items') == 1 | strcmp(f1(i), 'groups') == 1 | strcmp(f1(i), 'specs') == 1 | strcmp(f1(i), 'fields') == 1
        continue;
    elseif size(L2_field,1) == num_neurons
        eval(['L2_str.' f1{i} '(qneurons) = [];']);
    elseif size(L2_field,1) == num_sites
        eval(['L2_str.' f1{i} '(qsites) = [];']);
    end
end

% level 2 deletion
for j = 1:length(f2)
    specs_field = eval(['L2_str.specs.' f2{j} ';']);
    if strcmp(f2(j), 'item_filenames') == 1 | strcmp(f2(j), 'data_files') == 1 | strcmp(f2(j), 'nitms_per_grp') == 1 | strcmp(f2(j), 'fields') == 1 | strcmp(f2(j), 'spk_window') | strcmp(f2(j), 'filter_type') == 1 | strcmp(f2(j), 'lowcut_freq') | strcmp(f2(j), 'creation_info') | strcmp(f2(j), 'mfiles') | strcmp(f2(j), 'creation_info') | strcmp(f2(j), 'mfiles') == 1
        continue;
    elseif size(specs_field,1) == num_neurons
        eval(['L2_str.specs.' f2{j} '(qneurons) = [];']);
    elseif size(specs_field,1) == num_sites
        eval(['L2_str.specs.' f2{j} '(qsites) = [];']);
    end
end

% level 3 deletion
for k = 1:length(f3)
    datafiles_field = eval(['L2_str.specs.data_files.' f3{k} ';']);
    if strcmp(f3(k), 'fields') == 1
        continue;
    elseif size(datafiles_field,1) == num_neurons
        eval(['L2_str.specs.data_files.' f3{k} '(qneurons) = [];']);
    elseif size(datafiles_field,1) == num_sites
        eval(['L2_str.specs.data_files.' f3{k} '(qsites) = [];']);
    end
end
end