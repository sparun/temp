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
stimontime = 0.5;
stimofftime = 3.5;
nfixheadtail = 2;
nfixevts = 16;

% display specifications
Screen('Preference', 'SkipSyncTests', 1);
screenList = Screen('Screens');
scrnum = max(screenList);
screenbg = [0 0 0];
HideCursor; ListenChar(2);
wptr = Screen('OpenWindow', scrnum, screenbg); HideCursor; ListenChar(2);
displayspecs = Screen('Resolution', Screen('WindowScreenNumber', wptr));

% loading and selecting images
DrawFormattedText(wptr, 'Loading images...', 'center', 500, [255 255 255]);
Screen('Flip', wptr);
load('evtimages.mat');
nimages = length(images);
for eid = 1:nimages
    textureptr(1,eid) = Screen('MakeTexture', wptr, images{eid});
end

ncnds = 2*nfixheadtail + nfixevts + nimages+8;
[stimorder, isrep, evtid] = fmri_genevtconditions(runid, nfixheadtail, nfixevts,nimages);
assert(length(stimorder) == ncnds);

DrawFormattedText(wptr, 'Always fixate on the dot at the center', 'center', 350, [255 255 255]);
DrawFormattedText(wptr, 'Press a key whenever an image repeats', 'center', 450,[255 255 255]);
DrawFormattedText(wptr, 'Press any key to continue...', 'center', 500, [255 255 255]);
Screen('Flip', wptr);
RestrictKeysForKbCheck([KbName('c') KbName('d')]);
KbStrokeWait;
RestrictKeysForKbCheck([]);
[responsekey, keytime, tstimon, tstimoff, tstartrun, tendrun] = fmri_runrun(wptr, screenbg, textureptr, stimorder, evtid, stimontime, stimofftime);
Screen('CloseAll'); ShowCursor; ListenChar(0);

data.stimid = stimorder;
data.isrep = isrep;
data.tstimon = tstimon;
data.tstimoff = tstimoff;
data.responsekey = responsekey;
data.keytime = keytime;

n=0;
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

specs.nfixheadtail = nfixheadtail;
specs.nfixevts = nfixevts;
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
n=n+1; specs.fields{n,1} = 'nfixheadtail = number of fixation conditions at the start and end of the run';
n=n+1; specs.fields{n,1} = 'nfixevts     = number of fixation events';
n=n+1; specs.fields{n,1} = 'ncnds        = total number of conditions in a run, including events and fixations';
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
n=n+1; expt_str.fields{n,1} = 'runid     = event run number';
n=n+1; expt_str.fields{n,1} = 'data      = trial wise data';
n=n+1; expt_str.fields{n,1} = 'specs     = specifications';

timestampstr = datestr(now, 'yyyymmdd_HHMMSS');
save([subjfolder 'exptstr_evt_' num2str(runid, 'r%02d') '_' exptname '_' subjectid '_' timestampstr], 'expt_str');

for eid = 1:length(names)
    xx = expt_str.data.tstimon(find(expt_str.data.stimid == eid));
    onsets{eid,1} = xx(1) - expt_str.specs.tstartrun;
    durations{eid,1} = 0;
end
names{end+1,1} = 'fixation';
xx = expt_str.data.tstimon(find(expt_str.data.stimid == 0)); xx(1:nfixheadtail) = []; xx(end-nfixheadtail+1:end) = [];
onsets{end+1,1} = xx - expt_str.specs.tstartrun;
durations{end+1,1} = zeros(length(onsets{end}),1);
save([subjfolder 'mcf_evt_' num2str(runid, 'r%02d') '_' exptname '_' subjectid '_' timestampstr], 'names', 'onsets', 'durations');
