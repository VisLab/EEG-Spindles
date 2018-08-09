function  [spindles, params, additionalInfo] =  ...
                    spinky(data, srate, expertEvents, imageDir, params) 
%% Run the spinky algorithm on the data.
%
%  Parameters:
%     data           1 x frames array of EEG data
%     expertEvents   n x 2 array of start and end times of expert events
%     imageDir       path to directory to dump images or empty if no dump
%     params         (input/output) structure with the parameters for the algorithm
%     spindles       structure with spindles at each threshold value
%     additionalInfo structure with details of the results
%
% Written by Kay Robbins, UTSA 2017-2018

    %% Set up the parameters and check that the data is not empty
    defaults = concatenateStructs(getGeneralDefaults(), spinkyGetDefaults());
    additionalInfo = struct('algorithm', 'spinky', 'srate', srate, ...
        'parameterCurves', nan, 'warningMsgs', [], 'allMetrics', nan);
    params = processParameters('spinky', nargin, 5, params, defaults); 
    if isempty(data)
       additionalInfo.warningMsgs = 'spinky: data is empty algorithm fails';
       warning(additionalInfo.warningMsgs);
       return
    end
    totalTime = length(data)/srate;
   %% Calculate the spindle representations for a range of parameters
   [spindles, params, additionalInfo.thresholds, additionalInfo.oscil] = ...
        spinkyExtractSpindles(data, srate, [], params);
  
    additionalInfo.parameterCurves = ...
        spinkyGetParameterCurves(spindles, totalTime, imageDir, params);
    
    %% Process the expert events if available
    if ~isempty(expertEvents)
        numExp = length(spindles);
        allMetrics(numExp) = ...
            struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                   'onset', NaN, 'time', NaN);
        totalTime = length(data)/srate;
        for n = 1:numExp
            allMetrics(n) = getPerformanceMetrics(expertEvents, ...
                spindles(n).events, srate, totalTime, params);
        end
        
        for n = 1:length(params.metricNames)
            spinkyShowMetric(additionalInfo.thresholds, ...
                allMetrics, params.metricNames{n}, imageDir, params);
        end
        additionalInfo.allMetrics = allMetrics;
    end
    
    
end