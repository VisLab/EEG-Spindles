function [spindles, params, additionalInfo] =  ...
                     sdar(data, srate, expertEvents, imageDir, params)    
%% Run the SDAR algorithm to generate parameter curves


%% Extract spindles and parameter curves
   defaults = concatenateStructs(getGeneralDefaults(), sdarGetDefaults());
    additionalInfo = struct('algorithm', 'sdar', 'srate', srate, ...
        'parameterCurves', nan, 'warningMsgs', [], 'allMetrics', nan);
    params = processParameters('sdar', nargin, 5, params, defaults);
    if isempty(data)
       additionalInfo.warningMsgs = 'sdar: data is empty algorithm fails';
       warning(additionalInfo.warningMsgs);
       return
    end
    totalTime = length(data)/srate;
    
     %% Calculate the spindle representations for a range of parameters
    [spindles, params] = sdarExtractSpindles(data, srate, params);
    additionalInfo.parameterCurves = ...
        sdarGetParameterCurves(spindles, totalTime, imageDir, params);
    totalTime = length(data)/srate;
    %% Process the expert events if available
       metrics = struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                        'onset', NaN, 'time', NaN); 
    if ~isempty(expertEvents)    
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
        additionalInfo.allMetrics = allMetrics;
    end
    
end