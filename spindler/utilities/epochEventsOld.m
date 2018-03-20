function [eventCounts, eventMasks, eventLists] = ...
                   epochEvents(events, srate, totalFrames, epochFrames)
%% Produce epoched events in various formats
%
%  Parameters:
%      events       n x 2 array of event start and end times in seconds
%      srate        sampling rate
%      totalFrames  total frames in the dataset
%      epochFrames  number of frames in an epoch
%      eventCounts  (output)vector with the counts of events in epoch
%      eventMasks   (output)mask of events in the epoch
%      eventList    (output) cell array of event lists for epochs
%
%  Notes:
%    An event that spans epochs is only counted in the starting epoch
%    If epochFrames doesn't evenly divide totalFrames, the last partial epoch
%    discarded.
%
%   Written by: Kay A. Robbins, UTSA, 2017

numEpochs = floor(totalFrames/epochFrames);
eventCounts = zeros(numEpochs, 1);
eventMasks = false(numEpochs*epochFrames, 1);
eventLists = cell(numEpochs, 1);
eventFrames = round(events*srate) + 1;
eventFrames(eventFrames > totalFrames) = totalFrames;
for k = 1:numEpochs
   eMask =  epochFrames*(k - 1) < eventFrames(:, 1) & ...
            eventFrames(:, 1) <= epochFrames*k;
   eventLists{k} = events(eMask, :);
   if isempty(eventLists{k})
       continue;
   end
   eventLists{k} = eventLists{k} - epochFrames*(k-1)/srate;
   theseStarts = eventFrames(eMask, 1);
   theseEnds = eventFrames(eMask, 2);
   eventCounts(k) = size(eventLists{k}, 1);
   for j = 1:eventCounts(k)
       eventMasks(theseStarts(j):min(theseEnds(j), epochFrames*k)) = true;
   end
end
eventMasks = reshape(eventMasks, epochFrames, numEpochs)';
     
              