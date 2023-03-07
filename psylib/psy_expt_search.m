% psy_expt_search -> runs a full visual search experiment
% expt_str = psy_expt_search(varargin)
%            Arguments are (in this order)
%            images,abpairs,setsize,nrepsperdir,posjitter,boxscale,sizejitter,locmatrix,keyspecs,timespecs,block_name,wptr,rand_flag

% REQUIRED INPUTS 
%   images          = n images indexed in the same way as abpairs
%   abpairs         = npairs x 2 matrix specifying [T D] (giving [1 2] will NOT run [2 1] automatically)
%                        Can be used to define several types of search
%                        Simple search (default)
%                             If abpairs has two columns, target is placed either left or right
%                             If abpairs is empty, generate all possible pairs of images with either image as target
%                        Complex search 
%                             If abpairs has more than two columns, then this experiment becomes a complex search experiment
%                             with multiple distracters. (cmplxsrch_flag = 1)
%                        Present/Absent Search
%                             If both items are same in a row, this is a target-absent trial (presabs_flag = 1)
%                             In this case, center line is not displayed, and response_correct is handled accordingly.
%
%   genbapairs_flag = 1 to generate BA pairs too (default = 0)
%   setsize         = [m n nitems] creates an m x n grid with nitems located randomly in this grid
%                        [m n] creates a m x n grid with all items at all locations
%                        If nitems is even, put equal numbers of items on either side (if odd, split them randomly on each trial)
%                        If setsize is a npairs x 3 matrix, each imgpair is run at that setsize
%   nrepsperdir     = number of repetitions for each direction (AB/BA) of an imgpair
%                        If nrepsperdir is a number, the same number of reps apply for all abpairs
%                        If nrepsperdir is a vector, it specifies the number of reps for each imgpair
%                        If nrepsperdir is odd, then the extra rep will be chosen randomly as left/right and the remaining are balanced
%
% OPTIONAL INPUTS
%   posjitter       = [xjitter yjitter] array specifying jitter of items, as a fraction of boxscale 
%                        posjitter = 0.25 jitters the position of each item by 0.25*boxscale on either side of the box center
%                        posjitter = [0.1 0.25] jitters the position of each item by 0.1 and 0.25 times the width and height of the box 
%   boxscale        = [widthscale heightscale] specifies the scale of a rectangular bounding box 
%                        if boxscale = 1.5 the program assumes a square box (default) 
%                        if boxscale = [1.2 1.5] => the box will be 1.2 times the maxwidth of all objects and 1.5 x maxheight
%   sizejitter      = 2xk matrix specifying the distracter size distribution
%                        sizejitter(1,k) specifies the probability of occurrence of kth distracter
%                        sizejitter(2,k) specifies the scaling level of kth distracter
%                        default: sizejitter = [1;1]
%                        Example: [0.5 0.25 0.25; 1 0.75 1.25] specifies half the distracters to be
%                           unscaled, 25% to be scaled down to 0.75 times of their size, and 25% to be
%                           scaled up to 1.25 times their size.
%                        If cmplxsrch_flag = 1, the first row will be treated as the distracter distribution
%                        and the second row will be ignored. However, the default value will result in
%                        error. So, specifying the appropriate sizejitter is a must for complex searches.
%   locmatrix       = m x n array containing 0s and 1s, with 1s specifying possible target locations
%                        Target location is chosen at random on each trial from this location matrix.
%                        locmatrix can be a cell array of matrices corresponding to setsize
%                        default: [] allows all locations in the array for target.
%   keyspecs        = [key1 key2] specifying character strings for the response keys
%                        For left/right targets, key1 & key2 are the left & right keys respectively
%                        For present/absent targets, key1 & key2 are target present & absent
%   timespecs       = [fixation_time timeout target_preview_time]
%                        default: [0.5 5 0]
%                        If target_preview_time is supplied, target is shown in isolation before array onset.
%                        If target_preview_time is not supplied or 0, no target preview
%   block_name      = Name of experimental block to be displayed on the screen
%   wptr            = wptr is the psytb screen pointer passed on from the program that is calling this function
%   rand_flag       = If 1, randomizes the trial order (default)
%                        If 0, produces sequential trials in the same order as abpairs

