function [events, metrics, additionalInfo, params] =  ...
                        spinky(data, expertEvents, params)
%% Run the spinky algorithm on the data.


%% Set up the metrics for evaluation
    metrics = struct();
    additionalInfo = struct();
    events = [];
    for j = 1:length(params.methodNames)
        metrics.(params.methodNames{j}) = NaN;
    end
   
    %% Set the epoch size and number of training frames and epoch the data
    totalTime = length(data)/params.srate;
    epochTime = params.epochLength;
    if epochTime > totalTime
        warning('%s data is smaller than 1 epoch, resetting epoch', ...
                 params.name);
        epochTime = totalTime;
    end
    epochFrames = round(epochTime*params.srate);
    totalEpochs = floor(totalTime/epochTime);
    epochedData = epochData(data, epochFrames); 
    
    %% Now load the events and epoch
    if isempty(expertEvents)
       eventCounts = [];
       eventLists = [];
    else
       [eventCounts, eventLists] = epochEvents(expertEvents, totalTime, epochTime);
    end

    %% Now set up the training set if training data is available
    
    optimalThreshold = params.spinkyDefaultThreshold;
    trainingEpochs = round(params.supervisedTrainingDataLength/epochTime);
    if trainingEpochs >= totalEpochs
        trainingEpochs = 0;
        warning (['%s\n--- Data is too short to train -- '...
                  'reverting to default threshold %g'], ...
                  params.name, optimalThreshold);
    elseif sum(eventCounts(1:trainingEpochs)) < params.trainingEventsMin
        warning(['%s\n--- only %d events in training --- ' ...
                 'reverting to default threshold %g'], ...
                 params.name, optimalThreshold);
    else
       optimalThreshold = spinkyTrain(epochedData(1:trainingEpochs, :), ...
           eventCounts(1:trainingEpochs), params);
    end
    additionalInfo.optimalThreshold = optimalThreshold;
    
    %% Run the test
    [spindleCounts, ~, spindleList] = ...
            spinkyTest(epochedData(trainingEpochs + 1:end, :), ...
                       optimalThreshold, params);
    labeledEvents = cell(length(spindleCounts), 1);
    for m = 1:length(spindleCounts)
        labeledEvents{m} = combineEvents(spindleList{m}, params.spindleLengthMin, ...
                                     params.spindleSeparationMin);
    end
  
    %% Deal with ground truth if available
    if ~isempty(eventCounts)
        testEvents = eventLists(trainingEpochs + 1:end);  
        epochTimes = repmat(epochTime, length(testEvents), 1);
        [metrics.countMetrics, metrics.hitMetrics, ...
         metrics.intersectMetrics, metrics.onsetMetrics, metrics.timeMetrics] = ...
             getPerformanceMetrics(testEvents, labeledEvents, ...
             epochTimes, params);
    end
    
end