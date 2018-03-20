function [events, metrics, additionalInfo, params] =  spindler(EEG, channelLabels, expertEvents, imageDir, paramsInit)
%% Get the data and event file names and check that we have the same number

    %% Read in the EEG and find the correct channel number
    [channelNumber, channelLabel] = getChannelNumber(EEG, channelLabels);
    if isempty(channelNumber)
        warning('%s does not have the channel in question, cannot compute....', ...
            EEG.setname);
        return;
    end
    
    %% Calculate the spindle representations for a range of parameters
    [spindles, params] = spindlerExtractSpindles(EEG, channelNumber, paramsInit);
    metricNames = params.metricNames;
    methodNames = params.methodNames;
    params.name = EEG.setname;
    [spindlerCurves, warningMsgs] = spindlerGetParameterCurves(spindles, imageDir, params);
    if spindlerCurves.bestEligibleLinearInd > 0
         events = spindles(spindlerCurves.bestEligibleLinearInd).events;
    end
    
    %% Process the expert events if available
    numExperts = length(expertEvents);
    metrics = cell(numExperts, 1);
    
    for k = 1:numExperts
        [theseMetrics, params] = calculatePerformance(spindles, expertEvents{k}, params);
        for n = 1:length(metricNames)
            spindlerShowMetric(spindlerCurves, theseMetrics, metricNames{n}, ...
                       imageDir, params);
        end
        if spindlerCurves.bestEligibleLinearInd > 0
            metrics{k} = theseMetrics(spindlerCurves.bestEligibleLinearInd);
        end
    end
   
    additionalInfo.spindles = spindles;
    additionalInfo.spindlerCurves = spindlerCurves;
    additionalInfo.metrics = metrics;
    additionalInfo.warningMsgs = warningMsgs;
   
end
