function  [spindles, allMetrics, additionalInfo, params] =  ...
                              mcsleepy(data, expertEvents, imageDir, params) 
%% Run the spinky algorithm on the data.  Given
%
%  Parameters:
%     data
   
    %% Calculate the spindles
    [spindles, params] = mcsleepExtractSpindles(data, params);
    additionalInfo.parameterCurves = ...
                     mcsleepGetParameterCurves(spindles, imageDir, params);
    additionalInfo.spindles = spindles;
    numThresholds = length(params.mcsleepThresholds);
    numLambda2s = length(params.mcsleepLambda2s);
    
    %% Process the expert events if available
    metrics = struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
        'onset', NaN, 'time', NaN);
    allMetrics(numLambda2s, numThresholds) = metrics;
    if ~isempty(expertEvents)
        totalTime = length(data)/params.srate;
        for n = 1:numLambda2s
            for m = 1:numThresholds
                allMetrics(n, m) = getPerformanceMetrics(expertEvents, ...
                    spindles(n, m).events, totalTime, params);
            end
        end
        
        for n = 1:length(params.metricNames)
            mcsleepShowMetric(allMetrics, params.metricNames{n}, ...
                              imageDir, params);
        end
    
    end
    
    additionalInfo.allMetrics = allMetrics;
end