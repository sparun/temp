% gets eye data between the specified times
%   - t_beg is the start time
%   - t_end is the end time
%   - eyedata will contain the eye data
function eyedata = get_eyedata_fragment(t_beg, t_end)
global eyex_freq eyex_ts eyex_frag_size eyex eyey n_eye_frags;
nsamples = floor((t_end - t_beg) * eyex_freq);
sample_offset = 0;
for frag = 1:n_eye_frags
    if t_beg <= eyex_ts(frag,2), break; end
    sample_offset = sample_offset + eyex_frag_size(frag);
end
start_sample = sample_offset + floor((t_beg - eyex_ts(frag)) * eyex_freq);
end_sample = start_sample + nsamples - 1;
eyedata = [eyex(start_sample:end_sample) eyey(start_sample:end_sample)];
end