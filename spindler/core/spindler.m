function [events, metrics, additionalInfo, params] =  spindler(data, expertEvents, imageDir, params)
%% Calculate the spindles and performance using spindler
%
%  Parameters:
%      data           1 x n data for spindles
%      expertEvents   events
%      imageDir       if not empty, dump the parameter curvers
%      params         parameters for the algorithm
%
%     
    %% Calculate the spindle representations for a range of parameters
    events = [];
    metrics = [];
    if isempty(data)
       additionalInfo.warningMsgs = 'spindler: data is empty algorithm fails';
       warning(additionalInfo.warningMsgs);
       return
    end
    [spindles, params] = spindlerExtractSpindles(data, params);
    [spindlerCurves, warningMsgs] = ...
                  spindlerGetParameterCurves(spindles, imageDir, params);
    if spindlerCurves.bestEligibleAtomInd > 0
         events = spindles(spindlerCurves.bestEligibleAtomInd, ...
                           spindlerCurves.bestEligibleThresholdInd).events;
    else
        events = [];
    end
    
    %% Process the expert events if available
    metrics = struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                        'onset', NaN, 'time', NaN); 
    if ~isempty(expertEvents)
        totalTime = length(data)/params.srate;
        [numAtoms, numThresholds] = size(spindles);
        allMetrics(numAtoms, numThresholds) = metrics;
        for k = 1:numAtoms
            for j = 1:numThresholds
                allMetrics(k, j) = getPerformanceMetrics(expertEvents, ...
                                 spindles(k, j).events, totalTime, params);
            end
        end
        
        for n = 1:length(params.metricNames)
            spindlerShowMetric(spindlerCurves, allMetrics, ...
                params.metricNames{n}, imageDir, params);
        end
        metrics = struct();
        if spindlerCurves.bestEligibleThresholdInd > 0 && ...
           spindlerCurves.bestEligibleAtomInd > 0
            metrics = allMetrics(spindlerCurves.bestEligibleAtomInd, ...
                                 spindlerCurves.bestEligibleThresholdInd);
        end
    end
    additionalInfo.spindles = spindles;
    additionalInfo.spindlerCurves = spindlerCurves;
    additionalInfo.metrics = metrics;
    additionalInfo.warningMsgs = warningMsgs;  
end
