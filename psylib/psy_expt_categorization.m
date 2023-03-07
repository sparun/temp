% psy_categorization -> generic categorization code to handle n categories
%
% Required Inputs
%    catimages    : images of all the stimuli to be used
%    catlabels    : category label for each stimulus
%    catnames     : list of unique category names
%                   First catname should correspond to lowest catlabel and
%                   last catname should correpond to highest catlabel.
% Optional Inputs
%    nreps        : number of repetitions/trials for each stimulus
%    responsekeys : response keys corresponding to categories in catnames
%    stimdur      : duration for which stimulus should be presented
%    noisedur     : duration for which noise mask should be presented
%    timeout      : maximum time to wait for subject response
%    wptr         : psychtoolbox window pointer
%    flag_packdep : if 1 (default), pack all dependent codes, if 0, do nothing
%
% Notes
%    (1) default values for responsekeys applies only to the 2-category case
%    (2) number of catnames should be equal to the number of categories and
%        not to the number of images
%    (3) responsekeys -> category mapping is implicit, i.e. it will follow
%        the order in categories appear in the catlabels argument
%    (4) expt_str is not being saved

% Credits: Ratan, Arun, Zhivago
% Changelog
%   05/03/2014 (Ratan/Arun/Zhivago)       First version
%   12/05/2017 (Georgin/Pramod/Zhivago)   Moved to psy_wait instead of psy_await_keypress, added packdeps
%   10/11/2017 (Georgin/Zhivago)          - replaced subfunction announce_block to call psy_announce block instead
%                                         - added packdeps, changed expt_str to a local variable, included 'space' as a reponse key.
%   31/05/2019 (Arun/Aakash)              Added fixdur as a task parameter

function expt_str = psy_expt_categorization(catimages,catlabels,catnames,nreps,responsekeys,fixdur,stimdur,noisedur,timeout,wptr,flag_packdep)

% check everything & set defaults
if(length(catimages)~=length(catlabels)), error('category images and labels differ in length'); end;
if(ischar(catnames)), catnames = {catnames, ['Non-' catnames]}; end; % e.g. 'Animals' becomes {'Animals','Non-Animals'}
if(~exist('nreps') | isempty(nreps)), nreps = 4; end;
if(~exist('fixdur') | isempty(fixdur)), fixdur = 0.75; end
if(~exist('stimdur') | isempty(stimdur)), stimdur = 0.05; end;
if(~exist('noisedur') | isempty(noisedur)), noisedur = 1.0; end;
if(~exist('timeout') | isempty(timeout)), timeout = 5; end;
if(~exist('responsekeys') | isempty(responsekeys)), responsekeys = {'z','m'}; end;
if(~exist('flag_packdep')|isempty(flag_packdep)),flag_packdep=1;end;
if(length(unique(catlabels))~=length(responsekeys)),error('Mismatch in number of catlabels and responsekeys'); end;
% Initialise expt_str
expt_str=set_everything(catnames,nreps,fixdur,stimdur,noisedur,timeout,responsekeys);

Screen('FillRect', wptr, [0,0,0]); Screen('Flip',wptr); HideCursor; ListenChar(2);

% Announce the experiment...
str = sprintf('You will be doing a %d-class categorization task \n\n\n',length(catnames)); 
for cid = 1:length(catnames)
    str=sprintf('%s \n %d) If you see a %s, press %s \n',str,cid,catnames{cid},responsekeys{cid}); 
end
psy_announce_block(str,wptr); 

% Generate the noise screen which will be the same size as the images...
noise_dim = max(cellfun('length',catimages));
noisescreen = randn(noise_dim,noise_dim); noisescreen = 255*noisescreen/max(noisescreen(:));
noise = Screen('MakeTexture',wptr,noisescreen);

