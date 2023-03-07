% example_expt.m       -> example experiment using psylib

% s p arun
% november 17 2010

function example_expt

allclear;
global expt_str eye_data_stream;

try
    set_everything; % initializes experiment variables, initializes screens, sets up iscan, sets up display
    set_task_structure;
    
    calib_locations = [-10 0; 0 0; 10 0];
    fail_flag = psy_calibrate_iscan(calib_locations); % do calibration & validation
    
    % ---- main experiment ----
    ntrials = expt_str.task.ntrials;
    total_trials = sum(ntrials);
    bag_of_trials = [];
    for i = 1:length(ntrials)
        bag_of_trials = [bag_of_trials i*ones(1,ntrials(i))];
    end
    
    trial_id = 1;
    while(~isempty(bag_of_trials))
        
        % figure out which trial type to run
        q = randperm(length(bag_of_trials)); q = q(1);
        trial_type = bag_of_trials(q);
        
        % set up trial-specific parameters
        stim1_dva = [(-15 + (rand - 0.5)*2*3) 0]; % xdva = -10 +/- 3
        stim2_dva = [(+15 + (rand - 0.5)*2*2) 0]; % xdva = -10 +/- 2
        flash_dva = [(rand - 0.5)*2*5 (rand - 0.5)*2*5];
        
        % initialize eye data stuff
        psy_purge_iscan(); eye_data_stream = [];
        
        tbeg = GetSecs; % beginning of trial
        
        % display first cross
        t_first_cross = psy_draw_cross(stim1_dva,WHITE);
        fail_flag = psy_await_fix(stim1_dva,expt_str.task.fix_timeout);
        % wait for random delay
        isi_range = expt_str.task.isi_range;
        first_delay = isi_range(1) + rand*(isi_range(2)-isi_range(1));
        psy_check_fix(stim1_dva,first_delay);
        
        % set up random delay for the second fixation
        second_delay = isi_range(1) + rand*(isi_range(2)-isi_range(1));
        
        if(fail_flag==0)
            switch trial_type
                case 1 % no flash
                    t_flash_dot = NaN;
                    % draw second cross and wait for saccade
                    t_second_cross = psy_draw_cross(stim2_dva, YELLOW);
                    fail_flag = psy_await_saccade(stim1_dva,expt_str.task.sacc_timeout);
                    if(fail_flag==0)
                        fail_flag = psy_await_fix(stim2_dva,expt_str.task.fix_timeout);
                    end
                    
                case 2 % flash before saccade
                    t_flash_dot = psy_draw_dot(flash_dva, GRAY, expt_str.task.flash_size, 1, 1,expt_str.task.flash_time);
                    % draw second cross and wait for saccade
                    t_second_cross = psy_draw_cross(stim2_dva, YELLOW);
                    fail_flag = psy_await_saccade(stim1_dva,expt_str.task.sacc_timeout);
                    if(fail_flag==0)
                        fail_flag = psy_await_fix(stim2_dva,expt_str.task.fix_timeout);
                    end
                    
                case 3 % flash during saccade
                    % draw second cross and wait for saccade
                    t_second_cross = psy_draw_cross(subj_scr, stim2_dva, YELLOW);
                    fail_flag = psy_await_saccade(stim1_dva,expt_str.task.sacc_timeout);
                    t_flash_dot = psy_draw_dot(flash_dva, GRAY, expt_str.task.flash_size, 1, 1,expt_str.task.flash_time);
                    if(fail_flag==0)
                        fail_flag = psy_await_fix(stim2_dva,expt_str.task.fix_timeout);
                    end
                   
                case 4 % flash after saccade
                    % draw second cross and wait for saccade
                    t_second_cross = psy_draw_cross(stim2_dva, YELLOW);
                    fail_flag = psy_await_saccade(stim1_dva,expt_str.task.sacc_timeout);
                    if(fail_flag==0)
                        fail_flag = psy_await_fix(stim2_dva,expt_str.task.fix_timeout);
                    end
                    psy_check_fix(stim2_dva,second_delay); 
                    t_flash_dot = psy_draw_dot(flash_dva, GRAY, expt_str.task.flash_size, 1, 1,expt_str.task.flash_time);
                otherwise
                    disp('invalid trial type');
            end
            
        end
        
        [response_flag,key_time] = psy_await_keypress(expt_str.task.response_keys,expt_str.task.response_timeout); 
        psy_collect_eyedata; 
        
        response_correct = 0; 
        if( (trial_type==1 && response_flag==2) || (trial_type~=1 && response_flag==1) ) % i.e flash absent, and user hit n key
            response_correct = 1; 
            bag_of_trials(q) = [];
        end
        tend = GetSecs; 
        
        % now add everything into the data structure
        data.trial_type(trial_id,1)    = trial_type; 
        data.stim1_dva(trial_id,:)     = stim1_dva;
        data.stim2_dva(trial_id,:)     = stim2_dva;
        data.flash_dva(trial_id,:)     = flash_dva;
        data.t_first_cross(trial_id,1) = t_first_cross - tbeg; 
        data.first_delay(trial_id,1)   = first_delay;
        data.t_flash(trial_id,1)       = t_flash_dot - tbeg; 
        data.t_second_cross(trial_id,1)= t_second_cross - tbeg; 
        data.second_delay(trial_id,1)  = second_delay;
        
        data.eye_stream{trial_id,1}    = eye_data_stream; 
        data.response_correct(trial_id,1) = response_correct;
        data.RT(trial_id,1)            = key_time - t_flash_dot; 
        
        
        trial_id = trial_id + 1;
    end
    
    psy_shutdown;
    ShowCursor; ListenChar(0);
    Screen('CloseAll');
