% trial_spks_str = process_plx_trial_spks(trial_seg, trial_ts, spks_ts, nstims_per_grp, conditions, spk_window)
%
%     Takes as input the event codes, their timestamps and spike times during a trial (incorrect/correct)
%     and extracts stimulus spike times, and on/off times for each stimulus.
%
% INPUTS
%     trial_seg      - trial segment (containing the event codes that were transmitted during the trial)
%     trial_ts       - event code times
%     spks_ts        - spike times
%     nstims_per_grp - number of stimuli/group
%     conditions     - condition/group matrix
%     spk_window     - time window for collecting spikes
%
% OUTPUTS
%     trial_spks_str
%        |__stim_order       : specified order of stimulus/group
%        |__spks             : spike times for each stimulus
%        |__t_on             : stimulus on time for each stimulus
%        |__t_off            : stimulus off time for each stimulus
%        |__response_correct : correctness of the trial
%
% USAGE
%     (1) Without any stimuli grouping, with C being the cortex condition matrix, and pre-stimulus time = 0.1s
%
%             trial_spks_str = process_plx_trial_spks(trial_ev, trial_ts, spks_ts, 1, C);
%
%     (2) 2 stimuli/group, with C being the cortex condition matrix, and pre-stimulus time = 0.15s
%
%             trial_spks_str = process_plx_trial_spks(trial_ev, trial_ts, spks_ts, 2, C, 0.15);

function trial_spks_str = process_plx_trial_spks(trial_ev, trial_ts, spks_ts, nitm_per_grp, conditions, spk_window)

% loading the event code definitions
global C;

% setting default pre-stim time, if not specified
% end time of spikes for each stimulus is the start time of the next stimulus
if ~exist('spk_window') | isempty(spk_window), spk_window = [-.1 .4]; end

trial_spks_str = setup_str();

t_beg = trial_ts(trial_ev == C.PLEXON_START);
t_end = trial_ts(trial_ev == C.EYEDATA_STOP);

% determining whether it is a correct/incorrect trial
response_correct = 0;
if ~isempty(find(trial_ev == C.RESPONSE_CORRECT)), response_correct = 1; end

% extracting the cortex condition number
cnd_id = trial_ev(3)- C.COND_ID_START - 3;

if nitm_per_grp > 1
    stim_order = conditions(cnd_id,:);
else
    % order of stimuli in the conditions file
    stim_order = conditions(cnd_id,:);
    stim_order(stim_order == 0) = [];
    % factoring in permutation order (if any) to figure out the actual stimulus order
    perm_order = trial_ev(trial_ev > C.PERM_ORDER_START & trial_ev <= C.PERM_ORDER_END) - C.PERM_ORDER_START;
    if ~isempty(perm_order)
        stim_order = stim_order(perm_order);
    end
end

% indices of stimulus on/off markers
% END_ANALYSIS is used as the end time marker of spikes for the last stimulus
q_on_off = find(trial_ev >= C.STIM0_ON & trial_ev <= C.STIM9_OFF);

% monkey didn't fixated even on a single stimulus
if isempty(q_on_off), return; end

% determining the actual number of stimuli presented during the trial
% since both correct and incorrect trials will be processed by this code
nstims = floor(length(q_on_off)/2);
ngrps  = floor(nstims/nitm_per_grp);

% retaining the stimuli for which both on/off times are available
q_on_off = q_on_off(1:nstims*2);

% monkey didn't maintain fixation through the on and off times
if ngrps == 0, return; end

% in case END_ANALYSIS marker is not present, pick the next marker
q_on_off = [q_on_off; q_on_off(end)+1];

count = 1;
for g = 1:ngrps
    if size(spk_window,1) == 1
        stim_spk_window = spk_window;
    else
        stim_spk_window = spk_window(stim_order(g),:);
    end
    % on/off times for every stimulus in a group
    for stim = 1:nitm_per_grp
        t_on(g,stim)  = trial_ts(q_on_off(count)); count = count + 1;
        t_off(g,stim) = trial_ts(q_on_off(count)); count = count + 1;
    end
    % computing the timeline for spikes and extracting them
    t_first_stim_on = t_on(g,1);
    q_spks = find(spks_ts >= t_first_stim_on + stim_spk_window(1) & spks_ts <= t_first_stim_on + stim_spk_window(2));
    spks{g,1} = spks_ts(q_spks) - t_first_stim_on;
end
trial_spks_str.ngrps            = ngrps;
trial_spks_str.nitm_per_grp     = nitm_per_grp;
trial_spks_str.stim_order       = stim_order;
trial_spks_str.spks             = spks;
trial_spks_str.t_on             = t_on;
trial_spks_str.t_off            = t_off;
trial_spks_str.t_beg            = t_beg;
trial_spks_str.t_end            = t_end;
trial_spks_str.response_correct = response_correct;
end

function trial_spks_str = setup_str()
trial_spks_str = struct(...
    'ngrps', [],...
    'nitm_per_grp', [],...
    'stim_order', [],...
    'spks', cell(1,1),...
    't_on', [],...
    't_off', [],...
    't_beg', [],...
    't_end', [],...
    'response_correct', [],...
    'fields', []);
n=0;
n=n+1; trial_spks_str.fields{n,1} = 'ngrps = number of groups with on/off times';
n=n+1; trial_spks_str.fields{n,1} = 'nitm_per_grp = number of stimuli per group';
n=n+1; trial_spks_str.fields{n,1} = 'stim_order = specified order of stimulus/group';
n=n+1; trial_spks_str.fields{n,1} = 'spks = spike times for each stimulus';
n=n+1; trial_spks_str.fields{n,1} = 't_on = stimulus on time for each stimulus';
n=n+1; trial_spks_str.fields{n,1} = 't_off = stimulus off time for each stimulus';
n=n+1; trial_spks_str.fields{n,1} = 't_beg = trial begin time';
n=n+1; trial_spks_str.fields{n,1} = 't_end = trial end time';
n=n+1; trial_spks_str.fields{n,1} = 'response_correct = correctness of the trial';
end