% L2_str = plx2L2(lowcut_freq, plx_filespec, raw_plx_folder, spk_window, L2_folder, overwriteflag, stimfolder, processeye_flag, add_all_trials)
%
% INPUTS
%       lowcut_freq     : lowcut frequency used during sorting
%       plx_filespec    : plx file(s) can be specified in one of the following ways
%                             a) name      : hu007a_1.plx
%                             b) full path : d:\data\hugo\plxdata\hu007a_1.plx
%                             c) wildcard  : d:\data\hugo\plxdata\hu007a_*.plx or hu007*.plx
%       raw_plx_folder  : folder where the raw files are located
%                         if not specified, units file will be assumed to contain continuous eye data too
%       spk_window      : time window for collecting spikes
%                         if specified as a 2-element vector, it will be
%                         applied to every stimulus
%                         if specified as an <nstim x 2> array, each row
%                         will be treated as the spike window for each
%                         stimulus
%                         default is [-0.1 0.4], i.e. from 100 ms before
%                         stimulus onset to 400 ms after stimulus onset
%       L2_folder       : If a relevant L2_data is found in this folder, it
%                         will be updated.  Otherwise a new L2_data will be
%                         stored in this folder.
%       overwriteflag   : if neuron already exists in L2_str
%                         1 indicates overwriting data in L2_str
%                         0 indicates skipping the neuron
%                         If unspecified, no L2_data will be updated
%       stimfolder      : folder in which all the stimuli for all experiments are located
%       processeye_flag : 1 indicates that eye data should be processed
%                        0, otherwise.
%       add_all_trials : 1 indicates that both correct/incorrect trials should be processed
%                        0 indicates that only correct trials should be processsed
% OUTPUTS
%    1) L2_str - will contain the new or the updated L2_str
%
% USAGE
%    For processing multiple plx/pl2 files in the current folder:
%         L2_str = plx2L2(250, '*.pl', [], [], [], 1, 'H:\Zhivago\ctxrcv\', 1);
%
% DESCRIPTION
%      Extracts the data from the specified .plx file(s) into the
%      L2_str format is returned as the output parameter.
%      By default, the L2_str for the relevant experiment is not updated
%      and the eye data is not processed.
%      The L2_str's of all the experiments are stored in the same folder.
%      The mat files containing the L2_str's of the experiments are named
%      as per the following convention:
%               L2_<experiment name>.mat
%      The experiment names can be found in mkprognames.m.
%
%      It is assumed that a plx file contains data for ONLY ONE experiment.
%
%      For a given experiment, a plx/pl2 file may contain data from one or many
%      channels.
%
%      For a given channel, there may be one or more units, with each unit
%      denoting data from a single neuron.
%
%      One L2_str can hold all the data for one experiment.
%
%      Experiment data comprises of the following:
%
%          - neuron information (neuron id, AP/ML coordinates, electrode depth, etc.)
%          - stimuli
%          - conditions
%          - spike times
%          - on/off times and associated statistics
%          - fixation statistics
%          - validation data
%          - response correctness
%          - plx/ctx/group file names, etc.
%
% Let nt = # of tracks
%     nn = # of neurons
%     ns = # of stimuli
%     np = # of stimulus presentations in a trial
%     nd = 1 + (# of lib programs plx2L2.m depends upon)
%
%     Spike data in the L2_str is organized in the following fashion.
%
%          [neuron 1]  -> [stimulus 1]  -> [trial 1]
%                                       -> [trial 2]
%                                          ...
%                                       -> [trial np]
%                      -> [stimulus 2]  -> [trial 1]
%                                          ...
%                                       -> [trial np]
%                          ..........
%                         ..........
%                      -> [stimulus ns] -> [trial 1]
%                                          ...
%          ..........
%          ..........
%          [neuron nn] -> [stimulus 1]  -> [trial 1]
%                                           ...
% L2 STRUCTURE FORMAT
%        L2_data
%        |___ expt_name           : string
%        |___ items               : ni x 1 cell
%        |___ neuron_id           : nn x 1 cell
%        |___ spikes              : nn x 1 cell
%        |___ response_correct    : nn x 1 cell
%        |___ specs               : 1  x 1 struct
%             |___ expt_version   : nt x 1 cell
%             |___ AP             : nt x 1 double}
%             |___ ML             : nt x 1 double}
%             |___ depth          : nt x 1 double]
%             |___ item_filenames : nt x 1 cell
%             |___ nitms_per_grp  : 1  x 1 double
%             |___ spk_window     : 1  x 2 double 
%             |___ t_on_off       : nt x 1 cell
%             |___ onoff_stats    : nt x 1 cell
%             |___ fix_stats      : nt x 1 cell
%             |___ val_data       : nt x 1 struct
%             |___ filter_type    : 1 x 1 double
%             |___ lowcut_freq    : string
%             |___ waveforms      : nn x 1 cell
%             |___ data_files     : 1  x 1 struct
%             |   |___ plxfile    : nn x 1 cell
%             |   |___ itmfile    : nn x 1 cell
%             |   |___ cndfile    : nn x 1 cell
%             |   |___ timfile    : nn x 1 cell
%             |   |___ grpfile    : nn x 1 cell
%             |___ creation_info  : string
%             |___ mfiles         : 1  x 1 struct (with nd string fields)

