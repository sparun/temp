% generic template for psy_expt_* functions

% SP Arun
% 15 Sep 2017

allclear;
subj_name = input('Enter subject name: ','s');

try
    expt_str.experiment = 'test';
    expt_str.subj_name = subj_name;
    load psylib\testimages;
    scrnum = 0; wptr = Screen(scrnum, 'OpenWindow'); % screen parameters
        
    if(0) % ------------ CODE FOR BASELINE BLOCK ----------------
        expt_str.baseline = psy_run_baseline(wptr,2,keyspecs);
    end

    if(1) % ------------ CODE FOR PSY_EXPT_CATEGORIZATION ----------
        catnames={'animal','bird','natural','manmade'}; catlabels=[1,1,2,2,3,3,4,4]; nreps=2;
        responsekeys = {'a','b','n','m'}; 
        stimdur=1; noisedur=3; timeout=5;
        expt_str= psy_expt_categorization(testimages,catlabels,catnames,nreps,responsekeys,stimdur,noisedur,timeout,wptr)
    end
    
    if(0) % ------------ CODE TO RUN SEARCH BLOCK ----------------
        imgpairs = nchoosek([1:length(testimages)],2);
        block_name = 'testexpt';
        keyspecs = {'z','m'}; timespecs = [0.5 20]; rand_flag = 1;
        nrepsperdir = 2; % number of trials for each image pair
        setsize = [4 4]; % set size of search array
        boxscale = [1.5 1.5]; % set scale of box relative to largest image
        posjitter = [0.1 0.1]; % set position jitter of elements in the array
        expt_str = psy_expt_search(testimages,imgpairs,1,setsize,nrepsperdir,posjitter,boxscale,[],[],keyspecs,timespecs,block_name,wptr,rand_flag);
    end
    
    % ---------------- WRAP UP CODE -------------------------
    % close screen
    ShowCursor; ListenChar(0); Screen('CloseAll');
    
    % enable to save data to file
    %fprintf('*** storing all relevant .m programs into expt_str \n');
    %expt_str.depstr = packdeps(mfilename);
    %out_file = [subj_name,date];
    %save(out_file,'expt_str');
    
catch err % In case of error above, close windows and display error
    ShowCursor; ListenChar(0);
    Screen('CloseAll');
    rethrow(err);
end
