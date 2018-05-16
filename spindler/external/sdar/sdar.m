function [spindles, allMetrics, additionalInfo, params] =  ...
                             sdar(data, expertEvents, imageDir, params)    
%% Run the SDAR algorithm to generate parameter curves


%% Extract spindles and parameter curves
    [spindles, params] = sdarExtractSpindles(data, params);
    sdarCurves = sdarGetParameterCurves(spindles, imageDir, params);
   
    %% Process the expert events if available
       metrics = struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                        'onset', NaN, 'time', NaN); 
    if ~isempty(expertEvents)
        totalTime = length(data)/params.srate;
        numExp = length(spindles);
        allMetrics(numExp) = metrics;
        for n = 1:numExp
            allMetrics(n) = getPerformanceMetrics(expertEvents, ...
                               spindles(n).events, totalTime, params);
        end
        
        for n = 1:length(params.metricNames)
            sdarShowMetric(sdarCurves, allMetrics, params.metricNames{n}, ...
                imageDir, params);
        end
  
    end
    additionalInfo.spindles = spindles;
    additionalInfo.sdarCurves = sdarCurves;
end