% ChangeLog
%   28 Aug 2011 - ZAK/SPA - First version in series1
%   28 Aug 2014 - ZAK     - Updated for series2 to work with pl2 files
%   09 Feb 2015 - ZAK     - Updated to include mua 
%   07 May 2015 - ZAK     - Trials arranged as correct ones followed by incorrect ones
%                           Valid trial block defined between PLEXON_START & EYEDATA_STOP
%                           instead of between PLEXON_START & PLEXON_STOP
%   15 Dec 2015 - ZAK     - Added inter-trial baseline activity
%                         - Removed redundant per neuron specs and organized as per site specs
%   02 Apr 2016 - ZAK     - Fixed the bug where response_correct was incorrectly ordered by the 1st neuron in the track
%                         - Added a field under specs for storing information about L2 creation
%                         - Added L2_str.specs.mfiles substructure for storing plx2L2.m and all dependent programs
%                           To recreate each file, run L2_str.specs.mfiles.plx2L2 and save the command line output as a separate file
%                         - Added code to handle incorrect track information in ka122b_04_rela.plx

function L2_str = plx2L2(lowcut_freq, plx_filespec, raw_plx_folder, spk_window, L2_folder, overwriteflag, stimfolder, processeye_flag, add_all_trials)
dbstop if error;
clear global;

% loading event code definitions
readplxh;
save('plxh');

% event code definitions, event codes, L2 structure
global C event_codes L2_data std_items std_item_names;

C = load('plxh');

% setting the defaults, if necessary
if ~exist('spk_window') | isempty(spk_window), spk_window = [-.1 0.4]; end
if ~exist('overwriteflag') | isempty(overwriteflag), overwriteflag = 0; end
if ~exist('processeye_flag') | isempty(processeye_flag), processeye_flag = 0; end
if ~exist('add_all_trials') | isempty(add_all_trials), add_all_trials = 0; end
if ~exist('L2_folder') | isempty(L2_folder), L2_folder = '.'; end

splitem_progs = {'dtxct', 'ord', 'prime', 'size'};

