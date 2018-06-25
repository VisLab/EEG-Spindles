function  [spindles, additionalInfo, params] =  ...
                              spinky(data, expertEvents, imageDir, params) 
%% Run the spinky algorithm on the data.
%
%  Parameters:
%     data           1 x frames array of EEG data
%     expertEvents   n x 2 array of start and end times of expert events
%     imageDir       path to directory to dump images or empty if no dump
%     params         structure with the parameters for the algorithm
   
    %% Set up the parameters and check that the data is not empty
    defaults = concatenateStructs(getGeneralDefaults(), spinkyGetDefaults());
    params = processParameters('spinky', nargin, 4, params, defaults); 
    if isempty(data)
       additionalInfo.warningMsgs = 'spinky: data is empty algorithm fails';
       warning(additionalInfo.warningMsgs);
       return
    end
    
   %% Calculate the spindle representations for a range of parameters
    [spindles, params, additionalInfo.oscil] = ...
                   spinkyExtractSpindles(data, [], params);
  
    additionalInfo.parameterCurves = ...
                    spinkyGetParameterCurves(spindles, imageDir, params);
    
    %% Process the expert events if available
    if ~isempty(expertEvents)
        numExp = length(spindles);
        allMetrics(numExp) = ...
            struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                   'onset', NaN, 'time', NaN);
        totalTime = length(data)/params.srate;
        for n = 1:numExp
            allMetrics(n) = getPerformanceMetrics(expertEvents, spindles(n).events, ...
                totalTime, params);
        end
        thresholds = params.thresholds;
        for n = 1:length(params.metricNames)
            spinkyShowMetric(thresholds, allMetrics, params.metricNames{n}, ...
                imageDir, params);
        end
    else
        allMetrics = []; 
    end
    
    additionalInfo.allMetrics = allMetrics;
end