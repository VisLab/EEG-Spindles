function allMetrics = ...
        getPerformanceMetrics(trueEvents, labeledEvents, totalTimes, params)

%  Written by:  John La Rocco and Kay Robbins, UTSA, 2016-2018
params = processParameters('getPerformanceMetrics', ...
                       nargin, 3, params, getGeneralDefaults());
allMetrics = struct('count', NaN, 'hit', NaN, 'onset', NaN, ...
                    'intersect', NaN, 'time', NaN);

%% Compute the different types of metrics given the
[countConfusion, hitConfusion, intersectConfusion, ...
    onsetConfusion, timeConfusion] = ...
    getConfusions(trueEvents, labeledEvents, totalTimes, params);
         
allMetrics.count = getConfusionMetrics(countConfusion);
allMetrics.hit = getConfusionMetrics(hitConfusion);
allMetrics.onset = getConfusionMetrics(onsetConfusion);
allMetrics.intersect = getConfusionMetrics(intersectConfusion);
allMetrics.time = getConfusionMetrics(timeConfusion);