% processing the plx file specification
plx_list = dir(plx_filespec); n_plx = length(plx_list);
q = strfind(plx_filespec, '\');
if ~isempty(q)
    units_plx_folder = plx_filespec(1:q(end));
else
    units_plx_folder = './';
end

if ~exist('raw_plx_folder') | isempty(raw_plx_folder)
    raw_plx_folder = units_plx_folder;
end

% processing each plx file
for file_id = 1:n_plx
    L2_str = [];
    plxname = plx_list(file_id).name;
    
    disp(' ');
    disp(['Selecting ' plxname]);
    
    neuron_id = plxname(1:6);
    
    q_ = find(plxname == '_'); n_ = length(q_);
    qutag = strfind(plxname, 'units'); isutag = ~isempty(qutag);
    
    if n_ == 2
        qdot = find(plxname == '.');
        xx = plxname(1:qdot-1);
    elseif isutag
        xx = plxname(1:qutag-2);
    else
        fprintf('There seems to be an issue with units filename. Skipping this file... \n');
        continue;
    end
    
    if exist([raw_plx_folder xx '.pl2'], 'file')
        rawplxname = [xx '.pl2'];
    elseif exist([raw_plx_folder xx '.plx'], 'file')
        rawplxname = [xx '.plx'];
    else
        fprintf('Unable to locate the raw plx/pl2 file. Skipping this file... \n');
        continue;
    end
    
    q1 = find(rawplxname == '_'); q1 = q1(end)+1;
    q2 = find(rawplxname == '.'); q2 = q2 - 2;
    prog_name = plxname(q1:q2);
    
    % loading L2_str if it exists and taking care of special item file scenario
    L2_str_exists = 0;
    splitem_flag = 0;
    std_items = cell(0); std_item_names = cell(0);
    if ~isempty(L2_folder)
        L2_str_name = ['L2_' prog_name '.mat'];
        L2_str_fullname = [L2_folder '\' L2_str_name];
        if exist(L2_str_fullname) ~= 0
            L2_str_exists = 1;
            load(L2_str_fullname);
        end
        if any(strcmp(splitem_progs, prog_name))
            splitem_flag = 1;
            load_std_itms(prog_name, stimfolder);
        end
    end
    
    % skipping existing neuron if overwriteflag is set
    if ~isempty(L2_str) & any(strcmp(neuron_id, L2_str.neuron_id)) & overwriteflag == 0
        disp('   Skipping : neuron already exists in L2_str');
        continue;
    end
    
    ishugo = 0; if strncmpi(plxname, 'hu', 2) == 1, ishugo = 1; end
    
    % loading program names
    mkprognames(ishugo);
    
    % preparing the plx file names with path
    plx_file = [raw_plx_folder rawplxname];    
    sorted_plx_file = [units_plx_folder plxname];
    
    disp(['Processing ' sorted_plx_file]);
     
    % reading event codes from the plx file
    readeventcodes(sorted_plx_file);
    
    % further processing cannot happen without a valid program id
    prog_id = get_prog_id();
    if isempty(prog_id)
        disp([sorted_plx_file ' does not have a valid program ID']);
        plx_close(sorted_plx_file);
        continue;
    end
    prog_name = C.progname{prog_id - C.PROG_ID_START, 1};
    fprintf('Experiment Name: %s\n', upper(prog_name));
    
    % there will be one xfer segment per plx file, i.e. per experiment per neuron
    % processing the xfer segment and extracting the header and files
    header = process_xfer_block(plxname, prog_id, event_codes, stimfolder, [], ishugo, 0, std_item_names);
    if isempty(header) | header.valid == 0, disp('ERROR: Incomplete header!!!'); plx_close(sorted_plx_file); continue; end
    
    if strcmp(plxname, 'ka122b_04_rela.plx') == 1
        header.track_id = 122;
        header.site_id = 'ka122b';
    end
    
    % returning if the necessary information for L2_data set-up is missing
    if isempty(header.prog_name) | isempty(header.site_id), fail_flag = 1; plx_close(sorted_plx_file); continue; end
    
    % loading condition groups, if any
    [header.cnd_grps header.grpfile] = load_cnd_grps(header.prog_name, header.version);
    
    % determining the # of channels and units
    tscounts = plx_info(sorted_plx_file, 1); tscounts = tscounts(2:end,2:end);
    chunitmap = tscounts ~= 0; channels = find(sum(chunitmap,1)~=0);
    
    % creating a new L2_data
    L2_data = []; setupL2(header, spk_window);
    
    % taking care of the validation blocks
    if processeye_flag == 1, process_val_blocks(plx_file); end
    
    % % plotting the fixation quality
    % if processeye_flag == 1 & val_flag == 1, fixqual(); end
    
    % processing each channel
    chno = 1;
    site_id = header.site_id;
    for channel = channels
        
        sitech_id = sprintf('%s_ch%02d', site_id, channel);
        
        % processing each unit
        units = find(chunitmap(:,channel) == 1)';
        for unit = units
            
            neuron_id = [sitech_id '_u' num2str(unit)];
            
            if unit > length(units) % MU detected
                neuron_id(end-1:end) = 'um'; % putting um to ensure mua appears after u1,u2 etc
            end
            
            disp(['Processing neuron ' num2str(unit) ': ' neuron_id]);
            
            L2_data.neuron_id{end+1,1} = neuron_id;
            
            if length(L2_data.neuron_id) > 1
                L2_data.spikes{end+1,1} = cell(0);
                L2_data.baseline_spikes{end+1,1} = cell(0);
                L2_data.response_correct{end+1,1} = cell(0);
                L2_data.specs.waveforms{end+1,1} = cell(0);
            end
            
            % adding mean and standard deviation of unit waveforms
            [nwaves, npts, waves_ts, waves] = plx_waves_v(sorted_plx_file, channel, unit);
            L2_data.specs.waveforms{end,1} = [mean(waves); std(waves)];
            
            % taking care of the trial blocks
            process_trial_blocks(sorted_plx_file, channel, unit, header.prog_id, header.cnds, header.cnd_grps, processeye_flag, add_all_trials);
        end
        chno = chno + 1;
    end
    
    if isempty(L2_data.groups),
        L2_data = rmfield(L2_data, 'groups');
        L2_data.specs.data_files = rmfield(L2_data.specs.data_files, 'grpfile');
    end
    if isempty(L2_data.item_ids),
        L2_data = rmfield(L2_data, 'item_ids');
    end
    
    if isempty(L2_str)
        L2_str = L2_data;
    else
        L2_str = addL2(L2_data, L2_str, overwriteflag);
    end
    
    L2_str.specs.filter_type = 'butterworth-4pole';
    L2_str.specs.lowcut_freq = lowcut_freq;
    
    % adding L2 creation information
    timestamp = datestr(now);
    computername = getenv('COMPUTERNAME');
    [~, xx] = dos('getmac'); macaddress = xx(160:176);
    L2_str.specs.creation_info = sprintf('%s %s [MAC: %s]', timestamp, computername, macaddress);
    
    % adding plx2L2 and all the programs it depends upon
    flist = matlab.codetools.requiredFilesAndProducts('plx2L2');
    for fid = 1:length(flist)
        if ~isempty(strfind(flist{fid}, 'plxmat609')), continue; end
        fprintf('adding %s\n', flist{fid});
        filestr = [];        
        filestr = sprintf('%s%% FILE: %s\n\n', filestr, flist{fid});
        xx = strsplit(flist{fid}, '\'); fieldname = xx{end}(1:end-2);        
        fp = fopen(flist{fid}); while(~feof(fp)), str = fgets(fp); if isspace(str(end)), str = str(1:end-1); end; filestr = [filestr str]; end; fclose(fp);
        eval(['L2_str.specs.mfiles.' fieldname ' = filestr;']);
    end
    
    if ~isempty(L2_folder), save(L2_str_fullname, 'L2_str'); end
    
    plx_close(sorted_plx_file);
end
delete('plxh.mat');
end

% loads the standard items in case item file is generated for each neuron
function load_std_itms(prog_name, stimfolder)
global std_items std_item_names;
flist = dir([stimfolder prog_name '*.bmp']);
nfiles = length(flist);
for i = 1:nfiles
    std_item_names{i,1} = flist(i).name;
    std_items{i,1} = imread([stimfolder flist(i).name]);
end
end

% loads the condition grouping matrix
function [cnd_grps grpfile] = load_cnd_grps(prog_name, prog_ver)
cnd_grps = [];
grpfile = ['cnd_grps_' prog_name prog_ver '.mat'];
if exist(grpfile), load(grpfile); else grpfile = []; end
end

% extracts the program id from the event codes read from the plx file
% the assumption here is that a plx file will contain data pertaining to only one experiment 
function prog_id = get_prog_id
global C event_codes;
prog_id = event_codes(event_codes > C.PROG_ID_START & event_codes <= C.PROG_ID_END);
if ~isempty(prog_id) & ~all(prog_id == C.PROG_ID_START + C.PROG_ID.EYE)
    q = find(prog_id ~= C.PROG_ID_START + C.PROG_ID.EYE); q = q(1);
    prog_id = prog_id(q);
end
end

% Calculates the mean and standard deviations of stimulus off times for
% every stimulus in a group
function calc_onoff_stats(t_on, t_off, ngrps, nitms_per_grp)
global L2_data;
for grp_id = 1:ngrps
    tmp_stats = [];
    for itm_id = 1:nitms_per_grp
        tmp_stats = [tmp_stats mean(t_on{grp_id,itm_id}) mean(t_off{grp_id,itm_id}) std(t_on{grp_id,itm_id}) std(t_off{grp_id,itm_id})];
    end
    onoff_stats(grp_id,:) = tmp_stats;
end
L2_data.specs.onoff_stats{end,1} = onoff_stats;
end

% sets up the L2_data to add data pertaining to a neuron and the
% experiment that's run on the neuron
%     - L2_folder is the folder where the existing L2_data may be found or
%       the folder where the newly created L2_data should be saved
%     - header should have at least the program id/name and neuron id
%     - ctx_folder is the folder where all the cortex files - i.e.
%       itm/cnd files - are located
%     - grp_flag = 0 indicates absence of stimulus grouping, and
%       grp_flag = 1, otherwise
%     - fail_flag is set to 1 if L2_data alreadt contains data from the current
%       neuron under processing
%     - L2_str_name will contain the name of the mat file in which the
%       L2_data resides or will reside
%     - current_neuron will be the index into the L2_data for the neuron
%       under consideration
function setupL2(header, spk_window)
global L2_data std_items std_item_names;
fail_flag = 0;

% create and initialize L2_data fields
L2_data = createL2str();
L2_data.expt_name = header.prog_name;
L2_data.specs.spk_window = spk_window;
L2_data.specs.val_data(end,1).t_beg = [];

L2_data.specs.site_id{1,1} = header.site_id;

L2_data.groups = [];
L2_data.spikes{1,1} = cell(0);
L2_data.baseline_spikes{1,1} = cell(0);
L2_data.response_correct{1,1} = cell(0);
L2_data.specs.fix_stats{1,1} = cell(0);
L2_data.specs.t_on_off{1,1} = cell(0);
L2_data.specs.onoff_stats{1,1} = cell(0);
L2_data.specs.waveforms{1,1} = cell(0);

L2_data.specs.baseline_spk_window = [0 .5];

% adding the ctx/plx file information
L2_data.specs.expt_version{1,1}       = header.version;
L2_data.specs.data_files.itmfile{1,1} = header.itmfile;
L2_data.specs.data_files.cndfile{1,1} = header.cndfile;
L2_data.specs.data_files.timfile{1,1} = header.timfile;
L2_data.specs.data_files.plxfile{1,1} = header.plxfile;
L2_data.specs.data_files.grpfile{1,1} = header.grpfile;
% adding depth and AP/ML information
L2_data.specs.depth(1,1) = header.depth;
L2_data.specs.AP(1,1) = header.AP;
L2_data.specs.ML(1,1) = header.ML;

ngrps = 0;
groups = [];
if isempty(header.cnd_grps)
    nitms_per_grp = 1;
else
    [groups ngrps nitms_per_grp] = prep_grp_itms_map(header.cnds, header.cnd_grps);
end

L2_data.specs.nitms_per_grp = nitms_per_grp;
L2_data.groups = groups;

% adding fields related to items
if isempty(header.item_ids)
    L2_data.items = header.itms;
    L2_data.specs.item_filenames = header.itm_names;
else
    L2_data.items = std_items;
    L2_data.specs.item_filenames = std_item_names;
    L2_data.item_ids{1,1} = header.item_ids;
end
end

% L2_data definition
%   - L2_data is the newly created L2_data
function L2_data = createL2str()
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

specs_str = struct(...
    'site_id', [],...
    'expt_version', [],...
    'AP', [],...
    'ML', [],...
    'depth', [],...
    'item_filenames', [],...
    'nitms_per_grp', [],...
    'spk_window', [],...
    'baseline_spk_window', [],...
    't_on_off', [],...
    'onoff_stats', [],...
    'fix_stats', [],...
    'val_data', struct(val_str),...
    'qsite', [],...
    'filter_type', [],...
    'lowcut_freq', [],...
    'waveforms', [],...
    'data_files', struct(data_files_str),...
    'creation_info', [],...
    'mfiles', [],...
    'fields', []);
n=0;
n=n+1; specs_str.fields{n,1} = 'site_id             = site id = monkey name + track id + track location';
n=n+1; specs_str.fields{n,1} = 'expt_version        = per site experiment version a/b/c/etc.';
n=n+1; specs_str.fields{n,1} = 'AP                  = per site anterior-posterior location relative to chamber center, mm (+ = anterior)';
n=n+1; specs_str.fields{n,1} = 'ML                  = per site medial-lateral location relative to chamber center, mm (+ = lateral)';
n=n+1; specs_str.fields{n,1} = 'depth               = per site micromanipulator depth relative to base of grid, mm';
n=n+1; specs_str.fields{n,1} = 'item_filenames      = item filenames';
n=n+1; specs_str.fields{n,1} = 'nitms_per_grp       = number of items per group';
n=n+1; specs_str.fields{n,1} = 'spk_window          = window during which spikes are collected relative to stimulus onset, in seconds';
n=n+1; specs_str.fields{n,1} = 'baseline_spk_window = window during which baseline spikes are collected relative to reward onset, in seconds';
n=n+1; specs_str.fields{n,1} = 't_on_off            = per site stimulus on & off times relative to the start of the experiment, in seconds';
n=n+1; specs_str.fields{n,1} = 'onoff_stats         = per site on-off stats [mean(ton1) mean(toff1) std(ton1) std(toff1) mean(ton2) mean(toff2) std(ton2) std(toff2);]';
n=n+1; specs_str.fields{n,1} = 'fix_stats           = per site fixation statistics (x & y : min, max, mean, std) in dva';
n=n+1; specs_str.fields{n,1} = 'val_data            = per site validation data';
n=n+1; specs_str.fields{n,1} = 'qsite               = per neuron index into L2_str.specs.site_id';
n=n+1; specs_str.fields{n,1} = 'filter_type         = high-pass filter used during sorting';
n=n+1; specs_str.fields{n,1} = 'lowcut_freq         = lowcut frequency used during sorting';
n=n+1; specs_str.fields{n,1} = 'waveforms           = mean and standard deviation of waveforms from each neuron';
n=n+1; specs_str.fields{n,1} = 'data_files          = per site raw data files';
n=n+1; specs_str.fields{n,1} = 'creation_info       = L2 creation date, time, pc name, and mac address';
n=n+1; specs_str.fields{n,1} = 'mfiles              = fields contain code for plx2L2.m and all dependent programs';

L2_data = struct(...
    'expt_name', [],...
    'items', [],...
    'item_ids', [],...
    'groups', [],...
    'neuron_id', [],...
    'spikes', [],...
    'baseline_spikes', [],...
    'response_correct', [],...
    'specs', struct(specs_str),...
    'fields', []);
n=0;
n=n+1; L2_data.fields{n,1} = 'expt_name        = experiment name';
n=n+1; L2_data.fields{n,1} = 'items            = downsampled itms';
n=n+1; L2_data.fields{n,1} = 'item_ids         = index into the items - for special item files';
n=n+1; L2_data.fields{n,1} = 'groups           = groups-to-items matrix';
n=n+1; L2_data.fields{n,1} = 'neuron_id        = neuron id = monkey name + track id + track location + channel id + unit id; unit id um means multi-unit activity';
n=n+1; L2_data.fields{n,1} = 'spikes           = spikes FROM 100ms before stimulus onset TO 400ms after stimulus offset; spike times are relative to stimulus onset';
n=n+1; L2_data.fields{n,1} = 'baseline_spikes  = spikes FROM REWARDED till 500 ms later; spike times are relative to the REWARDED marker';
n=n+1; L2_data.fields{n,1} = 'response_correct = corrext/incorrect response';
n=n+1; L2_data.fields{n,1} = 'specs            = specifications - header, plx/cortex/group filenames';
end

% processes a set of validation segments found in the plx file
% uses the eye data obtained from the validation points during the
% successful validation blocks for calibration purposes
% linear regression is used for calibrating eye data
%    - val_segs contains the indices necessary to extract each validation
%      segment from the event codes vector
function process_val_blocks(plx_file)
global event_codes event_codes_ts L2_data C;

siteid = L2_data.specs.site_id{1};
monkey = siteid(1:2);
trackid = str2double(siteid(3:5));

if strncmp(monkey, 'hu', 2)
    eyex_ch = 16; eyey_ch = 17;
elseif strncmp(monkey, 'ro', 2) | strncmp(monkey, 'xa', 2)
    eyex_ch = 48; eyey_ch = 49;
elseif strncmp(monkey, 'ka', 2) | strncmp(monkey, 'sa', 2)
    eyex_ch = 90; eyey_ch = 91;
end

if strncmp(siteid, 'ro002a', 6)
    val_pts = [-6 3; 6 3; 0 -3];
elseif strncmp(monkey, 'hu', 2) | strncmp(monkey, 'ro', 2) | strncmp(monkey, 'xa', 2)
    val_pts = [-11.36 0; 11.36 0; 0 -11.36];
elseif (strncmp(monkey, 'ka', 2) & trackid <= 46) | (strncmp(monkey, 'sa', 2) & trackid <= 11)
    val_pts = [-9 0; 9 0; 0 -11.36];
elseif (strncmp(monkey, 'ka', 2) & trackid >= 49 & trackid <= 50) | (strncmp(monkey, 'sa', 2) & trackid >= 12 & trackid <= 15)
    val_pts = [-11.36 0; 11.36 0; 0 -11.36];
else
    val_pts = [-9.9 0; 9.9 0; 0 -9.9];
end

% read analog eye data from the plx file
readplxeyedata(plx_file, eyex_ch, eyey_ch);
plx_close(plx_file);

% extracting the validation segments
[matchstart, matchend] = regexp(char(event_codes'),char([C.PLEXON_START ...
                                                         C.EYEDATA_START ...
                                                         (C.COND_ID_START + 3) ...
                                                         (C.PROG_ID_START + C.PROG_ID.EYE) ...
                                                         '.*?' ...
                                                         C.PLEXON_STOP]));
val_segs = [matchstart' matchend'];

% number of validation segments
nsegs = size(val_segs,1);

count = 1;

% processing each validation segment
for seg_no = 1:nsegs
    % teasing out one of the validation segment
    val_seg = event_codes(val_segs(seg_no,1):val_segs(seg_no,2));
    % timestamps for the markers sent during the validation block
    val_ts  = event_codes_ts(val_segs(seg_no,1):val_segs(seg_no,2));
    % only data from successful validation blocks will be used
    if ~isempty(regexp(char(val_seg'), char([C.PLEXON_START ...
                                             C.EYEDATA_START ...
                                             (C.COND_ID_START + 3) ...
                                             (C.PROG_ID_START + C.PROG_ID.EYE) ...
                                             C.LEFT_TARGET_ON:C.DOWN_TARGET_REWARD ...
                                             C.EYEDATA_STOP ...
                                             C.RESPONSE_CORRECT ...
                                             C.PLEXON_STOP])))
        
        % recording the start and end times of the validation block
        tstart = val_ts((val_seg == C.PLEXON_START)); tstart = tstart(end);
        L2_data.specs.val_data(end,1).t_beg(count,1) = tstart;
        L2_data.specs.val_data(end,1).t_end(count,1) = val_ts((val_seg == C.PLEXON_STOP));
        
        % collecting eye data for the left target [-6.0 3.0]
        t_beg = val_ts((val_seg == C.LEFT_TARGET_FIXATED));
        t_end = val_ts((val_seg == C.LEFT_TARGET_REWARD));
        
        L2_data.specs.val_data(end,1).eyedata{1,1} = val_pts(1,:);
        L2_data.specs.val_data(end,1).eyedata{2,1} = val_pts(2,:);
        L2_data.specs.val_data(end,1).eyedata{3,1} = val_pts(3,:);
        
        L2_data.specs.val_data(end,1).eyedata{1,2} = get_eyedata_fragment(t_beg, t_end);
        
        % collecting eye data for the right target [6.0 3.0]
        t_beg = val_ts((val_seg == C.RIGHT_TARGET_FIXATED));
        t_end = val_ts((val_seg == C.RIGHT_TARGET_REWARD));
        L2_data.specs.val_data(end,1).eyedata{2,2} = get_eyedata_fragment(t_beg, t_end);
        
        % collecting eye data for the down target [0.0 -3.0]
        t_beg = val_ts((val_seg == C.DOWN_TARGET_FIXATED));
        t_end = val_ts((val_seg == C.DOWN_TARGET_REWARD));
        L2_data.specs.val_data(end,1).eyedata{3,2} = get_eyedata_fragment(t_beg, t_end);
        
        % arranging eye data from all the validated coordinates and the
        % associated coordinate values for calibration purposes
        valeyedata = L2_data.specs.val_data(end,1).eyedata;
        npts = size(valeyedata,1);
        xdvadata = [];
        ydvadata = [];
        fixdata = [];
        for pt = 1:npts
            nsamples = length(valeyedata{pt,2});
            ONES = ones(nsamples,1);
            xdvadata = [xdvadata; ONES*valeyedata{pt,1}(1)];
            ydvadata = [ydvadata; ONES*valeyedata{pt,1}(2)];
            fixdata = [fixdata; valeyedata{pt,2} ONES];
        end
        % performing linear regression and storing the coefficients
        L2_data.specs.val_data(end,1).x_transform(:,count) = regress(xdvadata, fixdata);
        L2_data.specs.val_data(end,1).y_transform(:,count) = regress(ydvadata, fixdata);
        count = count + 1;
    end
end
end

% processes a set of trial segments from the plx file
%    - trial_segs contains the indices necessary to extract each trial
%      segment from the event codes vector
%    - current_neuron will be the index into the L2_data for the neuron
%      under consideration
%    - processeye_flag = 1, if eye data should be processed
%      processeye_flag = 0, otherwise
function process_trial_blocks(sorted_plx_file, channel, unit, prog_id, cnds, cnd_grps, processeye_flag, add_all_trials)
global C event_codes event_codes_ts L2_data spks_ts;

if ~isempty(cnd_grps), cnds = cnd_grps; end
    
% extracting both correct and incorrect trial segments
[matchstart, matchend] = regexp(char(event_codes'),char([C.PLEXON_START ...
                                                         C.EYEDATA_START ...
                                                         '.' ...
                                                         prog_id ...
                                                         '.*?' ...
                                                         C.EYEDATA_STOP]));