% EXAMPLE
%   see psy_expt_template.m

% Credits: PramodRT/ZhivagoK/SPArun
% Change log
%     01/09/2013 (Pramod) - First version
%     19/10/2013 (Pramod) - added default handler in validate parameter block: scale_factor = ones(length(scaled_images),1);
%     13/02/2014 (Pramod) - added support for different setsizes & nrepsperdir; chooses left/right randomly if nrepsperdir = 1
%     21/02/2014 (Arun)   - reordered some parameters and tightened documentation
%     02/04/2014 (Pramod) - added setsize_run as one of the fields in expt_str.data
%     12/05/2017 (Pramod/Georgin/Zhivago) - remove automatic image resizing code and associated arguments
%                                         - balanced number of left/right trials for 1-rep condition
%                                         - calling psy_wait to compensate for flip misses
%                                         - storing all the dependent code and images in expt_str using packdeps
%     16/09/2017 (Aakash) - added functionality for unequal box sizes

function expt_str = psy_expt_search(varargin)
% set default values for all parameters
[images,abpairs,genbapairs_flag,setsize,nrepsperdir,posjitter,...
    boxscale,sizejitter,locmatrix,keyspecs,...
    timespecs,block_name,wptr,rand_flag,...
    cmplxsrch_flag,presabs_flag] = set_parameters(varargin);

% Validate all parameters
[boxsize] = validate_parameters(images,posjitter,sizejitter,setsize,locmatrix,wptr,boxscale);

% create images of all required sizes
all_images = create_allsizeimages(images,sizejitter);

% create the condition matrix with each row containing [T D pairid isleft ispresent]
cond_mat = get_condmat(abpairs,genbapairs_flag,nrepsperdir,presabs_flag);

% initialize the display and set the task parameters
[expt_str,startexp,keys_to_listen,screenW,screenH,black] = set_everything(block_name,setsize,locmatrix,boxscale,posjitter,sizejitter,wptr,timespecs,keyspecs);

%psy_verify_dvi(wptr);

% display the task name
psy_announce_block(block_name,wptr,30,[60 120 180]);

% setup and run the main block
ntrials = size(cond_mat,1); ndist = size(abpairs,2) - 1;
bag_of_trials = (1:ntrials)'; trial_id = 1; quit_flag = 0; ispresent = [];

