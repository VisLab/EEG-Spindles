function [eventCounts, eventLists] = segmentEvents(events, startTime, totalTime, segmentTime)
%% Produce segmented event lists and counts 
%
%  Parameters:
%      events       n x 2 array of event start and end times in seconds
%      totalTime    total time in sec
%      segmentTime  time of a segment in seconds
%      eventCounts  (output)vector with the counts of events in epoch
%      eventList    (output) cell array of event lists for epochs
%
%  Notes:
%    An event that spans segments is only counted in the starting epoch
%    If epochFrames doesn't evenly divide totalFrames, the last partial epoch
%    discarded.
%
%   Written by: Kay A. Robbins, UTSA, 2017

numSegments = floor(totalTime/segmentTime);
eventCounts = zeros(numSegments, 1);
eventLists = cell(numSegments, 1);
if isempty(events)
    return;
end
for k = 1:numSegments
   eMask =  segmentTime*(k - 1) + startTime < events(:, 1) & ...
                 events(:, 1) <= segmentTime*k + startTime;
   eventLists{k} = events(eMask, :);
   if isempty(eventLists{k})
       continue;
   end
   eventLists{k} = eventLists{k} - segmentTime*(k-1) - startTime;
   eventCounts(k) = size(eventLists{k}, 1);
end        