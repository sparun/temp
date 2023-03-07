% Add some documentation here

clear; clc; close all; dbstop if error;
cd(fileparts(which(mfilename)));
commandwindow;
exptname  = input('Enter experiment name : ', 's');
subjectid = input('Enter subject ID      : ', 's');
runid     = input('Enter event run ID    : ');
expt_str.exptname = exptname;
expt_str.subjectid = subjectid;
expt_str.runid = runid;
specs.expdatetime = datestr(now, 'yyyymmdd_HHMMSS');
subjfolder = ['data/' exptname '_' subjectid '/']; mkdir(subjfolder);

% task parameters
nstimperblk = 14;
stimontime = 0.8;
stimofftime = 0.2;
n1back = 2;
nreps = 3;
nfixheadtail = 4;
nfixwashout = 4;

% display specifications
Screen('Preference', 'SkipSyncTests', 1);
screenList = Screen('Screens');
scrnum = max(screenList);
screenbg = [0 0 0];
HideCursor; ListenChar(2);
wptr = Screen('OpenWindow', scrnum, screenbg); HideCursor; ListenChar(2);
displayspecs = Screen('Resolution', Screen('WindowScreenNumber', wptr));

% loading and selecting localizer images
DrawFormattedText(wptr, 'Loading images...', 'center', 500, [255 255 255]);
Screen('Flip', wptr);
blkimgmats = dir('blkimages_*.mat');
nblks = length(blkimgmats);
for bid = 1:nblks
    fname = blkimgmats(bid).name;
    fprintf('loading images from : %s\n', fname);
    load(fname);
    q_ = find(blkimgmats(bid).name == '_'); q_ = q_(1) + 1;
    qdot = find(blkimgmats(bid).name == '.') - 1;
    blknames{bid,1} = fname(q_:qdot);
    nimages(bid,1) = size(images,4);
    for sid = 1:nimages(bid)
        textureptr(bid,sid) = Screen('MakeTexture', wptr, images(:,:,:,sid));
    end
end

ncnds = 2*nfixheadtail+ nblks*(nstimperblk + n1back + nfixwashout)*nreps;
[stimorder, isrep, blkid] = fmri_genblkconditions(nimages, nstimperblk, n1back, nreps, nfixheadtail, nfixwashout);
assert(length(stimorder) == ncnds);

DrawFormattedText(wptr, 'Always fixate on the dot at the center', 'center', 350, [255 255 255]);
DrawFormattedText(wptr, 'Press a key whenever an image repeats', 'center', 450,[255 255 255]);
DrawFormattedText(wptr, 'Press any key to continue...', 'center', 500, [255 255 255]);
Screen('Flip', wptr);
RestrictKeysForKbCheck([KbName('c') KbName('d')]);
KbStrokeWait;
RestrictKeysForKbCheck([]);
[responsekey, keytime, tstimon, tstimoff, tstartrun, tendrun] = fmri_runrun(wptr, screenbg, textureptr, stimorder, blkid, stimontime, stimofftime);
Screen('CloseAll'); ShowCursor; ListenChar(0);

data.blknames = blknames;
data.blkid = blkid;
data.stimid = stimorder;
data.isrep = isrep;
data.tstimon = tstimon;
data.tstimoff = tstimoff;
data.responsekey = responsekey;
data.keytime = keytime;

n=0;
n=n+1; data.fields{n,1} = 'blknames     = names of the localizer blocks';
n=n+1; data.fields{n,1} = 'conditions   = condition matrix [blkid stimid isrep]';
n=n+1; data.fields{n,1} = 'blkid        = localizer block id';
n=n+1; data.fields{n,1} = 'stimid       = stimulus id';
n=n+1; data.fields{n,1} = 'isrep        = is this a repeated stimulus (n-back)?';
n=n+1; data.fields{n,1} = 'tstimon      = stimulus on time';
n=n+1; data.fields{n,1} = 'tstimoff     = stimulus off time';
n=n+1; data.fields{n,1} = 'responsekey  = ascii codes of keys pressed';
n=n+1; data.fields{n,1} = 'keytime      = keypress time';

expt_str.data = data;

% bundling all the codes used for this experiment
exptfiles = dir('*.m');
exptfiles = arrayfun(@(x) x.name, exptfiles, 'UniformOutput', false);
exptfiles{end+1,1} = which('psy_record_keys');
exptfiles{end+1,1} = which('packdeps');
exptfiles{end+1,1} = which('unpackdeps');
depstr = packdeps(exptfiles);

