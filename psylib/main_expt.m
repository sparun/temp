% Comments from your review
% -----------------------------------------------------------------------------------
% overall data structure
% expt_str.expt_name
% expt_str.subj_name
% expt_str.subj_id
% expt_str.session_id
% expt_str.expt_date
% expt_str.expt_time
% etc

% expt_str.data.t_fix_on  = [n x 1 array of fixation times] where n = ntrials
% expt_str.data.t_saccade = [n x 1 array of saccade onset times]
% expt_str.data.rt        = [n x 1 array of rts]
% expt_str.data.block     = [n x 1 array of block id of each trial]
% etc.

% expt_str.task.fix_window = 3; % size of fixation window
% expt_str.task.fix_duration = 0.5;
% expt_str.task.check_fix_time = 0.1;
% etc.

% expt_str.specs.calibration
% expt_str.specs.iscan
% expt.str.specs.screen

% comments/changes
%   - store eye data on a per-trial basis. no need to store for entire experiment
%   - no need to store raw eye signal values - only store dva values
% overall
%   - make expt_str as global and let it be modified by whoever
% psy_calibrate_iscan

%   - remove sigx_dev_limit and sigy_dev_limit from iscan structure
%   - force experimenter to specify calibration locations
%   - if no validation locations are specified, then validate at a random point within the square
%     specified by (minx,maxx) and (miny,maxy).
%     if validation locations are present, validate all locations.
%   - specs.calibration.cal_locations = n x 2 array
%   - specs.calibration.cal_data = n x 1 cell array with (i,j)th entry = 24x2 array of dva values
%   - likewise with specs.calibration.val_locations & specs.calibration.val_data
%   - (that means psy_calibrate_iscan should both calibrate and validate
%   - specs.calibration.dva_error = n x 4 array of [xmean xstd ymean ystd], where xmean = mean error between
%     actual and iscan; xstd = standard deviation of iscan dvas; ymean, ystd likewise.
%   - rename max_fix_attempts as n_attempts
%   - specs.calibration.x_transform & specs.calibration.y_transform
% __________________________________________________________________________________

% main_expt.m -> main experiment
% This experiment is an attempt to characterize saccadic masking in terms of:
% 1) length of the saccade
% 2) size of the flash
% 3) brightness of the flash
% For further information on experiment design, etc. please refer to:
% saccadic_masking.doc
%
% Zhivago KA
% 07 December 2010

function main_expt

psy_allclear();
ListenChar(2);

% global variable to store all the experiment information
global expt_str;
% global variable to store the eye data stream from iscan
global eye_data_stream;

% screen landmarks
CENTER = [0 0];

% typical colors that experiments can use 
BLACK   = [0 0 0];
RED     = [255 0 0];
GREEN   = [0 255 0];
BLUE    = [0 0 255];
YELLOW  = [255 255 0];
CYAN    = [0 255 255];
MAGENTA = [255 0 255];
WHITE   = [255 255 255];

% To control the luminance of the flash
grayness = 15;
GRAY = [grayness grayness grayness];

