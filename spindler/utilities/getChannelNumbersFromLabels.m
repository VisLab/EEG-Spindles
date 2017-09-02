function channelNumbers = getChannelNumbersFromLabels(actualLabels, requestedLabels)
%% Return a vector of channel numbers given channel labels
%
%  Parameters
%     actualLabels     cell array of channels in order they appear in EEG
%     requestedLabels  cell array of channel labels you want
%     channelNumbers   (output) row vector of channel numbers
%
%  Written by: Kay Robbins, UTSA 2017
%
%% Extract the labels
channelNumbers = zeros(1, length(requestedLabels));
cCount = 0;
for k = 1:length(requestedLabels)
   thisValue = find(strcmpi(actualLabels, requestedLabels{k}), 1, 'first');
    if ~isempty(thisValue)
        cCount = cCount + 1;
        channelNumbers(cCount) = thisValue;
    end
end
channelNumbers = channelNumbers(1:cCount);