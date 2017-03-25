function eventsNew = removeOverlapEvents(events, method)
%% Removes overlapping events.
%
%  Parameters:
%     events     n x 2 array of event start and end times in seconds
%     method     method of removal: 'union' (default) or 'longest'
%     eventsNew  m x 2 array of reduced event start and end times 
%
%  Written by:  Kay Robbins, 2017, UTSA
%
curEvent = 1;
origEvent = 0;
eventsNew = sortrows(events, [1, 2]);
while curEvent < length(eventsNew)
    removed = [];
    origEvent = origEvent + 1;
    eFirst = eventsNew(curEvent, :);
    eNext = eventsNew(curEvent + 1, :);
    if eFirst(2) < eNext(1);
        curEvent = curEvent + 1;
        continue;
    end
    switch method
        case 'union'
            eventsNew(curEvent, 2) = max(eFirst(2), eNext(2));
            removed = 1;
        case 'longest'
            firstLen = eFirst(2) - eFirst(1);
            nextLen = eNext(2) - eNext(1);
            if firstLen >= nextLen
                removed = 1;
            else
                removed = 0;
            end
    end
    if ~isempty(removed)
       eventsNew(curEvent + removed, :) = [];
       fprintf('Combining events %d [%g, %g] and %d [%g, %g] as [%g, %g] at %d\n', ...
          origEvent, events(origEvent, 1), events(origEvent, 2), ...
          origEvent + 1, events(origEvent + 1, 1), events(origEvent + 1, 2), ...
          eventsNew(curEvent, 1), eventsNew(curEvent, 2), curEvent);
    end
    
end
