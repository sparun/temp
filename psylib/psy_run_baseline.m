% ----------------------------------------------------------------------
% psy_run_baseline function runs a motor reaction time measurement block
% ----------------------------------------------------------------------
% expt_str = psy_run_baseline(wptr,nreps,keyspecs)
% 
% INPUTS
%  wptr           = window pointer
%  nreps          = number of repetitions of left (or right) trials
%  keyspecs       = Keycode of Left/Right keys or cell array containing Left/Right key characters
%  
% OUTPUTS
%  expt_str       = experiment structure containing task parameters and data.
% 
% EXAMPLE
%  psy_run_baseline(wptr,10,{'z','m'})
%  will run the baseline block with 10 repetitions of left and right trials with 'z' as the left
%  assignment and 'm' as the right assignment keys.
%
% Pramod R T
% September 2013

function expt_str = psy_run_baseline(wptr,nreps,keyspecs)

% set up screens
scrnum = Screen('WindowScreenNumber',wptr);
scr = Screen('Resolution',scrnum); screenW = scr.width; screenH = scr.height;
black = BlackIndex(wptr); white = WhiteIndex(wptr);
Screen('FillRect',wptr,black); Screen('Flip', wptr);

psy_announce_block('Baseline Block',wptr);

trial_id = 1;
bag_of_trials = 1:2*nreps; 
isleftall(1:nreps) = 0; isleftall(nreps+1:2*nreps) = 1; 
leftloc = [(screenW/4-50) (screenH/2-50) (screenW/4+50) (screenH/2+50)]; % left
rightloc = [(3*screenW/4-50) (screenH/2-50) (3*screenW/4+50) (screenH/2+50)]; % right

quitstr = []; 
while ~isempty(bag_of_trials)
    stim_show_time = GetSecs + 0.5;
    current_trial = Sample(bag_of_trials);
    
    psy_fix_cross(wptr,[255 0 0],20,3); 
    
    % select location at which the circle will appear
    isleft(trial_id,1) = isleftall(current_trial); 
    location = rightloc; if(isleft(trial_id)), location = leftloc; end
    
    % center red line
    Screen('DrawLine', wptr, [200 0 0], screenW/2, 0, screenW/2, screenH, 5);
    % draw an oval at the left or right location
    Screen('FillOval', wptr, white, location);
    
    % show the entire screen (oval and red line) at time 'stim_show_time'
    t_stim_on = Screen('Flip', wptr, stim_show_time);
    
    % keyboard input, outputs are: responded [0|1], left_key, RT, toolong
    [response_flag,key_time] = psy_wait(wptr,5,keyspecs);
    
    % evaluate response
    if(response_flag>0)
        Screen('FillRect',wptr,black); Screen('Flip', wptr); % fill screen with black if key pressed
        RT(trial_id,1) = key_time - t_stim_on;
        % if left key and left target, or right key and right target, then response_correct = 1
        if( (response_flag==1 && isleft(trial_id)==1) || (response_flag==2 && isleft(trial_id)==0) )
            response_correct(trial_id,1) = 1;
            bag_of_trials(find(bag_of_trials==current_trial)) = [];
        end
    end
    if(response_flag==-1)
        psy_announce_block('Experiment paused', wptr);
    end
    if(response_flag==-2)
        quitstr = 'Warning: Subject quit early'; 
        break;
    end
    
    trial_id = trial_id + 1;
end

expt_str.task.ntrials = 2*nreps;
expt_str.task.leftloc = leftloc; 
expt_str.task.rightloc = rightloc; 
expt_str.task.keys = keyspecs;

expt_str.data.RT               = RT;
expt_str.data.isleft           = isleft;
expt_str.data.response_correct = response_correct;
expt_str.data.notes{1,1}       = quitstr; 

end