trialbag = repmat([1:length(catimages)]',nreps,1); ulabel = unique(catlabels); trial_id = 1;
while(~isempty(trialbag))
    % Display the fixation cross for 750 ms
    t_fix_on = psy_fix_cross(wptr,[255 0 0],20,3); psy_wait(wptr,fixdur);
    
    % choose a random object from the trialbag
    img_id = Sample(trialbag); stim = Screen('MakeTexture', wptr, catimages{img_id});
    
    % Display the stimulus for the stim_duration
    Screen('DrawTexture', wptr, stim); [~,~,tstim,~,~] = Screen('Flip', wptr); Screen('Close', stim);
    
    % Keep checking for response during stim, noise and timeout periods
    RT = NaN;
    [response_flag, t2] = psy_wait(wptr, stimdur,responsekeys);
    if(response_flag==0) % Display the noise mask for the noise_duration
        Screen('DrawTexture', wptr, noise); [~,~,tnoise,~,~] = Screen('Flip', wptr);
        [response_flag,t2]=psy_wait(wptr,noisedur,responsekeys);
    end
    if(response_flag==0) % Turn off noise mask and wait for a response till timeout
        Screen('FillRect', wptr, [0 0 0]); Screen('Flip', wptr);
        [response_flag, t2] = psy_wait(wptr, timeout-(stimdur+noisedur),responsekeys);
    end
    if(response_flag~=0), RT = t2-tstim; end;
    
    % Check if the response was a correct one and update the experiment structure
    responsecorrect = response_flag == find(ulabel == catlabels(img_id));
    
    if responsecorrect == 1, xx = find(trialbag==img_id); trialbag(xx(1)) = []; end
    
    if(response_flag==-1),psy_announce_block('Experiment Paused',wptr);end;
    if(response_flag==-2), break; end
    
    % compile all data
    expt_str.data.imgid(trial_id,1)            = img_id;
    expt_str.data.catlabel(trial_id,1)         = catlabels(img_id);
    expt_str.data.imggroup(trial_id,1)         = find(ulabel==catlabels(img_id));
    expt_str.data.stimdur(trial_id,1)          = tnoise-tstim; % actual duration of stimulus (check against task.stim_dur)
    expt_str.data.response(trial_id,1)         = response_flag;
    expt_str.data.responsecorrect(trial_id,1)  = responsecorrect;
    expt_str.data.RT(trial_id,1)               = RT;
    
    fprintf('%d trials remaining \n',length(trialbag));
    trial_id=trial_id+1;
end
expt_str.endtime = datestr(clock);
expt_str.duration = etime(datevec(expt_str.endtime),datevec(expt_str.starttime));

% add all dependent codes to expt_str
if(flag_packdep==1), expt_str.depstr = packdeps(mfilename); end

end

function [expt_str]=set_everything(catnames,nreps,fixdur,stimdur,noisedur,timeout,responsekeys)
% expt_str.exptname  = sprintf(' %s, %s, %s Categorisation',catnames{1},catnames{2},catnames{3});
expt_str.data = [];
expt_str.task = [];
[~,pcname] = system('ECHO %COMPUTERNAME%'); 
expt_str.where     = pcname(1:end-1); 
expt_str.starttime = datestr(clock);
expt_str.endtime   = [];
expt_str.duration  = [];
n=0;
n=n+1; expt_str.fields{n,1} = 'data           = block data';
n=n+1; expt_str.fields{n,1} = 'task           = block-related parameters';
n=n+1; expt_str.fields{n,1} = 'where          = name of pc on which expt was run';
n=n+1; expt_str.fields{n,1} = 'start          = time of block start';
n=n+1; expt_str.fields{n,1} = 'end            = time of block end';
n=n+1; expt_str.fields{n,1} = 'duration       = block duration, seconds';

expt_str.task.catnames = vec(catnames);
expt_str.task.nreps = nreps;
expt_str.task.fixdur = fixdur;
expt_str.task.stimdur = stimdur;
expt_str.task.noisedur = noisedur;
expt_str.task.timeout = timeout;
expt_str.task.responsekeys = [KbName(responsekeys{2}) KbName(responsekeys{1}) ...
    KbName('space') KbName('shift') KbName('control') KbName('2@')];

n=0;
n=n+1; expt_str.task.fields{n,1} = 'catnames     = Name of each category';
n=n+1; expt_str.task.fields{n,1} = 'nreps        = Number of repetitions per image';
n=n+1; expt_str.task.fields{n,1} = 'fixdur       = Duration of fixation cross, s';
n=n+1; expt_str.task.fields{n,1} = 'stimdur      = Duration of each image, s';
n=n+1; expt_str.task.fields{n,1} = 'noisedur     = Duration of the noise mask, s';
n=n+1; expt_str.task.fields{n,1} = 'timeout      = Time out, s';
n=n+1; expt_str.task.fields{n,1} = 'responsekeys = Response Keys';

expt_str.data = struct('imgid',[],'catlabel',[],'imggroup',[],'RT',[],'response',[],'responsecorrect',[],'fields',[]);

n=0;
n=n+1; expt_str.data.fields{n,1} = 'imgid            = ntrials x 1 vector of stim ids in each trial';
n=n+1; expt_str.data.fields{n,1} = 'catlabel         = category label for each stimulus';
n=n+1; expt_str.data.fields{n,1} = 'imggroup         = unique group to which stimulus belongs (unique(catlabels))';
n=n+1; expt_str.data.fields{n,1} = 'stimdur          = ntrials x 1 vector of stim durations in each trial, s';
n=n+1; expt_str.data.fields{n,1} = 'response         = subject''s response';
n=n+1; expt_str.data.fields{n,1} = 'responsecorrect  = 1/0: correct/incorrect (match between imggroup and response)';
n=n+1; expt_str.data.fields{n,1} = 'RT               = reaction time';

end