try
    % initialize experiment variables, screens, eye tracker
    set_everything();
    % initialize task-specific parameters
    set_task_structure();
    
    % calibrate eye tracker
    cal_locations = [-10 0; 0 10; 10 0];
    % val_locations = [0 0];
    fail_flag = psy_calibrate_iscan(cal_locations);
    if fail_flag == 1, disp('Calibration failed'); return; end
    
    % ---- main experiment ----
    
    % window pointer for all screen-related operations
    wptr = expt_str.specs.screen.wptr;
    
    % setting up the bag of trials from which trials will be picked at random
    ntrials = expt_str.task.n_trials;
    total_trials = sum(ntrials);
    bag_of_trials = [];
    for i = 1:length(ntrials)
        bag_of_trials = [bag_of_trials i*ones(1,ntrials(i))];
    end
    
    % starting the trials
    trial_id = 1;                 % trial id of each run
    n_aborts = 0;                 % number of aborted trials
    trial_count = 0;              % number of trials presented to the subject
    continue_session_flag = true; % flag to decide the fate of the session
    
    while(~isempty(bag_of_trials))
        
        trial_count = trial_count + 1; % keeping track of the number of trials run
        
        % Giving choices to the subject
        % if more than a specified number of trials are aborted
        if n_aborts == 3
            n_aborts = 0;
            while(1)
                psy_change_screen_color(BLACK);
                Screen('DrawText', wptr, 'Make a choice...', 500, 300, [0 255 0]);
                Screen('DrawText', wptr, '1) to continue - press c', 500, 350, [0 255 0]);
                Screen('DrawText', wptr, '2) to take a break - press no key', 500, 380, [0 255 0]);
                Screen('DrawText', wptr, '3) to recalibrate - press r', 500, 410, [0 255 0]);
                Screen('DrawText', wptr, '4) to exit - press ESC', 500, 440, [0 255 0]);
                Screen('Flip', wptr);
                [~, key_code, ~] = KbPressWait();
                if strcmp(KbName(key_code), 'r')
                    psy_change_screen_color(BLACK);
                    fail_flag = psy_calibrate_iscan(cal_locations);
                    if fail_flag
                        Screen('DrawText', wptr, 'CALIBRATION FAILED', 590, 300, [255 0 0]);
                        Screen('Flip', wptr);
                        WaitSecs(2);
                        continue;
                    end
                    break;
                elseif strcmp(KbName(key_code), 'esc')
                    continue_session_flag = false;
                    break;
                else
                    break;
                end
            end
        end
        if ~continue_session_flag, break; end
        
        % picking a trial from the trial bag randomly
        q = randperm(length(bag_of_trials)); q = q(1);
        trial_type = bag_of_trials(q);
        
        % computing cross 1, cross 2, and flash positions
        stim1_dva = [-10 0]; % [(-15 + (rand - 0.5)*2*3) 0]; % xdva = -10 +/- 3
        stim2_dva = [10 0];  %[(+15 + (rand - 0.5)*2*2) 0]; % xdva = -10 +/- 2
        flash_dva = [(rand - 0.5)*2*5 (rand - 0.5)*2*5];
        
        % indicate new trial to the subject
        psy_change_screen_color(BLACK);
        WaitSecs(1.5);
        Screen('DrawText', wptr, 'N E W    T R I A L', 580, 500, [0 255 0]);
        progress = sprintf('Trial ID %02i - Trial Count %02i', trial_id, trial_count);
        Screen('DrawText', wptr, progress, 550, 550, [0 255 0]);
        Screen('Flip',wptr);
        WaitSecs(1);
        psy_change_screen_color(BLACK);
        
        psy_purge_iscan(); eye_data_stream = []; % start fresh eye data collection
        tbeg = GetSecs; % time at the beginning of trial
        
        % display first cross
        t_first_cross = psy_draw_cross(stim1_dva,WHITE);
        % wait for fixation at cross 1
        fail_flag = psy_await_fix(stim1_dva,expt_str.task.fix_timeout);
        if fail_flag, n_aborts = n_aborts + 1; continue; end
        
        % wait for random delay at cross 1 checking for fixation
        isi_range = expt_str.task.isi_range;
        first_delay = isi_range(1) + rand*(isi_range(2)-isi_range(1));
        psy_check_fix(stim1_dva,first_delay);
        if fail_flag, n_aborts = n_aborts + 1; continue; end
        
        % set up random delay for the second fixation
        second_delay = isi_range(1) + rand*(isi_range(2)-isi_range(1));
        
        switch trial_type
            case 1 % no flash trial
                t_flash_dot = NaN;
                % draw second cross
                t_second_cross = psy_draw_cross(stim2_dva, YELLOW);
                % wait for saccade from cross 1
                fail_flag = psy_await_saccade(stim1_dva,expt_str.task.sacc_timeout);
                if fail_flag, n_aborts = n_aborts + 1; continue; end
                % wait for fixation at cross 1
                fail_flag = psy_await_fix(stim2_dva,expt_str.task.fix_timeout);
                if fail_flag, n_aborts = n_aborts + 1; continue; end
                
            case 2 % flash before saccade trial
                % flash a dot
                t_flash_dot = psy_draw_dot(flash_dva, GRAY, expt_str.task.flash_size, 1, 1,expt_str.task.flash_time);
                % draw second cross
                t_second_cross = psy_draw_cross(stim2_dva, YELLOW);
                % wait for saccade from cross 1
                fail_flag = psy_await_saccade(stim1_dva,expt_str.task.sacc_timeout);
                if fail_flag, n_aborts = n_aborts + 1; continue; end
                % wait for fixation at cross 2
                fail_flag = psy_await_fix(stim2_dva,expt_str.task.fix_timeout);
                if fail_flag, n_aborts = n_aborts + 1; continue; end
                
            case 3 % flash during saccade trial
                % draw second cross
                t_second_cross = psy_draw_cross(stim2_dva, YELLOW);
                % wait for saccade from cross 1
                fail_flag = psy_await_saccade(stim1_dva,expt_str.task.sacc_timeout);
                if fail_flag, n_aborts = n_aborts + 1; continue; end
                % flash a dot
                t_flash_dot = psy_draw_dot(flash_dva, GRAY, expt_str.task.flash_size, 1, 1,expt_str.task.flash_time);
                % wait for fixation at cross 2
                fail_flag = psy_await_fix(stim2_dva,expt_str.task.fix_timeout);
                if fail_flag, n_aborts = n_aborts + 1; continue; end
                
            case 4 % flash after saccade trial
                % draw second cross
                t_second_cross = psy_draw_cross(stim2_dva, YELLOW);
                % wait for saccade from cross 1
                fail_flag = psy_await_saccade(stim1_dva,expt_str.task.sacc_timeout);
                if fail_flag, n_aborts = n_aborts + 1; continue; end
                % wait for fixation at cross 2
                fail_flag = psy_await_fix(stim2_dva,expt_str.task.fix_timeout);
                if fail_flag, n_aborts = n_aborts + 1; continue; end
                % wait for random delay at cross 2 checking for fixation
                fail_flag = psy_check_fix(stim2_dva,second_delay);
                if fail_flag, n_aborts = n_aborts + 1; continue; end
                % flash a dot
                t_flash_dot = psy_draw_dot(flash_dva, GRAY, expt_str.task.flash_size, 1, 1,expt_str.task.flash_time);
            otherwise
                disp('invalid trial type');
                continue;
        end
        
        % ask the subject about the flash
        WaitSecs(.5);
        psy_change_screen_color(BLACK);
        Screen('DrawText', wptr, 'Saw anything flash anywhere?', 530, 500, [0 255 0]);
        Screen('DrawText', wptr, '[y/n]', 610, 550, [0 255 0]);
        Screen('Flip',wptr);
        [response_flag,key_time] = psy_await_keypress(expt_str.task.response_keys,expt_str.task.response_timeout); 
        if response_flag == 0, n_aborts = n_aborts + 1; continue; end
        
        % eye data collection
        psy_collect_eye_data();
        iscan_fix_data = decode_bin_stream(eye_data_stream);
        fix_dva_data = psy_transform_iscan_data(iscan_fix_data);
        
        tend = GetSecs; % time at the end of trial
        
        % determining if the subject's response was correct
        response_correct = 0; 
        if( (trial_type == 1 && response_flag == 2) ||...
            (trial_type ~= 1 && response_flag == 1) ) % i.e flash absent, and user hit n key
            response_correct = 1; 
        end
        
        % now add everything into a local data structure
        data.trial_type(trial_id,1)       = trial_type; 
        data.stim1_dva(trial_id,:)        = stim1_dva;
        data.stim2_dva(trial_id,:)        = stim2_dva;
        data.flash_dva(trial_id,:)        = flash_dva;
        data.t_first_cross(trial_id,1)    = t_first_cross - tbeg; 
        data.first_delay(trial_id,1)      = first_delay;
        data.t_flash(trial_id,1)          = t_flash_dot - tbeg; 
        data.t_second_cross(trial_id,1)   = t_second_cross - tbeg; 
        data.second_delay(trial_id,1)     = second_delay;
        data.eye_stream{trial_id,1}       = fix_dva_data; 
        data.response_correct(trial_id,1) = response_correct;
        data.RT(trial_id,1)               = key_time - t_flash_dot;
        data.trial_time(trial_id,1)       = tend - tbeg;
     
        bag_of_trials(q) = [];
        trial_id = trial_id + 1;
        
        % push all the data into the global data structure
        expt_str.data = data;
    end
    save('current_run.mat'); % save workspace, just in case!
    psy_shutdown_iscan;
    ShowCursor; ListenChar(0);
    Screen('CloseAll');
    
    % Plot accuracies for all the blocks
    n_ttypes = size(ntrials,2);
    corrects(1:n_ttypes) = 0;
    accuracy(1:n_ttypes) = 0;
    for t = 1:total_trials
        ttype = expt_str.data.trial_type(t,1);
        corrects(ttype) = corrects(ttype) + expt_str.data.response_correct(t);
    end
    for tt = 1:n_ttypes
        if ntrials(tt) ~= 0, accuracy(tt) = corrects(tt)/ntrials(tt); end
    end
    bar(accuracy);
    
    % Plot the saccade and flash times for the during-saccade block
    pause on;
    figure;
    iscan = expt_str.specs.iscan;
    for t = 1:total_trials
        ttype = expt_str.data.trial_type(t,1);
        if (ttype ~= 3), continue; end
        eye_stream = expt_str.data.eye_stream{t,1};
        n_pts = size(eye_stream,1); time = [0:n_pts-1]/iscan.sample_freq;
        plot(time, eye_stream(:,1),'.'); % saccade
        v = axis;
        hold on;
        t_flash = expt_str.data.t_flash(t,1);
        plot(t_flash * ones(2,1),[v(3) v(4)],'k');
        caption = sprintf('During-Saccade Block  [Trial: %02i  Saw Flash: %i]', t, expt_str.data.response_correct(t,1));
        title(caption);
        pause;
        hold off;
    end
    pause off;
    
    save('current_run.mat');
