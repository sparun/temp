% -------------------------------------------------------------------
% This function calibrates ISCAN.
% Computes the coefficient matrix for transforming ISCAN signals
% to dva's
% Displays crosses at the specified points and checks for fixation.
% If fixation is detected at all the points, then calibration is
% performed using the ISCAN signals obtained at all the calibration points.
% In case of failure to detect fixation at any point, the process is
% restarted from the 1st point.  Maximum of 5 attempts are given for the
% subject to fixate.
% -------------------------------------------------------------------
% fail_flag = psy_calibrate_iscan(cal_locations, val_locations)
% REQUIRED INPUTS
%  cal_locations = (x,y) dva's to be used for calibration
% OPTIONAL INPUTS
%  val_locations = (x,y) dva's to be used for validation
%                  Default value = random point in the biggest rect
%                  enclosed by the calibration points
% OUTPUTS
%  fail_flag = 1 if calibration succeeds, 0 otherwise.
% METHOD
%     
% NOTES
% 
% EXAMPLE
% cal_locations = [-10 0; 0 10; 10 0];
% psy_calibrate_iscan(cal_locations);
%  Performs calibration using the given 4 points
% REQUIRED SUBROUTINES
%  collect_fix_data
%  psy_transform_iscan_data
%  validate_iscan_calibration
%
% Zhivago KA
% 07 Dec 2010

function fail_flag = psy_calibrate_iscan(cal_locations, val_locations)

global expt_str;
fail_flag = 1;

iscan = expt_str.specs.iscan;
n_samples = expt_str.task.check_fix_samples;

n_attempts = 5;

% setting default values for the calibration points
if ~exist('cal_locations'), return; end

expt_str.specs.calibration.cal_locations = cal_locations;

% initializing the required variables
xy_dva = []; % to hold the dva values of the subject's eye movements
aug_cal_dva = []; % augmented expected dva matrix
n_cal_pts = size(cal_locations,1);

% displaying instruction about calibration
show_cal_instructions();

for attempts = 1:n_attempts
    fix_data = [];
    % collect fixation data at all the specified calibration points
    for pt = 1:n_cal_pts
        cal_data{pt,1} = cal_locations(pt,:);
        [fail_flag, cal_data{pt,2}] = collect_fix_data(cal_locations(pt,:));
        if fail_flag == true, break; end
        fix_data = [fix_data; cal_data{pt,2}];
    end
    if fail_flag == 0, break; end
end

if fail_flag == 0
    % computing the transformation coefficients matrix that will be used
    % to convert ISCAN signals to (x,y) dva, i.e. display coordinates
    aug_fix_data = [fix_data ones((n_samples * n_cal_pts), 1)];
    for pt = 1:n_cal_pts
        for rep = 1:n_samples
            aug_cal_dva = [aug_cal_dva; cal_locations(pt,:)];
        end
    end
    x_transform = regress(aug_cal_dva(:,1), aug_fix_data);
    y_transform = regress(aug_cal_dva(:,2), aug_fix_data);
    expt_str.specs.calibration.x_transform = x_transform;
    expt_str.specs.calibration.y_transform = y_transform;
    xy_dva = psy_transform_iscan_data(fix_data);
    for pt = 1:n_cal_pts
        cal_data{pt,3} = xy_dva((pt-1)*n_samples+1:pt*n_samples, :);
    end
    
    expt_str.specs.calibration.cal_data = cal_data;
    
    % setting default values
    if ~exist('val_locations')
        cal_locations = expt_str.specs.calibration.cal_locations;
        x_range = fix([min(cal_locations(:,1)) max(cal_locations(:,1))]);
        y_range = fix([min(cal_locations(:,2)) max(cal_locations(:,2))]);
        val_locations = [randi(x_range) randi(y_range)];
    end
    
    fail_flag = validate_iscan_calibration(val_locations);
end
return;

% -------------------------------------------------------------------
% This function displays a crossbar stimulus at a specified
% (x_dva,y_dva), collects the eye data and along with the
% transformed eye data (in terms of dva's) returns true if
% the subject is fixating, otherwise false.
% The last 100ms data is used to detect fixation.
% -------------------------------------------------------------------

function [fail_flag, fix_data] = collect_fix_data(xy_dva)

global eye_data_stream;
global expt_str;

task  = expt_str.task;
iscan = expt_str.specs.iscan;

n_samples = task.check_fix_samples;

sigx_dev_limit = 4;
sigy_dev_limit = 2;

fail_flag = true; 

psy_draw_cross(xy_dva, [255 255 255]); % draw cross at a calibration point
WaitSecs(1.5);
pktdata = IOPort('Read', iscan.port); % read ISCAN data from the serial port
eye_data_stream = [eye_data_stream pktdata]; % storing a copy in the global buffer
fix_data = psy_decode_bin_stream(pktdata); % decoding the raw ISCAN data
fix_data = fix_data(:,1:2);
fix_data = fix_data(end-n_samples+1:end,:); % using only the last 100ms data
% check if the ISCAN signals are within a specified error limit to
% say if the subject is fixating
if( all(std(fix_data(:,1)) <= sigx_dev_limit) &&...
    all(std(fix_data(:,2)) <= sigy_dev_limit) )
    fail_flag = false;
end
psy_change_screen_color(1);
WaitSecs(.5);
return

% -------------------------------------------------------------------
% This function displays necessary instructions to the subject before
% performing the calibration procedure
% -------------------------------------------------------------------

function show_cal_instructions()
global expt_str;
screen_str = expt_str.specs.screen; 
wptr = screen_str.wptr;
x = 600; y = 300; spacing = 50;
Screen('DrawText', wptr, 'I N S T R U C T I O N S', x, y);
y=y+spacing;   Screen('DrawText', wptr, '----------------------', x, y);
y=y+spacing*2; Screen('DrawText', wptr, '1. Crosses will appear at different places on the screen', x, y);
y=y+spacing;   Screen('DrawText', wptr, '2. Please look at a cross till it disappears', x, y);
y=y+spacing*3; Screen('DrawText', wptr, 'Press any key to continue...', x, y);
Screen('Flip', wptr);
KbStrokeWait;
return

% -------------------------------------------------------------------
% This function validates the calibration process.
% -------------------------------------------------------------------
function fail_flag = validate_iscan_calibration(val_locations)

global expt_str;
fail_flag = true;

% initializing variables
pts = size(val_locations, 1);

expt_str.specs.calibration.val_locations = val_locations;

% performing validation
for rep = 1:pts
    psy_draw_cross(val_locations(rep,:), [255 255 255]);
    % Waiting for 3 seconds to achieve fixation
    [fail_flag, fix_dva] = psy_await_fix(val_locations(rep,:), 3);
    if fail_flag == true, break; end
    val_data{rep, 1} = val_locations(rep,:);
    val_data{rep, 2} = fix_dva;
    dva_error(rep,1) = mean(val_locations(rep,1) - fix_dva(:,1));
    dva_error(rep,2) = std(fix_dva(:,1));
    dva_error(rep,3) = mean(val_locations(rep,2) - fix_dva(:,2));
    dva_error(rep,4) = std(fix_dva(:,2));
    WaitSecs(0.5);
    psy_change_screen_color([0 0 0]);
    WaitSecs(0.5);
    expt_str.specs.calibration.val_data  = val_data;
    expt_str.specs.calibration.dva_error = dva_error;
end
return