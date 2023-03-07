% plx2L2lfp         : Reads the lfp data for all the sites that appear in 
%                     L2_str from the raw plx files and organizes it into
%                     an L2lfp structure.
%
% required inputs:
%    L2_str         : L2 spikes structure of the experiment
%    raw_plx_folder : folder where are the raw plx files are located
%                     note that the plx & pl2 versions should not be in the same folder
%                     default: current folder
%
% optional inputs:
%    lfp_window     : time window in seconds from stimulus onset
%                   : default: [0 .4]
%    filterspecs    : {b,a} cell array of filter specifications to filter lfp data using 'filter' function:
%                     y = filter(b,a,X), where 'X' is the raw signal and 'y' is the filtered signal
%                     'b' is the numerator coefficient vector and 'a' is the denominator coefficient vector
%                     default: lfp will not be filtered
%
% outputs:
%    L2lfp          : a structure will all the lfp information
%    a mat file named 'L2lfp_exptname.mat' containing L2lfp will be stored in the current folder.
%
% method:
%    plx2L2lfp reads the list of sites from the spikes L2_str and for each site it
%    extracts lfp associated with every recorded wideband channel and
%    organizes the stimulus evoked lfp as nsites x nchannels x nstim x ntrials
%
% usage:
%    1) to extract lfp in the default 0-400 ms window:
%          L2lfp = plx2L2lfp(L2_str, '.');
%    2) to extract lfp in the 0-800 ms window from plx files located on labshare:
%          L2lfp = plx2L2lfp(L2_str, 'Z:\experiments\neurophysiology\series1\data\04_dtx\raw', [0 .8]);
%    3) to use an iir notch filter for removing 50 Hz line noise from a signal
%       sampled at 1000 Hz (fs) with the Q factor for the filter set to 35:
%          fs = 1000; wo = 50/(fs/2); bw = wo/35; [filternumerator, filterdenominator] = iirnotch(wo,bw);
%          L2lfp = plx2L2lfp(L2_str, '.', [], {filternumerator, filterdenominator});
%
% change log:
%    24/05/2017 - zhivago - first version

function L2lfp = plx2L2lfp(L2_str, raw_plx_folder, lfp_window, filterspecs)

dbstop if error;

