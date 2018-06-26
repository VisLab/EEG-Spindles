function [eventFraction, eventLength, eventRate] = ...
                               getEventProperties(events, totalTime)
%% Compute event properties given a list of events
%
%  Parameters:
%      events           n x 2 array of event start and end times in seconds
%      totalTime       total time covered by events in seconds
%      eventFraction   (output) fraction of time spent in an event
%      eventLength     (output) average event length in seconds
%      eventRate       (output) average event rate in events/min
%
%% Calculate the properties
if isempty(events) || totalTime <= 0
    eventFraction = 0;
    eventLength = 0;
    eventRate = 0;
    return;
end
numEvents = size(events, 1);
eventRate = 60*numEvents/totalTime;
eventLength = sum(events(:, 2) - events(:, 1));
eventFraction = eventLength/totalTime;
eventLength = eventLength/numEvents;