function [channelNumber, channelLabel] = getChannelNumber(EEG, channelLabels)
%% Return first channel label corresponding number that matches EEG channelLabels
%
%  Parameters
%     EEG              EEGLAB EEG structure
%     channelLabels    cell array of channel labels
%     channelNumber    (output) first channel number with labels in channelLabels
%     channelLabel     (output) first label in channelLabels with a match
%                      in EEG.chanlocs.labels
%
%  Written by: Kay Robbins, UTSA 2017
%
%% Extract the labels
actualLabels = {EEG.chanlocs.labels};
for k = 1:length(channelLabels)
   channelLabel = channelLabels{k};
   channelNumber = find(strcmpi(actualLabels, channelLabel), 1, 'first');
    if ~isempty(channelNumber)
        return;
    end
end