catch
    save('current_run.mat');
    psy_shutdown_iscan;
    ShowCursor; ListenChar(0);
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end

return

% -------------------------------------------------------------------
% This function initializes all devices and parameters
% -------------------------------------------------------------------
% set_everything
% REQUIRED INPUTS
%  None
% OPTIONAL INPUTS
%  None
% OUTPUTS
%  None
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  set_everything
%  will initialize all devices and parameters
% REQUIRED SUBROUTINES
%  None
%
% Zhivago KA
% 07 December 2010

function set_everything
global expt_str;

% data structure to store experiment information
info_str = struct('expt_name', [],...
                  'where', [],...
                  'when', [],...
                  'subj_name', [],...
                  'subj_id', [],...
                  'session_id', [],...
                  'fields', []);

n=0;
n=n+1; info_str.fields{n,1} = 'expt_name  = experiment name';
n=n+1; info_str.fields{n,1} = 'where      = experiment venue';
n=n+1; info_str.fields{n,1} = 'when       = experiment date/time';
n=n+1; info_str.fields{n,1} = 'subj_name  = subject name';
n=n+1; info_str.fields{n,1} = 'subj_id    = subject id';
n=n+1; info_str.fields{n,1} = 'session_id = Sesssion number';

% data structure to store all calibration information
cal_str = struct('cal_locations', [],...
                 'cal_data',  {cell(1,1)},...
                 'val_locations', [],...
                 'val_data',  {cell(1,1)},...
                 'dva_error', [],... %n x 4 array of [xmean xstd ymean ystd]
                 'x_transform', [0 0 0],...
                 'y_transform', [0 0 0],...
                 'fields', []);

