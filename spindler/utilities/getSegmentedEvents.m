function eventList = getSegmentedEvents(eventDirs, baseName, eventTypes, ...
                                       startTime, segmentTime, totalTime)
%% Reads in lists of events to be compared and plotted
%
%  Parameters:
%     eventDirs     cell array of event directories to be searched
%     baseName      baseName of the data set for the events
%     eventTypes    cell array with a label for each eventDir (e.g., 'expert1')
%     startTime     starting time in the dataset
%     segmentTime   length in seconds for the segments to create
%     totalTime     total time over which to segment the events
%
numDirs = length(eventDirs);
if numDirs == 0
    eventList = [];
    return;
end
eventList(numDirs) = struct('fileName', '', 'eventType', '', ...
    'startTime', startTime, 'totalTime', totalTime, ...
    'eventCounts', '', 'eventSegments', '');

for n = 1:numDirs
    eventList(n) = eventList(end);
    eventList(n).eventType = eventTypes{n};
    eventList(n).fileName = [eventDirs{n} filesep baseName '.mat'];
    theseEvents = readEvents(eventList(n).fileName);
    if isempty(theseEvents)
        continue;
    end
    [eventList(n).eventCounts, eventList(n).eventSegments] = ...
        segmentEvents(theseEvents, startTime, totalTime, segmentTime);
end