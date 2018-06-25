function [spindles, additionalInfo, params] =  spindler(data, expertEvents, imageDir, params)
%% Calculate the spindles and performance using spindler
%
%  Parameters:
%      data           1 x n data for spindles
%      expertEvents   events
%      imageDir       if not empty, dump the parameter curves
%      params         parameters for the algorithm
%
%     
   %% Set up the parameters and check that the data is not empty
    defaults = concatenateStructs(getGeneralDefaults(), spindlerGetDefaults());
    params = processParameters('spindler', nargin, 4, params, defaults);
    if isempty(data)
       additionalInfo.warningMsgs = 'spindler: data is empty algorithm fails';
       warning(additionalInfo.warningMsgs);
       return
    end
    
     %% Calculate the spindle representations for a range of parameters
    [spindles, params] = spindlerExtractSpindles(data, params);
    [additionalInfo.spindlerCurves, additionalInfo.warningMsgs] = ...
                  spindlerGetParameterCurves(spindles, imageDir, params);
 
    %% Process the expert events if available
    if ~isempty(expertEvents)   
        [numAtoms, numThresholds] = size(spindles);
        allMetrics(numAtoms, numThresholds) = ...
             struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                        'onset', NaN, 'time', NaN);
        totalTime = length(data)/params.srate;
        for k = 1:numAtoms
            for j = 1:numThresholds
                allMetrics(k, j) = getPerformanceMetrics(expertEvents, ...
                                 spindles(k, j).events, totalTime, params);
            end
        end
        
        for n = 1:length(params.metricNames)
            spindlerShowMetric(additionalInfo.spindlerCurves, allMetrics, ...
                params.metricNames{n}, imageDir, params);
        end
    else
        allMetrics = [];
    end
    additionalInfo.allMetrics = allMetrics;
end
