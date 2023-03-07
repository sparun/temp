% computes the following fixation statistics for the groups in a given trial
% max, min, mean, and standard deviation of x & y dva coordinates
%    - t_on is the stim on time
%    - t_off is the stim off time
%    - t_trial_beg is the trial begin time
%    - fix_stats will contain the fixation statistics
function fix_stats = compute_fix_stats(t_on, t_off, t_trial_beg)
global L2_data;
% data structure to store the fixation statistics
fix_stats = [];
% collecting eye data
eyedata = get_eyedata_fragment(t_on, t_off);
% computes the corresponding eye coordinates using the calibration
% coefficents obtained via the appropriate validation block, i.e the
% most recent validation block that was run before the trial under
% consideration
if ~isempty(L2_data.specs.val_data(1,1).t_beg)
    nvals = length(L2_data.specs.val_data(end,1).t_beg);
    for v = nvals:-1:1
        if t_trial_beg > L2_data.specs.val_data(end,1).t_end(v,1), break; end
    end
    num_pts = size(eyedata,1);
    xy_data = [eyedata ones(num_pts,1)];
    eye_dva = [(xy_data * L2_data.specs.val_data(end,1).x_transform(:,v)) (xy_data * L2_data.specs.val_data(end,1).y_transform(:,v))];
else
    eye_dva = eyedata;
end
% computing the fixation statistics
xmean = mean(eye_dva(:,1));
xstd  = std(eye_dva(:,1));
xmin  = min(eye_dva(:,1));
xmax  = max(eye_dva(:,1));
ymean = mean(eye_dva(:,2));
ystd  = std(eye_dva(:,2));
ymin  = min(eye_dva(:,2));
ymax  = max(eye_dva(:,2));
fix_stats = [xmin xmax xmean xstd ymin ymax ymean ystd];
end