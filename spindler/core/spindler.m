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
    [spindles, atomParams, sigmaFreq, scaledGabors, params] = ...
                                  spindlerExtractSpindles(data, params);
    [spindlerCurves, warningMsgs] = spindlerGetParameterCurves(spindles, imageDir, params);
    if spindlerCurves.bestEligibleLinearInd > 0
         events = spindles(spindlerCurves.bestEligibleLinearInd).events;
    else
        events = [];
    end
    
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
            spindlerShowMetric(spindlerCurves, allMetrics, params.metricNames{n}, ...
                imageDir, params);
        end
        metrics = struct();
        if spindlerCurves.bestEligibleLinearInd > 0
            metrics = allMetrics(spindlerCurves.bestEligibleLinearInd);
        end
    end
    additionalInfo.spindles = spindles;
    additionalInfo.spindlerCurves = spindlerCurves;
    additionalInfo.metrics = metrics;
    additionalInfo.warningMsgs = warningMsgs;  
end
