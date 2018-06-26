function [metrics, params] = ...
                 getSpindlerPerformance(spindles, expertEvents, params)
%% Calculate performance for representations in spindles
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
params = processParameters('calculatePerformance', ...
                     nargin, 2, params, getGeneralDefaults());

params = processParameters('calculatePerformance', ...
                     nargin, 2, params, getGeneralDefaults());

numExp = length(spindles);
metrics(numExp) = struct('hitMetrics', NaN, 'intersectMetrics', NaN, ...
                        'onsetMetrics', NaN, 'timeMetrics', NaN);

for k = 1:numExp
    metrics(k) = metrics(numExp);
    [metrics(k).countMetrics, metrics(k).hitMetrics, ...
        metrics(k).intersectMetrics, metrics(k).onsetMetrics, metrics(k).timeMetrics] = ...
        getPerformanceMetrics(expertEvents, spindles(k).events, ...
                              totalTimes, params);
end