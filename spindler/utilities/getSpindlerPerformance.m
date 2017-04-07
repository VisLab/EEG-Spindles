function [metrics, expertEvents, params] = ...
                 getSpindlerPerformance(spindles, expertEvents, params)
%% Calculate performance for representations in spdinles
%  
%  Parameters:
%    spindles         Structure with MP and performance information
%    expertEvents     (Input/Output) A two-column vector with the start and end times of
%                     spindles (in seconds) giving ground truth. If empty,
%                     no performance metrics are computed. Overlapping 
%                     events are removed, so input might not be the same.
%    params           (Input/Output) Structure with parameters for algorithm 
%                            (See getSpindleDefaults)
%
%  Written by:     J. LaRocco, K. Robbins, UTSA 2016-2017
%

%% Process the input parameters and set up the calculation
params = processSpindlerParameters('calculatePerformance', nargin, 2, params);
expertEvents = removeOverlapEvents(expertEvents, params.spindlerOverlapMethod);
numExp = length(spindles);
metrics(numExp) = struct('hitMetrics', NaN, 'intersectMetrics', NaN, ...
                        'onsetMetrics', NaN, 'timeMetrics', NaN);
frames = params.frames;
srate = params.srate;
for k = 1:numExp
    metrics(k) = metrics(numExp);
    [hitMetrics, intersectMetrics, onsetMetrics, timeMetrics] = ...
        getPerformanceMetrics(expertEvents, spindles(k).events, ...
                              frames, srate, params);
    metrics(k).hitMetrics = hitMetrics;
    metrics(k).intersectMetrics = intersectMetrics;
    metrics(k).onsetMetrics = onsetMetrics;
    metrics(k).timeMetrics = timeMetrics;
end