while(~isempty(bag_of_trials) && quit_flag==0)
    
    % determine trial number
    trial_num = bag_of_trials(1); if(rand_flag), x = randperm(length(bag_of_trials)); trial_num = bag_of_trials(x(1));end
    
    pairid = cond_mat(trial_num,end-1-presabs_flag); tarid = cond_mat(trial_num,1);
    isleft_condition = cond_mat(trial_num,end-presabs_flag);
    
    targetpos = get_targetpos(setsize(pairid,:),locmatrix{pairid},isleft_condition);
    distids = cond_mat(trial_num,2:ndist+1);
    if cmplxsrch_flag == 1
        img_array = psy_make_srcharray(all_images{tarid,1},all_images(distids,1),setsize(pairid,:),boxsize,targetpos,posjitter,sizejitter(1,:));
    else
        img_array = psy_make_srcharray(all_images{tarid,1},all_images(distids,:),setsize(pairid,:),boxsize,targetpos,posjitter,sizejitter(1,:));
    end
    
    isleft_trials(trial_id,1) = isleft_condition;
    location(trial_id,1) = targetpos;
    td(trial_id,:) = cond_mat(trial_num,1:end-2-presabs_flag);
    setsize_run(trial_id,:) = setsize(pairid,:);
    
    if(presabs_flag),
        ispresent(trial_id,1) = cond_mat(trial_num,end);
        td(trial_id,:) = cond_mat(trial_num,1:end-2-presabs_flag);
    end
    
    texture = Screen('MakeTexture',wptr,img_array);
    
    % display fix spot
    t_fix_on(trial_id,1) = psy_fix_cross(wptr,[255 0 0],20,3);
    psy_wait(wptr,expt_str.task.fixation_time);
    
    % handle target preview
    if(length(timespecs)==3)
        target_preview_time = timespecs(3);
        target_tex = Screen('MakeTexture',wptr,all_images{tarid,1});
        Screen('DrawTexture',wptr,target_tex); Screen('Flip',wptr);
        psy_wait(wptr,target_preview_time);
    end
    
    % prepare target-distractor array
    Screen('DrawTexture',wptr,texture); % draw array with target and distractor
    if(~presabs_flag)
        Screen('DrawLine',wptr,[200 0 0],screenW/2, 0, screenW/2, screenH, 5); % draw center line
    end
    
    % display target-distractor array
    [~,t_stim_on(trial_id,1)] = Screen('Flip',wptr);
    
    % wait for key press
    [response_flag, key_time(trial_id,1)] = psy_wait(wptr,expt_str.task.timeout,keys_to_listen);
    
    % evaluate response
    response_correct(trial_id,1) = -1; RT(trial_id,1) = NaN; % response is -1 and RT is NaN by default
    if(response_flag > 0)
        Screen('FillRect',wptr,black); Screen('Flip', wptr); % fill screen with black when key is pressed
        response_correct(trial_id,1) = 0;
        RT(trial_id,1) = key_time(trial_id,1) - t_stim_on(trial_id,1);
        
        % Response is deemed correct if
        % first key and left target, or second key and right target
        % first key and target present, or second key and target absent
        if(presabs_flag==0), cond_to_check = isleft_trials(trial_id); else cond_to_check = ispresent(trial_id); end;
        if((response_flag == 1 && cond_to_check == 1)|(response_flag == 2 && cond_to_check == 0))
            response_correct(trial_id,1) = 1;
            bag_of_trials(bag_of_trials == trial_num) = [];
        end
    elseif(response_flag==-1)
        psy_announce_block('Experiment paused',wptr);
    elseif(response_flag==-2)
        quit_flag = 1;
    end
    
    fprintf('%d trials remaining \n',length(bag_of_trials));
    % setup for next trial
    trial_id=trial_id+1;
    Screen('Close');
    
    clear img_array;
end
endexp = GetSecs;
Screen('FillRect',wptr, black); Screen('Flip', wptr);

isleft_trials(ispresent == 0) = NaN;

expt_str.data.cmplxsrch_flag   = cmplxsrch_flag;
expt_str.data.presabs_flag     = presabs_flag;
expt_str.data.td               = td;               % target and distracter ids for each trial
expt_str.data.isleft           = isleft_trials;    % target side on each trial (0 if right, 1 if left) and NaN if target-absent
expt_str.data.ispresent        = ispresent;        % in present-absent search, =1 for target present and =0 for target absent. Empty for other searches.
expt_str.data.locations        = location;         % target locations in the array for each trial
expt_str.data.setsize_run      = setsize_run;      % setsize of each trial [ntrials x 3]
expt_str.data.RT               = RT;               % reaction time for each trial
expt_str.task.boxsize          = boxsize;          % size of the imaginary box in which items are displayed
expt_str.task.t_fix_on	       = t_fix_on;         % fix on time for each trial
expt_str.task.t_stim_on        = t_stim_on;        % stim on time for each trial
expt_str.task.t_keypress       = key_time;         % key press time for each trial
expt_str.data.response_correct = response_correct; % 1 if correct response, 0 if incorrect
expt_str.data.total_time       = endexp - startexp;% total expt time

