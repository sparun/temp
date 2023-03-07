%
% wm_processCalibrationTrials  -> this function learns a linear model from 
%                                 each calib trial & eye data source & returns those models 
%                                 inside L1_str.calibmodel
% Required Inputs
%       L1_str            : struct with necessary fields
%       calTimeWindow     : 1-by-2 array of time window for calibration, in seconds.
% Outputs
%       L1_str            : updated struct with calibration-model
% 
% Version History:
%    Date               Authors             Notes
%    31-Jan-2023        Arun                First Implementation.
%
% ========================================================================================

function L1_str = wm_processCalibrationTrials(L1_str, calTimeWindow)
if(~exist('calTimeWindow')), calTimeWindow = [0.2 0.4]; end

allcaltrials = manystrmatch('Cal',L1_str.trialProperties.taskType)';
validtrials = find(L1_str.responseCorrect==1 & ~[L1_str.trialEvents.PtdMismatchFlag]'); 
caltrials = intersect(allcaltrials,validtrials)'; 

for trialid = caltrials
    tcodes = L1_str.trialEvents(trialid).tEcubePtd; % using ptd-corrected event times
    trialcodenames = L1_str.trialEvents(trialid).eventcodenames;
    qcalon   = find(~cellfun(@isempty,strfind(trialcodenames,regexpPattern('calib\dOn'))));
    qcaloff  = find(~cellfun(@isempty,strfind(trialcodenames,regexpPattern('calib\dOff'))));
    stimpos  = L1_str.trialProperties.stimPos{trialid};
    eyedatastr = {'rawEyeData','MLeyeData'}; 
    for eyedataid = 1:length(eyedatastr)
        eyedata = eval(['L1_str.' eyedatastr{eyedataid} '{trialid}']); 
        if(strcmp(eyedatastr{eyedataid},'rawEyeData')), israw = 1; else israw = 0; end
        if(israw)
            teyedata = tcodes(1)+[0:size(eyedata,1)-1]/L1_str.specs.ecube.specs.samplingRate;
        else
            teyedata = tcodes(1)+[0:size(eyedata,1)-1]/L1_str.specs.mlConfig.AISampleRate;
        end

        % compile all data for learning calibration model 
        xdva = []; ydva = []; eyesignalmatrix = []; calidlabel = [];
        for calid = 1:length(qcalon)
            tcalon = tcodes(qcalon(calid)); % time of calibration on
            calids = find(teyedata>=tcalon+calTimeWindow(1) & teyedata<=tcalon+calTimeWindow(2));
            eyedataX = eyedata(calids,1); eyedataY = eyedata(calids,2);
            xdva = [xdva; stimpos(calid,1)*ones(length(calids),1)];
            ydva = [ydva; stimpos(calid,2)*ones(length(calids),1)];
            eyesignalmatrix = [eyesignalmatrix; [eyedata(calids,1:2) ones(length(calids),1)] ];
            calidlabel = [calidlabel; calid*ones(length(calids),1)];
        end

        % learn calibration model for each datatype and trial
        xdvamodel = regress(xdva,eyesignalmatrix);
        ydvamodel = regress(ydva,eyesignalmatrix);
        xdvapred = eyesignalmatrix*xdvamodel;
        ydvapred = eyesignalmatrix*ydvamodel;

        % store calib model
        L1_str.calibmodel.calTimeWindow = calTimeWindow; 
        L1_str.calibmodel.trialID(trialid,1) = trialid; 
        if(israw)
            L1_str.calibmodel.rawEyeXmodel{trialid,1} = xdvamodel; 
            L1_str.calibmodel.rawEyeYmodel{trialid,1} = ydvamodel; 
        else
            L1_str.calibmodel.MLEyeXmodel{trialid,1} = xdvamodel; 
            L1_str.calibmodel.MLEyeYmodel{trialid,1} = ydvamodel; 
        end

        n=0; 
        n=n+1; L1_str.calibmodel.fields{n,1} = 'apply each model as [signalX signalY 1]*model'; 
        n=n+1; L1_str.calibmodel.fields{n,1} = 'calib model is trained for each successful cal trial'; 
        n=n+1; L1_str.calibmodel.fields{n,1} = 'calTimeWindow   = [tbeg tend] in sec of eye signals collected after each calibOn'; 
        n=n+1; L1_str.calibmodel.fields{n,1} = 'trialID         = trialID on which calib model was trained'; 
        n=n+1; L1_str.calibmodel.fields{n,1} = 'rawEyeXmodel    = model to apply on rawEyeX to get Xdva'; 
        n=n+1; L1_str.calibmodel.fields{n,1} = 'rawEyeYmodel    = model to apply on rawEyeY to get Ydva'; 
        n=n+1; L1_str.calibmodel.fields{n,1} = 'MLEyeXmodel     = model to apply on MLEyeX to get Xdva'; 
        n=n+1; L1_str.calibmodel.fields{n,1} = 'MLEyeYmodel     = model to apply on MLEyeY to get Ydva'; 
        
        % store plotdata for each calib model 
        plotid = length(L1_str.specs.plotdata)+1; 
        namestr = sprintf('%s, Trial %d',eyedatastr{eyedataid},trialid);
        L1_str.specs.plotdata(plotid).name = namestr; 
        L1_str.specs.plotdata(plotid).xdata{1} = eyesignalmatrix(:,1);
        L1_str.specs.plotdata(plotid).ydata{1} = eyesignalmatrix(:,2);
        L1_str.specs.plotdata(plotid).markerspec{1} = 'k.';
        L1_str.specs.plotdata(plotid).markersize{1} = 6; 
        L1_str.specs.plotdata(plotid).xlabel = 'Raw signal, X'; 
        L1_str.specs.plotdata(plotid).ylabel = 'Raw signal, Y';
        L1_str.specs.plotdata(plotid).legendstr = 'off'; 

        plotid = length(L1_str.specs.plotdata)+1; 
        namestr = sprintf('Transformed eyedata from %s, Trial %d',eyedatastr{eyedataid},trialid);
        L1_str.specs.plotdata(plotid).name = namestr; 
        L1_str.specs.plotdata(plotid).xdata{1} = xdva;
        L1_str.specs.plotdata(plotid).ydata{1} = ydva;
        L1_str.specs.plotdata(plotid).markerspec{1} = 'r+';
        L1_str.specs.plotdata(plotid).markersize{1} = 10; 
        L1_str.specs.plotdata(plotid).xdata{2} = xdvapred;
        L1_str.specs.plotdata(plotid).ydata{2} = ydvapred;
        L1_str.specs.plotdata(plotid).markerspec{2} = 'k.';
        L1_str.specs.plotdata(plotid).markersize{2} = 6; 
        L1_str.specs.plotdata(plotid).xlabel = 'eye position X, dva'; 
        L1_str.specs.plotdata(plotid).ylabel = 'eye position Y, dva';
        L1_str.specs.plotdata(plotid).legendstr = {'Calib location','Transformed Eye Signal'};
    end
end

end