specs.nblks = nblks;
specs.nstimperblk = nstimperblk;
specs.nback = n1back;
specs.nreps = nreps;
specs.nfixheadtail = nfixheadtail;
specs.nfixwashout = nfixwashout;
specs.ncnds = ncnds;
specs.stimontime = stimontime;
specs.stimofftime = stimofftime;
specs.screenbg = screenbg;
specs.displayspecs = displayspecs;
specs.depstr = depstr;
specs.tstartrun = tstartrun;
specs.tendrun = tendrun;
specs.runtime = tendrun - tstartrun;

n=0;
n=n+1; specs.fields{n,1} = 'expdatetime  = study date and time';
n=n+1; specs.fields{n,1} = 'nblks        = number of localizer blocks other than fixation';
n=n+1; specs.fields{n,1} = 'nstimperblk  = number of unique stimuli per block';
n=n+1; specs.fields{n,1} = 'n1backs      = number of 1-backs in a block';
n=n+1; specs.fields{n,1} = 'nreps        = number of repetitions of a block';
n=n+1; specs.fields{n,1} = 'nfixheadtail = number of fixation conditions at the start and end of the run';
n=n+1; specs.fields{n,1} = 'nfixwashout  = number of fixation conditions between localizer blocks';
n=n+1; specs.fields{n,1} = 'ncnds        = total number of conditions in a run, including localizer blocks and fixation blocks';
n=n+1; specs.fields{n,1} = 'stimontime   = time for stimulus is ON, in seconds';
n=n+1; specs.fields{n,1} = 'stimofftime  = time for which stimulus is OFF, in seconds';
n=n+1; specs.fields{n,1} = 'screenbg     = RGB for screen background';
n=n+1; specs.fields{n,1} = 'displayspecs = screen height, width, pixelsize and refresh rate';
n=n+1; specs.fields{n,1} = 'depstr       = a structure that contains all the m files used for this experiment - use unpackdeps() on this structure to retrieve all m files';
n=n+1; specs.fields{n,1} = 'tstartrun    = run start time';
n=n+1; specs.fields{n,1} = 'tendrun      = run end time';
n=n+1; specs.fields{n,1} = 'runtime      = total run time';

expt_str.specs = specs;

n=0;
n=n+1; expt_str.fields{n,1} = 'exptname  = name of the exptname';
n=n+1; expt_str.fields{n,1} = 'subjectid = subject ID';
n=n+1; expt_str.fields{n,1} = 'runid     = localizer run number';
n=n+1; expt_str.fields{n,1} = 'data      = trial wise data';
n=n+1; expt_str.fields{n,1} = 'specs     = specifications';

timestampstr = datestr(now, 'yyyymmdd_HHMMSS');
save([subjfolder 'exptstr_blk_' num2str(runid, 'r%02d') '_' exptname '_' subjectid '_' timestampstr], 'expt_str');

for bid = 1:nblks
    qblkstart = find(diff(blkid == bid) == 1) + 1;
    qblkend = find(diff(blkid == bid) == -1);
    blkonsets{bid,1} = tstimon(qblkstart);
    blkdurations{bid,1} = tstimoff(qblkend) - tstimon(qblkstart);
end

names = blknames;
onsets = cellfun(@(x) x-expt_str.specs.tstartrun, blkonsets, 'UniformOutput', false);
durations = blkdurations;
names{end+1,1} = 'fixation';
blkid = expt_str.data.blkid;
[qblkstart, qblkend] = regexp(char(uint8(blkid == 0)'), char(ones(nfixwashout,1)'));
if nfixheadtail ~= nfixwashout
    [qstart, qend] = regexp(char(uint8(blkid == 0)'), char(ones(nfixwashout,1)'));
    qblkstart = [qblkstart qstart]; qblkend = [qblkend qend];
    [~, ix] = sort(qblkstart); qblkstart = qblkstart(ix); qblkend = qblkend(ix);
end
qblkstart([1,end]) = []; qblkend([1,end]) = [];
onsets{end+1,1} = expt_str.data.tstimon(qblkstart) - expt_str.specs.tstartrun;
durations{end+1,1} = expt_str.data.tstimoff(qblkend) - expt_str.data.tstimon(qblkstart);
save([subjfolder 'mcf_blk_' num2str(runid, '%r02d') '_' exptname '_' subjectid '_' timestampstr], 'names', 'onsets', 'durations');
