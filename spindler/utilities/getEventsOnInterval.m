function newEvents = getEventsOnInterval(events, startTime, endTime)
    if isempty(events)
        newEvents = [];
        return;
    end
    eventMask = events(:, 1) >= startTime & events(:, 1) <= endTime;
    newEvents = events(eventMask, :);
    newEvents(newEvents > endTime) = endTime;
end