trial_segs = [matchstart' matchend'];

if ~isempty(trial_segs)
    % reading the spike data for the given channel and unit from the plx file
    readspikedata(sorted_plx_file, channel, unit);
end

nitms_per_grp = L2_data.specs.nitms_per_grp;
if nitms_per_grp > 1
    ngrps = length(L2_data.groups);
else
    ngrps = length(L2_data.items);
end

% t_on = cell(nitms_per_grp,1);
% t_off = cell(nitms_per_grp,1);

% total number of trial segments to be processed
ntrials = size(trial_segs,1);

t_on = cell(ngrps, nitms_per_grp);
t_off = cell(ngrps, nitms_per_grp);

nrc = 1;

% processing each trial segment, which could be a correct/incorrect trial
for trial_no = 1:ntrials
    
    % event codes collected during one trial
    trial_ev = event_codes(trial_segs(trial_no,1):trial_segs(trial_no,2)+1);
    
    qbeg = find(trial_ev == C.PLEXON_START); if length(qbeg) > 1, continue; end
    
    % processing only correct trials
    if add_all_trials == 0 & isempty(find(trial_ev == C.RESPONSE_CORRECT, 1)), continue; end
    
    if find(trial_ev == C.RESPONSE_CORRECT)
        trial_ts  = event_codes_ts(trial_segs(trial_no,1):trial_segs(trial_no,2)+1);
        t_beg = trial_ts(trial_ev == C.REWARDED) + L2_data.specs.baseline_spk_window(1);
        t_end = t_beg + L2_data.specs.baseline_spk_window(2);
        L2_data.baseline_spikes{end}{1}{1,nrc} = spks_ts(spks_ts >= t_beg & spks_ts <= t_end) - t_beg;
        nrc = nrc + 1;
    end
    
    % timestamps for the event codes collected above
    trial_ts  = event_codes_ts(trial_segs(trial_no,1):trial_segs(trial_no,2));
    % extracting the start and end times of the trial    
    t_beg = trial_ts(trial_ev == C.PLEXON_START);
    t_end = trial_ts(trial_ev == C.EYEDATA_STOP);
    % getting spikes during the trial period
    trial_spks_ts = spks_ts(spks_ts >= t_beg & spks_ts <= t_end);
    % processing spikes for each presentation during the trial
    trial_spks_str = process_plx_trial_spks(trial_ev, trial_ts, trial_spks_ts, nitms_per_grp, cnds, L2_data.specs.spk_window);
    % trial without even a single stimuli with on/off times
    if isempty(trial_spks_str.response_correct), continue; end
    % getting the eye data for the trial
    if processeye_flag == 1, trial_spks_str.fix_stats = process_trial_eyedata(trial_spks_str); end
    
    % adding spikes, eye data, response correctness to the L2_data
    % processing each group presented during the trial
    for grp_no = 1:trial_spks_str.ngrps
        % recording the on and off time for each stimulus in a group
        t_on_off = [];
         % group id - used to organize data in L2_data for a given neuron
        grpid = trial_spks_str.stim_order(grp_no);
        for stim = 1:nitms_per_grp
            t_on_off = [t_on_off trial_spks_str.t_on(grp_no,stim) trial_spks_str.t_off(grp_no,stim)];
            t_on{grpid,stim} = [t_on{grpid,stim} trial_spks_str.t_on(grp_no,stim) - trial_spks_str.t_on(grp_no,1)];
            t_off{grpid,stim} = [t_off{grpid,stim} trial_spks_str.t_off(grp_no,stim) - trial_spks_str.t_on(grp_no,1)];
        end
        if grpid > size(L2_data.spikes{end,1},1)
            L2_data.spikes{end,1}{grpid,1} = [];
            L2_data.response_correct{end,1}{grpid,1} = [];
            
            if length(L2_data.neuron_id) == 1
                L2_data.specs.t_on_off{end,1}{grpid,1} = [];
                if processeye_flag == 1, L2_data.specs.fix_stats{end,1}{grpid,1} = []; end
            end
        end
        
        % recording the spikes during the presentation of the group
        L2_data.spikes{end,1}{grpid,1} = [L2_data.spikes{end,1}{grpid,1} {trial_spks_str.spks{grp_no,1}}];
        % recording correctness of the trial
        L2_data.response_correct{end,1}{grpid,1} = [L2_data.response_correct{end,1}{grpid,1} trial_spks_str.response_correct];
        
        if length(L2_data.neuron_id) == 1
            % recording the on-off times of the stimuli in the group
            L2_data.specs.t_on_off{end,1}{grpid,1} = [L2_data.specs.t_on_off{end,1}{grpid,1} {t_on_off}];
            % computing the eye coordinates during the group presentation
            if processeye_flag == 1, L2_data.specs.fix_stats{end,1}{grpid,1} = [L2_data.specs.fix_stats{end,1}{grpid,1} {trial_spks_str.fix_stats{grp_no,1}}]; end
        end
    end
