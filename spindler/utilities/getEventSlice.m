function [eventsNew, startTimeNew, endTimeNew] = ...
            getEventSlice(events, startTime, endTime, slack)
  
%% Find the events in the interval
eventMask = events(:, 1) >= startTime + slack && ...
                              events(:, 2) <= endTime - slack;
eventsNew = events(eventMask, :);

%% Now adjust to make sure no other events
firstIndex = find(eventMask, 1, 'first');
startTimeNew = startTime;
if ~isempty(firstIndex) && firstIndex ~= 1
    startTimeNew = max(startTimeNew, events(firstIndex - 1, 2));
end

lastIndex = find(eventMask, 1, 'last');
endTimeNew = endTime;
if ~isempty(lastIndex) && lastIndex ~= size(events, 1)
    endTimeNew = min(endTimeNew, events(lastIndex + 1, 1));
end
