% removes redundant specs information from L2_str
%
% instructions
% ------------
% load the L2_str and call this script
% save the L2_str after running this script
% ------------------------------------------------

data_files_str = struct(...
    'plxfile', [],...
    'itmfile', [],...
    'cndfile', [],...
    'timfile', [],...
    'grpfile', [],...
    'fields', []);
n=0;
n=n+1; data_files_str.fields{n,1} = 'plxfile = plexon data file';
n=n+1; data_files_str.fields{n,1} = 'itmfile = cortex items file';
n=n+1; data_files_str.fields{n,1} = 'cndfile = cortex conditions file';
n=n+1; data_files_str.fields{n,1} = 'timfile = cortex timing file';
n=n+1; data_files_str.fields{n,1} = 'grpfile = condition groups file';

val_str = struct(...
    't_beg', [],...
    't_end', [],...
    'eyedata', [],...
    'x_transform', [],...
    'y_transform', [],...
    'fields', []);
n=0;
n=n+1; val_str.fields{n,1} = 't_beg       = validation start time';
n=n+1; val_str.fields{n,1} = 't_end       = validation end time';
n=n+1; val_str.fields{n,1} = 'eyedata     = ISCAN eye data';
n=n+1; val_str.fields{n,1} = 'x_transform = x transformation coefficient';
n=n+1; val_str.fields{n,1} = 'y_transform = y transformation coefficient';

L2specs = struct(...
    'site_id', [],...
    'expt_version', [],...
    'AP', [],...
    'ML', [],...
    'depth', [],...
    'item_filenames', [],...
    'nitms_per_grp', [],...
    'spk_window', [],...
    't_on_off', [],...
    'onoff_stats', [],...
    'fix_stats', [],...
    'val_data', struct(val_str),...
    'qsite', [],...
    'filter_type', [],...
    'lowcut_freq', [],...
    'waveforms', [],...
    'data_files', struct(data_files_str),...
    'fields', []);

uniquesites = unique(cellfun(@(x) x(1:6),L2_str.neuron_id,'UniformOutput',0));
for siteid = 1:length(uniquesites)
    qcell = manystrmatch(uniquesites{siteid}, L2_str.neuron_id);
    qcell = qcell(1); % first neuron at the site
    
    L2specs.site_id{siteid,1} = uniquesites{siteid};
    L2specs.expt_version{siteid,1} = L2_str.specs.expt_version{qcell};
    L2specs.AP(siteid,1) = L2_str.specs.AP(qcell);
    L2specs.ML(siteid,1) = L2_str.specs.ML(qcell);
    L2specs.depth(siteid,1) = L2_str.specs.depth(qcell);
    L2specs.t_on_off{siteid,1} = L2_str.specs.t_on_off{qcell};
    L2specs.onoff_stats{siteid,1} = L2_str.specs.onoff_stats{qcell};
    L2specs.fix_stats{siteid,1} = L2_str.specs.fix_stats{qcell};
    L2specs.val_data(siteid,1) = L2_str.specs.val_data(qcell);
    L2specs.data_files.plxfile{siteid,1} = L2_str.specs.data_files.plxfile{qcell};
    L2specs.data_files.itmfile{siteid,1} = L2_str.specs.data_files.itmfile{qcell};
    L2specs.data_files.cndfile{siteid,1} = L2_str.specs.data_files.cndfile{qcell};
    L2specs.data_files.timfile{siteid,1} = L2_str.specs.data_files.timfile{qcell};
end
L2specs.data_files.fields = L2_str.specs.data_files.fields;

siteids = cellfun(@(x) x(1:6), L2_str.neuron_id, 'UniformOutput', false);
L2specs.qsite = manystrmatch(siteids, L2specs.site_id);

L2specs.item_filenames = L2_str.specs.item_filenames;
L2specs.nitms_per_grp = L2_str.specs.nitms_per_grp;
L2specs.spk_window = L2_str.specs.spk_window;
L2specs.filter_type = L2_str.specs.filter_type;
L2specs.lowcut_freq = L2_str.specs.lowcut_freq;
L2specs.waveforms = L2_str.specs.waveforms;

n=0;
n=n+1; L2specs.fields{n,1} = 'site_id             = site id = monkey name + track id + track location';
n=n+1; L2specs.fields{n,1} = 'expt_version        = per site experiment version a/b/c/etc.';
n=n+1; L2specs.fields{n,1} = 'AP                  = per site anterior-posterior location of electrode';
n=n+1; L2specs.fields{n,1} = 'ML                  = per site medial temporal location of electrode';
n=n+1; L2specs.fields{n,1} = 'depth               = per site electrode depth';
n=n+1; L2specs.fields{n,1} = 'item_filenames      = item filenames';
n=n+1; L2specs.fields{n,1} = 'nitms_per_grp       = number of items per group';
n=n+1; L2specs.fields{n,1} = 'spk_window          = time window in which spikes are collected; relative to stimulus onset';
n=n+1; L2specs.fields{n,1} = 't_on_off            = per site stimulus on & off times relative to the start of the experiment';
n=n+1; L2specs.fields{n,1} = 'onoff_stats         = per site on-off stats [mean(ton1) mean(toff1) std(ton1) std(toff1) mean(ton2) mean(toff2) std(ton2) std(toff2);]';
n=n+1; L2specs.fields{n,1} = 'fix_stats           = per site fixation statistics (x & y : min, max, mean, std)';
n=n+1; L2specs.fields{n,1} = 'val_data            = per site validation data';
n=n+1; L2specs.fields{n,1} = 'qsite               = per neuron index into L2_str.specs.site_id';
n=n+1; L2specs.fields{n,1} = 'filter_type         = high-pass filter used during sorting';
n=n+1; L2specs.fields{n,1} = 'lowcut_freq         = lowcut frequency used during sorting';
n=n+1; L2specs.fields{n,1} = 'waveforms           = mean and standard deviation of waveforms from each neuron';
n=n+1; L2specs.fields{n,1} = 'data_files          = per site data files';

L2_str.specs = L2specs;