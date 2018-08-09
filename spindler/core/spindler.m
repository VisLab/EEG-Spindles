function [spindles, additionalInfo, params] =  ...
                    spindler(data, srate, expertEvents, imageDir, params)
%% Calculate the spindles and performance using spindler
%
%  Parameters:
%      data           1 x n data for spindles
%      srate          sampling rate in Hz for the data
%      expertEvents   n x 2 array of start and end times of ground truth
%      imageDir       if not empty, dump the parameter curves
%      params         parameters for the algorithm
% 
%  Written by:  Kay Robbins, 2017-2018  

   %% Set up the parameters and check that the data is not empty
    defaults = concatenateStructs(getGeneralDefaults(), spindlerGetDefaults());
    additionalInfo = struct('algorithm', 'spindler', 'srate', srate, ...
        'parameterCurves', nan, 'warningMsgs', [], 'allMetrics', nan);
    params = processParameters('spindler', nargin, 5, params, defaults);
    if isempty(data)
       additionalInfo.warningMsgs = 'spindler: data is empty algorithm fails';
       warning(additionalInfo.warningMsgs);
       return
    end
    totalTime = length(data)/srate;
    
     %% Calculate the spindle representations for a range of parameters
    [spindles, params, additionalInfo.atomParams, additionalInfo.sigmaFreq, ...
        additionalInfo.scaledGabors] = ...
        spindlerExtractSpindles(data, srate, params);
    [additionalInfo.parameterCurves, additionalInfo.warningMsgs] = ...
        spindlerGetParameterCurves(spindles, totalTime, imageDir, params);
 
    %% Process the expert events if available
    if ~isempty(expertEvents)   
        [numAtoms, numThresholds] = size(spindles);
        allMetrics(numAtoms, numThresholds) = ...
             struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                        'onset', NaN, 'time', NaN);
        
        for k = 1:numAtoms
            for j = 1:numThresholds
                allMetrics(k, j) = getPerformanceMetrics(expertEvents, ...
                          spindles(k, j).events, srate, totalTime, params);
            end
        end
        
        for n = 1:length(params.metricNames)
            spindlerShowMetric(additionalInfo.parameterCurves, allMetrics, ...
                params.metricNames{n}, imageDir, params);
        end
        additionalInfo.allMetrics = allMetrics;
    end
    
end
