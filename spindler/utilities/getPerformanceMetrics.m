function metrics = getPerformanceMetrics(trueEvents, labeledEvents, ...
         srate, totalTimes, params)
%% Calculate confusion matrix performance metrics for five matching methods
%
%  Parameters:
%      trueEvents    n x 2 array of start and end times of ground truth or
%                    cell array of n_i x 2 arrays of ground truth on
%                    segments
%      labeledEvents m x 2 array of start and end times of predictions or
%                    cell array of m_i x 2 arrays of predictions on
%                    segments
%      srate         sampling rate in Hz
%      totalTimes    array of total times covered by segments
%      metrics       structure with metrics computed using five matching
%                    methods: count, hit, intersect, onset, and time
%
%  Written by:  John La Rocco and Kay Robbins, UTSA, 2016-2018

%% Set up the parameters and the structures
params = processParameters('getPerformanceMetrics', ...
                       nargin, 5, params, getGeneralDefaults());
metrics = struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                 'onset', NaN, 'time', NaN);

%% Compute the different types of metrics given the
countConfusion = struct('tp', 0, 'tn', 0, 'fp', 0, 'fn', 0);
hitConfusion = struct('tp', 0, 'tn', 0, 'fp', 0, 'fn', 0);
intersectConfusion = struct('tp', 0, 'tn', 0, 'fp', 0, 'fn', 0);
onsetConfusion = struct('tp', 0, 'tn', 0, 'fp', 0, 'fn', 0);
timeConfusion = struct('tp', 0, 'tn', 0, 'fp', 0, 'fn', 0);

%% Compute the different types of metrics given the 
if ~iscell(trueEvents)
    trueEvents = {trueEvents};
    labeledEvents = {labeledEvents};
end
for m = 1:length(trueEvents)
    [tp, tn, fp, fn] = getConfusionCounts(trueEvents{m}, labeledEvents{m}, ...
        totalTimes(m), params.spindleDuration, params.epochLength);
    countConfusion.tp = countConfusion.tp + tp;
    countConfusion.tn = countConfusion.tn + tn;
    countConfusion.fp = countConfusion.fp + fp;
    countConfusion.fn = countConfusion.fn + fn;
    
    [tp, tn, fp, fn] = getConfusionHits(trueEvents{m}, ...
        labeledEvents{m}, totalTimes(m), params.spindleDuration);
    hitConfusion.tp = hitConfusion.tp + tp;
    hitConfusion.tn = hitConfusion.tn + tn;
    hitConfusion.fp = hitConfusion.fp + fp;
    hitConfusion.fn = hitConfusion.fn + fn;
    
    [tp, tn, fp, fn] = getConfusionIntersects(trueEvents{m}, ...
        labeledEvents{m}, totalTimes(m), ...
        params.toleranceIntersect, params.spindleDuration);
    intersectConfusion.tp = intersectConfusion.tp + tp;
    intersectConfusion.tn = intersectConfusion.tn + tn;
    intersectConfusion.fp = intersectConfusion.fp + fp;
    intersectConfusion.fn = intersectConfusion.fn + fn;
    
    [tp, tn, fp, fn] = getConfusionOnsets(trueEvents{m}, ...
         labeledEvents{m}, totalTimes(m), params.toleranceOnset, ...
         params.spindleDuration);
    onsetConfusion.tp = onsetConfusion.tp + tp;
    onsetConfusion.tn = onsetConfusion.tn + tn;
    onsetConfusion.fp = onsetConfusion.fp + fp;
    onsetConfusion.fn = onsetConfusion.fn + fn;
 
    [tp, tn, fp, fn] = getConfusionTimes(trueEvents{m}, ...
        labeledEvents{m}, totalTimes(m), srate, params.toleranceTiming);
    timeConfusion.tp = timeConfusion.tp + tp;
    timeConfusion.tn = timeConfusion.tn + tn;
    timeConfusion.fp = timeConfusion.fp + fp;
    timeConfusion.fn = timeConfusion.fn + fn;
end

metrics.count = getConfusionMetrics(countConfusion);
metrics.hit = getConfusionMetrics(hitConfusion);
metrics.onset = getConfusionMetrics(onsetConfusion);
metrics.intersect = getConfusionMetrics(intersectConfusion);
metrics.time = getConfusionMetrics(timeConfusion);
