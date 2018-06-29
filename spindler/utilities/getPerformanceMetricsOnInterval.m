function [allMetrics, expertEvents, spindleEvents, totalTime] = ...
              getPerformanceMetricsOnInterval(expertEvents, ...
                               spindles, startTime, endTime, params)
                      
    if isempty(expertEvents)
        allMetrics = [];
        return;
    end
    totalTime = endTime - startTime;
    expertEvents = getEventInterval(expertEvents - startTime, 0, totalTime);
    [size1, size2] = size(spindles);
    allMetrics(size1, size2) = struct('count', NaN, 'hit', NaN, ...
                              'intersect', NaN, 'onset', NaN, 'time', NaN);
    spindleEvents = cell(size1, size2);
    for k = 1:size1
        for j = 1:size2
            theseSpindles = ...
                getEventInterval(spindles(k, j).events - startTime, 0, totalTime);
            allMetrics(k, j) = getPerformanceMetrics(expertEvents, ...
                theseSpindles, totalTime, params);
            spindleEvents{k, j} = theseSpindles;
        end
    end
end

function newEvents = getEventInterval(events, startTime, endTime)
    if isempty(events)
        newEvents = [];
        return;
    end
    eventMask = events(:, 1) >= startTime & events(:, 1) <= endTime;
    newEvents = events(eventMask, :);
    newEvents(newEvents > endTime) = endTime;
end