% explain each field
n=0;
n=n+1; expt_str.data.fields{n,1} = 'cmplxsrch_flag   = 1 if complex search, else 0';
n=n+1; expt_str.data.fields{n,1} = 'presabs_flag     = 1 if target present-absent search,else 0';
n=n+1; expt_str.data.fields{n,1} = 'genbapairs_flag  = 1 to generate BA pairs too, else 0';
n=n+1; expt_str.data.fields{n,1} = 'td               = target and distracter IDs for each trial';
n=n+1; expt_str.data.fields{n,1} = 'isleft           = target locations (1 if left, 0 if right)';
n=n+1; expt_str.data.fields{n,1} = 'ispresent        = target present (=1) or target absent (=0) (Empty if presabs_flag = 0)';
n=n+1; expt_str.data.fields{n,1} = 'locations        = target locations in the array';
n=n+1; expt_str.data.fields{n,1} = 'RT               = reaction time in seconds for each trial';
n=n+1; expt_str.data.fields{n,1} = 'response_correct = response in each trial (1 if correct, 0 if wrong)';
n=n+1; expt_str.data.fields{n,1} = 'total_time       = total experiment time in seconds';

% explain each task field
n=0;
n=n+1; expt_str.task.fields{n,1} = 'expt_name        = name of experiment';
n=n+1; expt_str.task.fields{n,1} = 'setsize          = [nrows ncols nitems]';
n=n+1; expt_str.task.fields{n,1} = 'locmatrix        = allowed target locations = 1, otherwise zero';
n=n+1; expt_str.task.fields{n,1} = 'boxscale         = relative size of the grid of each image in the search array';
n=n+1; expt_str.task.fields{n,1} = 'posjitter        = position jitter wrt boxsize';
n=n+1; expt_str.task.fields{n,1} = 'sizejitter       = 1st row = probability distribution, 2nd row = size of distracters';
n=n+1; expt_str.task.fields{n,1} = 'wptr             = ptb window pointer';
n=n+1; expt_str.task.fields{n,1} = 'fixation time    = time for which fix cross is displayed';
n=n+1; expt_str.task.fields{n,1} = 'timeout          = max time for subject to respond';
n=n+1; expt_str.task.fields{n,1} = 'keyspecs         = keys used to indicate response';
n=n+1; expt_str.task.fields{n,1} = 'boxsize          = size of the imaginary itembox in pixels';
n=n+1; expt_str.task.fields{n,1} = 't_fix_on         = fix on time for each trial';
n=n+1; expt_str.task.fields{n,1} = 't_stim_on        = stim on time for each trial';
n=n+1; expt_str.task.fields{n,1} = 't_keypress       = keypress time for each trial';

% add dependency info to expt_str
expt_str.depstr = packdeps(mfilename);

% save data to file
out_file = [block_name,date];
save(out_file,'expt_str');

end

function varargout = set_parameters(varargin);

argall = {'images','abpairs','genbapairs_flag', 'setsize','nrepsperdir','posjitter','boxscale','sizejitter','locmatrix','keyspecs','timespecs','block_name','wptr','rand_flag','cmplxsrch_flag','presabs_flag'};
for n = 1:length(varargin{1}), eval([argall{n} '=varargin{1}{n};']); end;

if ~exist('wptr', 'var') | isempty(wptr)
    error('window pointer missing');
end

if isempty(genbapairs_flag), genbapairs_flag = 1; end
if isempty(abpairs) % if abpairs is empty, generate all possible target present image pairs.
    n = length(images); abpairs = nchoosek(1:n,2);
else
    if genbapairs_flag == 0 & mod(nrepsperdir,2) == 1, error('nrepsperdir cannot be odd'); end
end

ndist = size(abpairs,2) - 1; % number of distracters

if size(setsize,1) == 1, setsize = repmat(setsize,size(abpairs,1),1); end
if size(setsize,2) == 2, setsize(:,3) = setsize(:,1).*setsize(:,2); end % nitems = m x n
if isempty(locmatrix),
    for i = 1:size(setsize,1)
        locmatrix{i,1} = ones(setsize(i,1),setsize(i,2));
    end
end

% if set size has more than one row, then it should be equal to the number of image pairs.
% if(size(setsize,1)~=size(abpairs,1)), error('number of setsizes not equal to number of image pairs'); end

