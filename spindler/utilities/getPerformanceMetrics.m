function metrics = ...
        getPerformanceMetrics(trueEvents, labeledEvents,  totalTimes, params)

%  Written by:  John La Rocco and Kay Robbins, UTSA, 2016-2018
params = processParameters('getPerformanceMetrics', ...
                       nargin, 4, params, getGeneralDefaults());
metrics = struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                 'onset', NaN, 'time', NaN);

%% Compute the different types of metrics given the
[countConfusion, hitConfusion, intersectConfusion, ...
    onsetConfusion, timeConfusion] = ...
    getConfusions(trueEvents, labeledEvents, totalTimes, params);
         
metrics.count = getConfusionMetrics(countConfusion);
metrics.hit = getConfusionMetrics(hitConfusion);
metrics.onset = getConfusionMetrics(onsetConfusion);
metrics.intersect = getConfusionMetrics(intersectConfusion);
metrics.time = getConfusionMetrics(timeConfusion);
