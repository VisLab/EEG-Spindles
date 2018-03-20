function eventsNew = mergeExpertRatings(events, method)
%% Removes overlapping events in concatentated lists of events
%
%  Parameters:
%     events     n x 2 array of event start and end times in seconds
%     method     method of removal: 'union' (default) or 'longest'
%     eventsNew  m x 2 array of reduced event start and end times
%
%  Usually this function is used to clean up duplicates in concatentated
%  lists of expert ratings.
%  
%  Methods:
%     'Union'    when two events overlap, take the union
%     'Longest'  when two events overlap, take the longest
%
%  Written by:  Kay Robbins, 2017, UTSA
% 
curEvent = 1;
[sortedStarts, sortedIndices] = sort(events(:, 1), 'ascend');
eventsNew = [sortedStarts, events(sortedIndices, 2)];
while curEvent < length(eventsNew)
    if eventsNew(curEvent, 2)  < eventsNew(curEvent + 1, 1)
        curEvent = curEvent + 1;
        continue;
    end
 
    fprintf('Combining events %d at %g(%g) and %d at %g(%g)', ...
        curEvent, eventsNew(curEvent, 1), eventsNew(curEvent, 2), ...
        curEvent + 1, eventsNew(curEvent + 1, 1), eventsNew(curEvent + 1, 2));
    switch method
        case 'union'
            maxEnd = max(eventsNew(curEvent, 2), eventsNew(curEvent + 1, 2));
            eventsNew(curEvent, 2) = maxEnd;
            eventsNew(curEvent + 1, :) = [];
        case 'longest'
            if eventsNew(curEvent, 2) - eventsNew(curEvent, 1) >= ...
               eventsNew(curEvent + 1, 2) - eventsNew(curEvent + 1, 1)
               eventsNew(curEvent + 1, :) = [];
            else
               eventsNew(curEvent, :) = [];
            end
    end
    fprintf('as %g(%g)\n', eventsNew(curEvent, 1), eventsNew(curEvent, 2));
end

