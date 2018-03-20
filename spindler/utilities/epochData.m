function epochedData = epochData(data, epochFrames)
%% Epoch data into numFrames epochs, throwing away extra frames
%
%  Parameters:
%      data       (input) one dimensional array containing the data
%      epochFrames  number of frames in the epochs
%      data       (output)  n x numFrames epoched data
%
%  Written by:  Kay A. Robbins, UTSA, 2017

%% Compute the epochs
if isempty(data)
    epochedData = [];
    return;
end
numEpochs = floor(length(data)/epochFrames);
epochedData = data(1:epochFrames*numEpochs);
epochedData = reshape(epochedData, epochFrames, numEpochs)';