% setting defaults
if ~exist('raw_plx_folder') | isempty(raw_plx_folder), raw_plx_folder = '.'; end
if ~exist('lfp_window') | isempty(lfp_window), lfp_window = [0 .4]; end
filterflag = 1; if ~exist('filterspecs') | isempty(filterspecs), filterflag = 0; end
raw_plx_folder = [raw_plx_folder '\'];

% L2lfp structure initialization
specs_str = struct('lfp_window', [], 'filterspecs', [], 'fix_stats', 'refer to the L2_str for trial-wise fixation statistics'); n = 0;
n = n+1; specs_str.fields{n,1} = 'lfp_window = [1 x 2] time window used for trial-wise lfp extraction';
if filterflag == 1
    n = n+1; specs_str.fields{n,1} = 'filterspecs = filter specifications to be used in the ''filter function''';
else
    specs_str = rmfield(specs_str, 'filterspecs');
end
n = n+1; specs_str.fields{n,1} = 'fix_stats = refer to the L2_str for trial-wise fixation statistics';

L2lfp = struct('expt_name', [], 'site_id', [], 'evokedlfp', [], 'specs', specs_str, 'fields', []); n = 0;
n = n+1; L2lfp.fields{n,1} = 'expt_name = name of the experiment';
n = n+1; L2lfp.fields{n,1} = 'site_id = [nsites x 1] list of unique site ids for the experiment';
n = n+1; L2lfp.fields{n,1} = 'evokedlfp = [nsites x nchannels x nstim x ntrials] cell array of trial-wise lfp fragments';
n = n+1; L2lfp.fields{n,1} = 'specs = structure containing parameters and specifications';
exptname = L2_str.expt_name;

% for series 1 experiments the L2_str is not optimized to store specs only for the sites and not neurons.
% so for those experiments, extracting unique site id's and creating a flag which will be used later to retrieve the correct stimulus timing
siteorgflag = 1;
if isfield(L2_str.specs, 'site_id')
    sites = L2_str.specs.site_id;
else
    siteorgflag = 0;
    sites = unique(cellfun(@(x) x(1:6), L2_str.neuron_id, 'UniformOutput', false));
end
nsites = length(sites);

% information about available raw plx files
flist = dir([raw_plx_folder '\*' exptname '*.pl*']);
fnames = arrayfun(@(x) x.name, flist, 'UniformOutput', false);

% populating L2lfp
L2lfp.expt_name = exptname;
L2lfp.specs.lfp_window = lfp_window;
if filterflag == 1, L2lfp.specs.filterspecs = filterspecs; end

% processing each site from L2_str
for siteid = 1:nsites
    
    % locating the associated plx file
    fid = manystrmatch(sites{siteid}, fnames);
    fprintf('processing site %03d/%03d (%s): located %s\n', siteid, nsites, sites{siteid}, flist(fid).name);
    fullplxname = [raw_plx_folder flist(fid).name];
    L2lfp.site_id{siteid,1} = flist(fid).name(1:6);        
    
    % figuring out the recorded wideband channels.  these are the channels whose lfp's we are be interested in
    [~, ~, ~, ncontsamples] = plx_info(fullplxname, 1); % # of samples for all the continuous channels
    ncontsamples = ncontsamples'; q1 = find(ncontsamples);  % channels with recorded data, ie non-zero # of samples    
    [~, chnames] = plx_adchan_names(fullplxname); chnames = cellstr(chnames); % names of all continuous channels
    qwb = intersect(manystrmatch('WB', chnames), q1); % wideband channels with recorded data
        
    % for hugo, we seem to have recorded eye data on the wideband channels, not the slow direct channels
    % there is no way to automatically tell them apart from the neuronal data
    % so ignoring the 2 extra channels that show up and taking only the first one
    if strcmp(sites{siteid}(1:2), 'hu'), qwb = qwb(1); end
    
    % certain sites like ro150a & xa057a have data recorded on SPK channels rather than WB channels
    if isempty(qwb)
        qwb = intersect(manystrmatch('SPK', chnames), q1);
        if isempty(qwb), fprintf('   -- no wideband channels found\n'); continue; end
    end    
    
    % extracting only the channel numbers from the wideband channel names
    qlfp = cellfun(@str2double, cellfun(@(x) x(end-1:end), chnames(qwb), 'UniformOutput', false));
    
    % processing each channel
    for ch = 1:length(qlfp)
        
        % the actual lfp channel ID
        chid = qlfp(ch);
        
        % extracting lfp signal from the plx file
        fprintf('   LFP CH# %02d/%02d (FP%02d <-- %s)\n', ch, length(qlfp), chid, chnames{qwb(ch)});
        [samplingfreq, n, ts, fn, mV] = plx_ad_v(fullplxname, num2str(chid, 'FP%02d'));
        nlfpsamples = diff(lfp_window)*samplingfreq; % number of lfp samples to extract
                
        % putting the lfp fragments together if expt was paused in between and applying a filter, if one was passed
        qfragstart = round(ts.*1000);
        nsamples = qfragstart(end) + fn(end);
        chlfp = NaN(nsamples,1);        
        xx = cumsum(fn'); qf = [1 xx(1:end-1)+1; xx]';
        for frag = 1:length(ts)
            y = mV(qf(frag,1):qf(frag,2));
            if filterflag == 1
                chlfp(qfragstart(frag)+1:qfragstart(frag)+fn(frag)) = filter(filterspecs{1}, filterspecs{2}, y);
            else
                chlfp(qfragstart(frag)+1:qfragstart(frag)+fn(frag)) = y;
            end
        end
        
        % for series 1 experiments the L2_str is not optimized to store specs only for the sites and not neurons
        % hence picking up the first neuron on a given site to retrieve the stimulus timings
        uniquesiteid = siteid;
        if siteorgflag == 0
            uniquesiteid = manystrmatch(sites{siteid}, L2_str.neuron_id); uniquesiteid = uniquesiteid(1);
        end
        
        % extracting trial-wise lfp signal
        nstim = length(L2_str.specs.t_on_off{uniquesiteid});
        for stimid = 1:nstim % stimulus loop
            ntrials = length(L2_str.specs.t_on_off{uniquesiteid}{stimid});
            for tid = 1:ntrials % trial loop
                % retrieving stimulus on & off times from L2_str
                ton = L2_str.specs.t_on_off{uniquesiteid}{stimid}{tid}(1);
                toff = L2_str.specs.t_on_off{uniquesiteid}{stimid}{tid}(2);
                t = 0:1/samplingfreq:length(chlfp)/samplingfreq-1/samplingfreq; % timestamp for each lfp sample
                q = find(t >= ton + lfp_window(1)); q = q(1);
                L2lfp.evokedlfp{siteid,1}{ch,1}{stimid,1}(tid,:) = single(chlfp(q:q+nlfpsamples-1)); % using single precision to conserve disk space
            end
        end
    end    
end
save(['L2lfp_' exptname], 'L2lfp', '-v7.3')
end
