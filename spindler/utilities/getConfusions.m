function [countConfusion, hitConfusion, intersectConfusion, onsetConfusion, timeConfusion] = ...
             getConfusions(trueEvents, labeledEvents, totalTimes, params)

%  Written by:  John La Rocco and Kay Robbins, UTSA, 2016-2017
params = processParameters('getConfusions', ...
                       nargin, 3, params, getGeneralDefaults());
countConfusion = struct('tp', 0, 'tn', 0, 'fp', 0, 'fn', 0);
hitConfusion = struct('tp', 0, 'tn', 0, 'fp', 0, 'fn', 0);
intersectConfusion = struct('tp', 0, 'tn', 0, 'fp', 0, 'fn', 0);
onsetConfusion = struct('tp', 0, 'tn', 0, 'fp', 0, 'fn', 0);
timeConfusion = struct('tp', 0, 'tn', 0, 'fp', 0, 'fn', 0);
spindleDuration = params.spindleDuration;
epochTime = params.epochLength;
%% Compute the different types of metrics given the 
if ~iscell(trueEvents)
    trueEvents = {trueEvents};
    labeledEvents = {labeledEvents};
end
for m = 1:length(trueEvents)
    [tp, tn, fp, fn] = getConfusionCounts(trueEvents{m}, ...
        labeledEvents{m}, totalTimes(m), spindleDuration, epochTime);
    countConfusion.tp = countConfusion.tp + tp;
    countConfusion.tn = countConfusion.tn + tn;
    countConfusion.fp = countConfusion.fp + fp;
    countConfusion.fn = countConfusion.fn + fn;
    
    [tp, tn, fp, fn] = getConfusionHits(trueEvents{m}, ...
        labeledEvents{m}, totalTimes(m), spindleDuration);
    hitConfusion.tp = hitConfusion.tp + tp;
    hitConfusion.tn = hitConfusion.tn + tn;
    hitConfusion.fp = hitConfusion.fp + fp;
    hitConfusion.fn = hitConfusion.fn + fn;
    
    [tp, tn, fp, fn] = getConfusionIntersects(trueEvents{m}, ...
        labeledEvents{m}, totalTimes(m), params.toleranceIntersect, spindleDuration);
    intersectConfusion.tp = intersectConfusion.tp + tp;
    intersectConfusion.tn = intersectConfusion.tn + tn;
    intersectConfusion.fp = intersectConfusion.fp + fp;
    intersectConfusion.fn = intersectConfusion.fn + fn;
    
    [tp, tn, fp, fn] = getConfusionOnsets(trueEvents{m}, ...
         labeledEvents{m}, totalTimes(m), params.toleranceOnset, spindleDuration);
    onsetConfusion.tp = onsetConfusion.tp + tp;
    onsetConfusion.tn = onsetConfusion.tn + tn;
    onsetConfusion.fp = onsetConfusion.fp + fp;
    onsetConfusion.fn = onsetConfusion.fn + fn;
 
    [tp, tn, fp, fn] = getConfusionTimes(trueEvents{m}, ...
        labeledEvents{m}, totalTimes(m), params.srate, params.toleranceTiming);
    timeConfusion.tp = timeConfusion.tp + tp;
    timeConfusion.tn = timeConfusion.tn + tn;
    timeConfusion.fp = timeConfusion.fp + fp;
    timeConfusion.fn = timeConfusion.fn + fn;
end
