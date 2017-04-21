function [spindleCounts, spindleTime] = getSpindleCountsOld(events)

spindleCounts = length(events);
if spindleCounts == 0
    spindleTime = 0.0;
    return;
end
startSpindles = cellfun(@double, events(:, 2));
endSpindles = cellfun(@double, events(:, 3));
spindleTime = sum(endSpindles - startSpindles);