n=0;
n=n+1; cal_str.fields{n,1} = 'cal_locations = calibration points nx2 (x,y) dvas';
n=n+1; cal_str.fields{n,1} = 'cal_data      = calibration data';
n=n+1; cal_str.fields{n,1} = 'val_locations = validation points nx2 (x,y) dvas';
n=n+1; cal_str.fields{n,1} = 'val_data      = validation data';
n=n+1; cal_str.fields{n,1} = 'dva_error     = n x 4 array of [xmean xstd ymean ystd]';
n=n+1; cal_str.fields{n,1} = 'x_transform   = x tranformation coeffts';
n=n+1; cal_str.fields{n,1} = 'y_transform   = y tranformation coeffts';

% data structure to store all specs
spec_str = struct('screen', [],...
                  'iscan', [],...
                  'calibration', struct(cal_str),...
                  'fields', []);
n=0;
n=n+1; spec_str.fields{n,1} = 'screen      = screen/window parameters';
n=n+1; spec_str.fields{n,1} = 'iscan       = iscan parameters';
n=n+1; spec_str.fields{n,1} = 'calibration = calibration parameters';

% data structure to store all the experiment information/specs/data
expt_str = struct('info', struct(info_str),...
                  'specs', struct(spec_str),...
                  'task', [],...
                  'data', [],...
                  'fields', []);

n=0;
n=n+1; expt_str.fields{n,1} = 'info  = general information';
n=n+1; expt_str.fields{n,1} = 'specs = specifications';
n=n+1; expt_str.fields{n,1} = 'task  = task-specific parameters';
n=n+1; expt_str.fields{n,1} = 'data  = experiment data';

