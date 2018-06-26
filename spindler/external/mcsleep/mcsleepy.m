function  [spindles, additionalInfo, params] =  ...
                          mcsleepy(data, expertEvents, imageDir, params) 
%% Run the mcsleep algorithm on the data.  
%
%  Parameters:
%     data           channels x frames array of EEG data
%     expertEvents   n x 2 array of start and end times of expert events
%     imageDir       path to directory to dump images or empty if no dump
%     params         structure with the parameters for the algorithm
   
   %% Set up the parameters and check that the data is not empty
    defaults = concatenateStructs(getGeneralDefaults(), mcsleepGetDefaults());
    params = processParameters('mcsleepy', nargin, 4, params, defaults);
    if isempty(data)
       additionalInfo.warningMsgs = 'mcsleepy: data is empty algorithm fails';
       warning(additionalInfo.warningMsgs);
       return
    end
    
    %% Calculate the spindle representations for a range of parameters
    [spindles, params] = mcsleepExtractSpindles(data, params);
    additionalInfo.parameterCurves = ...
                     mcsleepGetParameterCurves(spindles, imageDir, params);
   
    %% Process the expert events if available   
    if ~isempty(expertEvents)
        numThresholds = length(params.mcsleepThresholds);
        numLambda2s = length(params.mcsleepLambda2s);
        allMetrics(numLambda2s, numThresholds) = ...
            struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                   'onset', NaN, 'time', NaN);
        totalTime = length(data)/params.srate;
        for n = 1:numLambda2s
            for m = 1:numThresholds
                allMetrics(n, m) = getPerformanceMetrics(expertEvents, ...
                    spindles(n, m).events, spindles(n, m).totalTime, params);
            end
        end
        
        for n = 1:length(params.metricNames)
            mcsleepShowMetric(allMetrics, params.metricNames{n}, ...
                              imageDir, params);
        end
    else
        allMetrics = [];
    end
    
    additionalInfo.allMetrics = allMetrics;
end