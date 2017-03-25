function channelNumbers = getChannelNumbers(EEG, channelLabels)
%% Return a vector of channel numbers given channel labels
%
%  Parameters
%     EEG              EEGLAB EEG structure
%     channelLabels    cell array of channel labels
%     channelNumbers   (output) row vector of channel numbers
%
%  Written by: Kay Robbins, UTSA 2017
%
%% Extract the labels
actualLabels = {EEG.chanlocs.labels};
channelNumbers = zeros(1, length(channelLabels));
cCount = 0;
for k = 1:length(channelLabels)
   thisValue = find(strcmpi(actualLabels, channelLabels{k}), 1, 'first');
    if ~isempty(thisValue)
        cCount = cCount + 1;
        channelNumbers(cCount) = thisValue;
    end
end
channelNumbers = channelNumbers(1:cCount);