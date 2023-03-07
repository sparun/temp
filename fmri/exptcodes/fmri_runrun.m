function [responsekey, keytime, tstimon, tstimoff, tstartrun, tendrun] = fmri_runrun(wptr, screenbg, textureptr, stimorder, blkorevtid, stimontime, stimofftime)
Screen('TextSize', wptr, 30);
displayspecs = Screen('Resolution', Screen('WindowScreenNumber', wptr));
cx = round(displayspecs.width/2); cy = round(displayspecs.height/2);
flipinterval = Screen('GetFlipInterval', wptr);

w = 3; % circle radius
Screen('FillRect', wptr, screenbg);
Screen('FillOval', wptr, [255 0 0], [cx-w, cy-w, cx+w, cy+w], 100);
Screen('Flip', wptr);

fprintf('waiting for 1st scanner pulse...\n');
RestrictKeysForKbCheck([KbName('s')]);
KbStrokeWait;
RestrictKeysForKbCheck([]);
tstartrun = GetSecs();
fprintf('received 1st scanner pulse...\n');

responsekey = []; keytime = [];
tperstim = (stimontime + stimofftime);
qTon = 0:tperstim:(length(stimorder)-1)*tperstim; tstimon(1) = 0;
for cid = 1:length(stimorder)
    % stim on
    if stimorder(cid) ~= 0
        Screen('DrawTexture',wptr,textureptr(blkorevtid(cid),stimorder(cid)));
    end
    Screen('FillOval', wptr, [255 0 0], [cx-w, cy-w, cx+w, cy+w], 100);
    [~, tstimon(cid,1)] = Screen('Flip', wptr,qTon(cid) + tstimon(1));    
    time = tstimon(cid,1) + stimontime;

    % waiting for response while stim on
    [rkey, rtime] = psy_record_keys(stimontime-(flipinterval/2));
    responsekey{cid,1} = rkey; keytime{cid,1} = rtime;
    if any(rkey == KbName('e')), break; end %81), break; end

    % stim off
    Screen('FillRect', wptr, screenbg);
    Screen('FillOval', wptr, [255 0 0], [cx-w, cy-w, cx+w, cy+w], 100);
    [~, tstimoff(cid,1)] = Screen('Flip', wptr,time);

    % waiting for response while stim off
    [rkey, rtime] = psy_record_keys(stimofftime-(flipinterval/2));
    responsekey{cid} = [responsekey{cid}; rkey]; keytime{cid} = [keytime{cid}; rtime];
    if any(rkey == KbName('e')), break; end
    if blkorevtid ~= 0, Screen('Close', textureptr(blkorevtid(cid),stimorder(cid))); end
end

tendrun = GetSecs();