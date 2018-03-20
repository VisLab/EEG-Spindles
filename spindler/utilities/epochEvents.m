function [eventCounts, eventLists] = epochEvents(events, totalTime, epochTime)
%% Produce epoched event lists and counts 
%
%  Parameters:
%      events       n x 2 array of event start and end times in seconds
%      totalTime    total time in sec
%      epochTime    time of an epoch in seconds
%      eventCounts  (output)vector with the counts of events in epoch
%      eventList    (output) cell array of event lists for epochs
%
%  Notes:
%    An event that spans epochs is only counted in the starting epoch
%    If epochFrames doesn't evenly divide totalFrames, the last partial epoch
%    discarded.
%
%   Written by: Kay A. Robbins, UTSA, 2017

numEpochs = floor(totalTime/epochTime);
eventCounts = zeros(numEpochs, 1);
eventLists = cell(numEpochs, 1);
if isempty(events)
    return;
end
for k = 1:numEpochs
   eMask =  epochTime*(k - 1) < events(:, 1) & events(:, 1) <= epochTime*k;
   eventLists{k} = events(eMask, :);
   if isempty(eventLists{k})
       continue;
   end
   eventLists{k} = eventLists{k} - epochTime*(k-1);
   eventCounts(k) = size(eventLists{k}, 1);
end
     
              