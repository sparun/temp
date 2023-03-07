
for sid = 1:length(subjects)
    xx = strsplit(subjects(sid).name, '_');
    subjectid = [xx{2} '_' xx{3}];
    subjectfolder = [exptfolder subjects(sid).name '/'];
    
    f = dir([subjectfolder 'mcf/mcf*blk_*.mat']);
    if isempty(f), continue; end
    load([exptfolder subjects(sid).name '/mcf/' f(1).name]);
    nevents = length(names); durations = cell(nevents,1); onsets = cell(nevents,1);
    for fid = 1:length(f)
        if fid == 1
            prevmat = f(fid).name;
        else
            prevmat = f(fid-1).name;
        end
        xx = strsplit(prevmat, {'_','.'});
        nii = dir([subjectfolder 'nii/s0*' xx{2} '_' xx{3} '*.nii']);
        if isempty(nii), error('matching nii not found'); end
        xx = strsplit(nii.name, '_'); nvols = sscanf(xx{2}, '%03dv'); TR = sscanf(xx{4}, 'tr%f');
        xx = load([exptfolder subjects(sid).name '/mcf/' f(fid).name]);
        for eid = 1:length(xx.names)
            durations{eid,1} = [durations{eid,1}; xx.durations{eid}];
            onsets{eid,1} = [onsets{eid,1}; xx.onsets{eid} + (fid-1) * nvols * TR];
        end
    end
    names = xx.names;
    save([exptfolder subjects(sid).name '/mcf/mergedmcf_blk'], 'durations', 'onsets', 'names');
    
    f = dir([subjectfolder 'mcf/mcf*evt_*.mat']);
    if isempty(f), continue; end
    load([exptfolder subjects(sid).name '/mcf/' f(1).name]);
    nevents = length(names); durations = cell(nevents,1); onsets = cell(nevents,1);
    for fid = 1:length(f)
        if fid == 1
            prevmat = f(fid).name;
        else
            prevmat = f(fid-1).name;
        end
        xx = strsplit(prevmat, {'_','.'});
        nii = dir([subjectfolder 'nii/s0*' xx{2} '_' xx{3} '*.nii']);
        if isempty(nii), error('matching nii not found'); end
        xx = strsplit(nii.name, '_'); nvols = sscanf(xx{2}, '%03dv'); TR = sscanf(xx{4}, 'tr%f');
        xx = load([exptfolder subjects(sid).name '/mcf/' f(fid).name]);
        for eid = 1:length(xx.names)
            durations{eid,1} = [durations{eid,1}; xx.durations{eid}];
            onsets{eid,1} = [onsets{eid,1}; xx.onsets{eid} + (fid-1) * nvols * TR];
        end
    end
    names = xx.names;
    save([exptfolder subjects(sid).name '/mcf/mergedmcf_evt'], 'durations', 'onsets', 'names');
    
    for eo = 1:2  % even-odd
        cnt = 1;     nevents = length(names); durations = cell(nevents,1); onsets = cell(nevents,1);
        for fid = eo:2:length(f)
            if cnt == 1
                prevmat = f(fid).name;
            else
                prevmat = f(fid-2).name;  % changed from 1 to 2 because of step size
            end
            xx = strsplit(prevmat, '_');
            nii = dir([subjectfolder 'nii/s0*' xx{2} '_' xx{3} '*.nii']);
            if isempty(nii), error('matching nii not found'); end
            xx = strsplit(nii.name, '_'); nvols = sscanf(xx{2}, '%03dv'); TR = sscanf(xx{4}, 'tr%f');
            xx = load([exptfolder subjects(sid).name '/mcf/' f(fid).name]);
            for eid = 1:length(xx.names)
                durations{eid,1} = [durations{eid,1}; xx.durations{eid}];
                onsets{eid,1} = [onsets{eid,1}; xx.onsets{eid} + (cnt-1) * nvols * TR];
            end
            cnt  = cnt+1;
        end
        names = xx.names;
        if eo == 1
            save([exptfolder subjects(sid).name '/mcf/mergedmcf_evt_odd'], 'durations', 'onsets', 'names');
        else
            save([exptfolder subjects(sid).name '/mcf/mergedmcf_evt_even'], 'durations', 'onsets', 'names');
        end
    end
    
end