% collect subject information
info.expt_name  = 'Saccadic Suppression Experiment';
info.where      = 'Psychophysics Lab, CNS, IISc';
info.when       = datestr(clock);
disp([info.expt_name ' -- ' info.where ' -- ' info.when]);
info.subj_name  = 'Zhivago'; % input('Subject Name : ','s');
info.subj_id    = '147'; %input('Subject ID   : ');
info.session_id = '12'; %input('Session ID   : ');
expt_str.info   = info;

% initialize display
scr_num = 2;       % scr_num = 0 if you want to open a huge window across all screens
wcolor  = [0 0 0]; % BLACK screen
expt_str.specs.screen = psy_init_display(scr_num);
open_window(scr_num, wcolor);

% initialize eye tracker
expt_str.specs.iscan  = psy_init_iscan();
return

% -------------------------------------------------------------------
% This function sets task-specific parameters that remain constant
% -------------------------------------------------------------------
% set_task_structure
% REQUIRED INPUTS
%  None
% OPTIONAL INPUTS
%  None
% OUTPUTS
%  None
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  set_task_structure
%  will set all taskspecific parameters that remain constant
% REQUIRED SUBROUTINES
%  None
%
% Zhivago KA
% 07 December 2010

function set_task_structure
global expt_str;

iscan = expt_str.specs.iscan;

check_fix_time    = 0.1; % last 100 ms data used for checking fixation
task.check_fix_samples = ceil(iscan.sample_freq * check_fix_time);
task.fix_window        = 3; % 3 dva
task.fix_duration      = 0.5;
task.fix_timeout       = 2; % timeout for psy_await_fix
task.sacc_timeout      = 0.5; % timeout for psy_await_saccade
task.isi_range         = [0.1 0.5]; % inter-stim-interval (isi) is picked randomly from this range
task.flash_time        = 0.03;
task.flash_size        = 0.2;
task.response_keys     = [KbName('up') KbName('down') KbName('r') KbName('c') KbName('esc')]; 
task.response_timeout  = 5;
task.n_trials          = [0 0 10 0]; % # of trials of each type sorted as no-flash, before, during, after

n=0;
n=n+1;task.fields{n,1} = 'check_fix_samples = number of samples to collect for checkinng fixation';
n=n+1;task.fields{n,1} = 'fix_window        = dva window in which check fixation';
n=n+1;task.fields{n,1} = 'fix_timeout       = timeout for checking fixation';
n=n+1;task.fields{n,1} = 'sacc_timeout      = timeout for checking saccade';
n=n+1;task.fields{n,1} = 'isi_range         = interstimulus interval';
n=n+1;task.fields{n,1} = 'flash_time        = time for which the dot appears';
n=n+1;task.fields{n,1} = 'flash_size        = size of the dot flashed';
n=n+1;task.fields{n,1} = 'response_keys     = allowed set of keys for response';
n=n+1;task.fields{n,1} = 'response_timeout  = timeout for making a response';
n=n+1;task.fields{n,1} = 'n_trials          = number of trials of each type in a block';

expt_str.task = task;
return

% -------------------------------------------------------------------
% This function opens the subject window
% -------------------------------------------------------------------
% open_window(scr_num, wcolor)
% REQUIRED INPUTS
%  scr_num   = screen number in which to open the window
% OPTIONAL INPUTS
%  wcolor    = window color
%              Default color = BLACK [0 0 0]
% OUTPUTS
%  None
% METHOD
%     
% NOTES
% 
% EXAMPLE
%  open_window(2, [0 255 0]);
%  will open a subject window with a GREEN background
% REQUIRED SUBROUTINES
%  None
%
% Zhivago KA
% 07 December 2010

function open_window(scr_num, wcolor)
global expt_str;

if ~exist('wcolor'), wcolor = [0 0 0]; end

% setting subject screen parameters
[wptr, rect] = Screen('OpenWindow', scr_num);
Screen('FillRect', wptr, wcolor);
Screen('Flip', wptr, 0, 0, 2);
Screen('Preference', 'TextAlphaBlending', 1);
Screen(wptr,'TextFont', 'Verdana');
Screen(wptr,'TextSize', 10);
Screen(wptr,'TextStyle', 0);
Screen(wptr,'TextColor', [0 0 255]);

expt_str.specs.screen.wptr  = wptr;
expt_str.specs.screen.rect  = rect;
expt_str.specs.screen.color = wcolor;

return