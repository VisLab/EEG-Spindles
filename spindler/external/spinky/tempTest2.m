    epochTime = 30;
     params.thresholds = thresholds;
    numThresholds = length(thresholds);
    spindles(numThresholds) = struct('threshold', 0, ...
                   'numberSpindles', 0, 'spindleTime', 0, 'events', NaN);
    for k = 1:numThresholds
        spindles(k) = spindles(end);
        spindles(k).threshold = spinkySpindles(k).threshold;
        events = epochedToList(spinkySpindles(k).spindleList, epochTime);
        events = combineEvents(events, params.spindleLengthMin, ...
                               params.spindleSeparationMin);
        spindles(k).events = events;
        if ~isempty(events)
            spindles(k).numberSpindles = size(events, 1);
            spindles(k).spindleTime = sum(events(:, 2) - events(:, 1));
        end
    end