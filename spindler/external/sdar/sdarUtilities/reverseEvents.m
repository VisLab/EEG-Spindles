function reversedEvents = reverseEvents(events, finalTime)

eventStarts = cellfun(@double, events(:, 2));
eventEnds = cellfun(@double, events(:, 3));
reversedStarts = [0; eventEnds];
reversedEnds = [eventStarts; finalTime];
mask = reversedStarts == reversedEnds;
reversedStarts(mask) = [];
reversedEnds(mask) = [];
reversedEvents = cell(length(reversedStarts), 3);
for k = 1:length(reversedStarts)
    reversedEvents{k, 1} = 'Reversed';
    reversedEvents{k, 2} = reversedStarts(k);
    reversedEvents{k, 3} = reversedEnds(k);
end
