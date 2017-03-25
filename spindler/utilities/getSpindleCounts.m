function [count, totalTime, meanTime] = getSpindleCounts(events)
%% Calculate number of events, total time in event and mean event time
%
%  Parameters:
%     events     n x 2 array with event start and end times in columns
%     count     (output) number of events
%     totalTime (output) total time in seconds in the events
%     meanTime  (output) mean time in each event
%
%  Written by:  John La Rocco and Kay Robbins, 2016-17
%
count = length(events);
if count == 0
    totalTime = 0.0;
    meanTime = 0.0;
    return;
end

totalTime = sum(events(:, 2) - events(:, 1));
meanTime = totalTime/count;