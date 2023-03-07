%
% wm_BasicSpikeSortThreshold -> This function performs spike sorting on each channel separtely based on a predefined threshold.
%
%  Required Inputs
%       rawData           : nchannels x nsamples wideband data
%       channelThreshold  : single number or channel-wise threshold to use for rudimentary spike sorting 
%       samplingRate      : sampling frequency of neural data
% Outputs 
%       neuralData        : structure with same format as wm_readNexFile
%
% Version History:
%    Date               Authors             Notes
%    17-Dec-2022        SP Arun             First version
%    29-Dec-2022        Shubho              Updated with findpeaks functionality
%    06-Jan-2022        Shubho              corrected neuralData.waves{chid}.waveforms = zeros(1,32); 
%
% ========================================================================================

function neuralData = wm_BasicSpikeSortThreshold(rawData,channelwiseThreshold,samplingRate)

nchannels = size(rawData,1); nSamples  = size(rawData,2);
if(length(channelwiseThreshold)==1), channelwiseThreshold = channelwiseThreshold*ones(nchannels,1); end
tneural = [0:nSamples-1]/samplingRate; 

for chid = 1:nchannels
    [~,spikeids] = findpeaks(rawData(chid,:),'MinPeakHeight',channelwiseThreshold(chid));
    % collect spiketimes
    tspikes = tneural(spikeids); 
    % collect necessary data
    neuralData.neurons{chid}.name = sprintf('Channel%03d',chid); 
    neuralData.neurons{chid}.wireNumber = chid-1; 
    neuralData.neurons{chid}.unitNumber = 0; 
    neuralData.neurons{chid}.timestamps = tspikes; 
    neuralData.waves{chid}.waveforms = zeros(32,1); 
end

end