if(~exist('block_name') || isempty(block_name)),block_name = 'Visual search'; end;
if(~exist('posjitter')||isempty(posjitter)), posjitter=0; end; 
if(~exist('sizejitter')||isempty(sizejitter)), sizejitter = [ones(1,ndist)/ndist; ones(1,ndist)]; end;
if(~exist('boxscale')||isempty(boxscale)), boxscale = 1.5; end; % specifies default boxscale

% If abpairs has more than 2 columns of distracters, flag it as complex search
cmplxsrch_flag = 0; if(size(abpairs,2)>2), cmplxsrch_flag = 1; end;
if(cmplxsrch_flag==1), sizejitter(2,:) = ones(1,ndist); end; % overwriting any non-unity values in sizejitter

% If in abpairs the target & any distracter are same, presabs_flag = 1
presabs_flag = 0;
for i = 2:size(abpairs,2)
    imgpairdiff = diff(abpairs(:,[1 i])')';
    if(~isempty(find(imgpairdiff == 0,1))), presabs_flag = 1; end
end

for n = 1:length(argall), eval(['varargout{n}=' argall{n} ';']); end;

end


function [boxsize] = validate_parameters(images,posjitter,sizejitter,setsize,locmatrix,wptr,boxscale)

[nrows,ncols,~] = cellfun(@size,images);
% if H(1) > W(1); maxisz = H; else, maxisz = W; end
% if sum(diff(maxisz)) ~= 0
%     error('the longer dimension for all the images are not identical\n');
% end
maxnrows = max(nrows); % longest dim across all images
maxncols = max(ncols); % smallest dim across all images
if(numel(boxscale)==1), maxnrows = max([maxnrows,maxncols]); maxncols = maxnrows; boxscale = [boxscale boxscale]; end

% get the largest size factor for the distracter
max_size = max(sizejitter(2,:));

% calculate the size of the box
boxsize(1) = round(boxscale(1) * maxnrows * max_size);
boxsize(2) = round(boxscale(2) * maxncols * max_size);

% maximum possible position jitter
rowjitter = (boxsize(1) - maxnrows)/(2*(boxsize(1)));
coljitter = (boxsize(2) - maxncols)/(2*(boxsize(2)));

if(exist('posjitter')&& numel(posjitter) == 1), posjitter = [posjitter posjitter]; end % specifies default posjitter
if (posjitter(1) > rowjitter || posjitter(2) > coljitter)
    error(sprintf('position jitter > maximum possible jitter. posjitter given = [%2.2f %2.2f], max = [%2.2f, %2.2f]',posjitter(1),posjitter(2),rowjitter,coljitter)); 
end

if length(locmatrix) ~= size(setsize,1)
    error('locmatrix should contain the same number of matrices as that of setsizes or abpairs');
end

% check if locmatix is compatible with set size
for i = 1:size(setsize,1)
    if (size(locmatrix{i},1) ~= setsize(i,1) || size(locmatrix{i},2) ~= setsize(i,2))
        error('size of location matrix is not compatible with the set size. Check variables: locmatrix');
    end
    
    % check if nitems can be embedded in the array
    if setsize(i,3) > setsize(i,1)*setsize(i,2)
        error('required number of items cannot be embedded in the array. Check variables: setsize');
    end
end

% check if given array with given boxsize can be displayed on the screen
scrnum = Screen('WindowScreenNumber',wptr); resolution = Screen('Resolution',scrnum);
screencols = resolution.width; screenrows = resolution.height;
maxrows = max(setsize(:,1)); maxcols = max(setsize(:,2));
if( (maxrows*boxsize(1)) > screenrows || (maxcols*boxsize(2)) > screencols)
    error(sprintf('items of size [%d %d] pixels making %d by %d array will NOT fit on screen with [%d %d]',boxsize(1),boxsize(2),maxrows,maxcols,screenrows,screencols)); 
end

% check if sizejitter probabilities add up to 1
if(sum(sizejitter(1,:))~=1)
    error('The probability distribution of sizes should sum to 1. Check variables: sizejitter');
end

end

function all_images = create_allsizeimages(images,sizejitter)
size_factor = sizejitter(2,:);
% generate images of every size specified by sizejitter.
for i = 1:length(images)
    for j = 1:length(size_factor)
        all_images{i,j} = uint8(imresize(images{i},size_factor(j)));
    end
end

end

%ZPG Check if all image pairs have AB, BA versions.
%ZPG for image pairs that dont have check nrepsperdir is even, else exit
function cond_mat = get_condmat(abpairs,genbapairs_flag,nrepsperdir,presabs_flag)

% cond_mat will have three columns
% column 1      : Target ID
% column 2      : Distracter ID
% column 3      : pair ID
% column 4      : 1 for left and 0 for right
% column 6      : target present = 1, absent = 0 (only if presabs_flag = 1)

npairs = size(abpairs,1);

% prepare condition matrix by grouping image pairs
cond_mat = [];
for i = 1:npairs
    p = abpairs(i,:);
    % creating left & right reps for each unique AB pair
    if genbapairs_flag == 0
        leftpairs = repmat([p i 1], nrepsperdir/2, 1);
        rightpairs = repmat([p i 0], nrepsperdir/2, 1);
        cond_mat = [cond_mat; leftpairs; rightpairs];
    else
        abp = repmat(p, nrepsperdir, 1);
        bap = repmat(fliplr(p), nrepsperdir, 1);
        isleftabp = [ones(ceil(nrepsperdir/2),1); zeros(floor(nrepsperdir/2),1)];
        if rand > 0.5, isleftabp = 1 - isleftabp; end; % ensure that abpairs are not always more on left 
        isleftbap = 1 - isleftabp;
        cond_mat = [cond_mat; [abp, i*ones(nrepsperdir,1), isleftabp]; [bap, i*ones(nrepsperdir,1), isleftbap]];
    end
end

% Detect and flag present-absent trials
if presabs_flag == 1
    cond_mat(:,end+1) = 1;
    for i = 2:size(abpairs,2) % compare targetid with each distracter column
        imgpairdiff = diff(cond_mat(:,[1 i])')';
        index = find(imgpairdiff == 0);
        cond_mat(index,end) = 0;  % last column indicates target-present trial
    end
end

end

function targetpos = get_targetpos(setsize,locmatrix,isleft_condition)

nrows = setsize(1); ncols = setsize(2);

% depending on isleft_condition pick a random target location from locmatrix
target_locations = find(locmatrix == 1);
if isleft_condition == 1
    left_locs = target_locations(target_locations <= (nrows*ncols)/2);
    r = randperm(length(left_locs));
    targetpos = left_locs(r(1));
else
    right_locs = target_locations(target_locations > (nrows*ncols)/2);
    r = randperm(length(right_locs));
    targetpos = right_locs(r(1));
end

end

function [expt_str,startexp,keys_to_listen,screenW,screenH,black] = set_everything(block_name,setsize,locmatrix,boxscale,posjitter,sizejitter,wptr,timespecs,keyspecs)

scrnum = Screen('WindowScreenNumber',wptr);
scr = Screen('Resolution',scrnum); screenW = scr.width; screenH = scr.height;
HideCursor; ListenChar(2);
KbName('UnifyKeyNames');

expt_str.task.expt_name = block_name;
expt_str.task.setsize = setsize;
expt_str.task.locmatrix = locmatrix;
expt_str.task.boxscale = boxscale;
expt_str.task.posjitter = posjitter;
expt_str.task.sizejitter = sizejitter;
expt_str.task.wptr = wptr;

% define main task parameters
expt_str.task.fixation_time = timespecs(1); % time for which fix cross is displayed
expt_str.task.timeout       = timespecs(2);   % max time for subject to respond
expt_str.task.keyspecs      = keyspecs; % Keys used for collecting response

startexp = GetSecs;
black = BlackIndex(wptr);
Screen('FillRect',wptr, black); Screen('Flip', wptr);
keys_to_listen = [KbName(keyspecs(1)) KbName(keyspecs(2)) KbName('shift') KbName('control') KbName('2@')];

clc;
end