catch
    shutdown_iscan;
    ShowCursor; ListenChar(0);
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end

% overall data structure
% expt_str.expt_name
% expt_str.subj_name
% expt_str.subj_id
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
% overall
%   - make expt_str as global and let it be modified by whoever
% psy_calibrate_iscan
%   - store eye data on a per-trial basis. no need to store for entire experiment
%   - no need to store raw eye signal values - only store dva values
%   - remove sigx_dev_limit and sigy_dev_limit from iscan structure
%   - force experimenter to specify calibration locations
%   - if no validation locations are specified, then validate at a random point within the square
%     specified by (minx,maxx) and (miny,maxy).
%     if validation locations are present, validate all locations.
%   - specs.calibration.cal_locations = n x 2 array
%   - specs.calibration.cal_data = n x 1 cell array with (i,j)th entry = 24x2 array of dva values
%   - likewise with specs.calibration.val_locations & iscan.calibration.val_data
%   - (that means psy_calibrate_iscan should both calibrate and validate
%   - specs.calibration.dva_error = n x 4 array of [xmean xstd ymean ystd], where xmean = mean error between
%     actual and iscan; xstd = standard deviation of iscan dvas; ymean, ystd likewise.
%   - rename max_fix_attempts as n_attempts
%   - specs.calibration.x_transform & specs.calibration.y_transform

return

function set_everything
global expt_str;

% initialize subject-specific parameters
expt_str.expt_name = 'saccade blindness';
expt_str.subj_name = input('enter subject name: ','s');
expt_str.subj_id   = input('enter subject number: ');

% initialize display
scr_num           = 2; % scr_num = 0 if you want to open a huge window across all screens
wptr              = screen(scr_num, 'openwindow');
expt_str.specs.screen      = init_display(scr_num);
expt_str.specs.screen.wptr = wptr;

% initialize eye tracker
expt_str.specs.iscan  = init_iscan;

return

function set_task_structure
global expt_str;

task.fix_window   = 3;
task.fix_timeout  = 1;   % timeout for psy_await_fix
task.sacc_timeout = 0.5; % timeout for psy_await_saccade
task.isi_range    = [0.1 0.5]; % inter-stim-interval (isi) is picked randomly from this range
task.ntrials      = [75 25 35 45]; % # of trials of each type sorted as no-flash, before, during, after
task.flash_time   = 0.03;
task.flash_size   = 0.3;
task.response_keys= [KbName('up') KbName('down')]; 
task.response_timeout = 3; 

n=0;
n=n+1;task.fields{n,1} = 'task       = variables that are fixed throughout the experiment';
n=n+1;task.fields{n,1} = 'fix_window = dva window in which fixation is checked';

expt_str.task = task;
return
