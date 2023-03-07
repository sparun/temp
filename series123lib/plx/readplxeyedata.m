% read the analog eye data from the given plx file and stores the data in
% global variables
%   - plx_file contains the full path of the plx file
function readplxeyedata(plx_file, eyex_ch, eyey_ch)
global eyex_freq eyex_ts eyex_frag_size eyex eyey n_eye_frags;
iscanrate = 250;

[eyex_freq, n_eyex, eyex_ts, eyex_frag_size, eyex] = plx_ad(plx_file, eyex_ch);

downsamplefactor = eyex_freq/iscanrate;

eyex_frag_size = ceil(eyex_frag_size/downsamplefactor);
chosen_ones = 1:eyex_freq/250:length(eyex);
eyex = eyex(chosen_ones);
n_eyex = length(eyex);
eyex_freq = 250;

[eyey_freq, n_eyey, eyey_ts, eyey_frag_size, eyey] = plx_ad(plx_file, eyey_ch);

eyey_frag_size = ceil(eyey_frag_size/160);
chosen_ones = 1:eyey_freq/250:length(eyey);
eyey = eyey(chosen_ones);
n_eyey = length(eyey);
eyey_freq = 250;

for i = 1:length(eyex_frag_size)
    eyex_ts(i,2) = eyex_ts(i) + eyex_frag_size(i)/eyex_freq;
end
n_eye_frags = size(eyex_ts,1);
end