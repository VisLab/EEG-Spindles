function  [spindles, allMetrics, additionalInfo, params] =  ...
                              mcsleepy(data, expertEvents, imageDir, params) 
%% Run the spinky algorithm on the data.  Given
%
%  Parameters:
%     data
   
    %% Calculate the spindles
    [spindles, params] = mcsleepExtractSpindles(data, params);
    parameterCurves = mcsleepGetParameterCurves(spindles, imageDir, params);
    additionalInfo.parameterCurves = parameterCurves;
    %% Process the expert events if available
    metrics = struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                        'onset', NaN, 'time', NaN); 
    if ~isempty(expertEvents)
        totalTime = length(data)/params.srate;
        numExp = length(spindles);
        allMetrics(numExp) = metrics;
        for n = 1:numExp
            allMetrics(n) = getPerformanceMetrics(expertEvents, spindles(n).events, ...
                totalTime, params);
        end
        
        for n = 1:length(params.metricNames)
            mcsleepShowMetric(allMetrics, params.metricNames{n}, ...
                              imageDir, params);
        end
    
    end
    additionalInfo.spindles = spindles;
    additionalInfo.allMetrics = allMetrics;
end