end

rc = L2_data.response_correct;
for i = 1:length(rc{end}) % stim
    neworder = [find(rc{end}{i} == 1) find(rc{end}{i} == 0)];
    L2_data.spikes{end}{i} = L2_data.spikes{end}{i}(neworder);
    L2_data.response_correct{end}{i} = L2_data.response_correct{end}{i}(neworder);
    
    if length(L2_data.neuron_id) == 1
        L2_data.specs.t_on_off{end}{i} = L2_data.specs.t_on_off{end}{i}(neworder);
        L2_data.specs.fix_stats{end}{i} = L2_data.specs.fix_stats{end}{i}(neworder);
    end
end    

if length(L2_data.neuron_id) == 1
    % calculating some stats related to stimulus off times
    calc_onoff_stats(t_on, t_off, ngrps, nitms_per_grp);
end

end

% computes the following fixation statistics for the groups in a given trial
% max, min, mean, and standard deviation of x & y dva coordinates
%    - trial_spks_str contains trial data organized in terms of groups
%    - fix_stats will contain the fixation statistics
function fix_stats = process_trial_eyedata(trial_spks_str)
% number of groups in the trial
ngrps = trial_spks_str.ngrps;
% data structure to store the fixation statistics
fix_stats = cell(ngrps,1);
% processing each group
for i = 1:ngrps
    % computing fixation statistics for each group in the trial
    fix_stats{i,1} = compute_fix_stats(trial_spks_str.t_on(i,1), trial_spks_str.t_off(i,end), trial_spks_str.t_beg);
end
end

% reads event codes from the specified plx file
%   - plx_file contains the full path of the plx file
function readeventcodes(plx_file)
global event_codes_ts event_codes;
[n_events, event_codes_ts, event_codes] = plx_event_ts(plx_file, 257);
end

% reads the spikes for a specified channen & unit from a given plx file and
% stores it in the global variable spks_ts
%   - plx_file contains the full path of the plx file
%   - channel is the channel#
%   - unit is the unit#
function readspikedata(plx_file, channel, unit)
global n_spks spks_ts;
[n_spks, spks_ts] = plx_ts(plx_file, channel, unit);
end

