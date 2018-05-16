function [spindles, params, oscil] = spinkyExtractSpindles(data, thresholds, params)
%% Run the spinky algorithm on the data.  Given
%
%  Parameters:
%     data
    %% Set the epoch size and number of training frames and epoch the data
    totalTime = length(data)/params.srate;
    epochTime = params.epochLength;
    if epochTime > totalTime
        warning('%s data is smaller than 1 epoch, resetting epoch', ...
                 params.name);
        epochTime = totalTime;
    end
    epochFrames = round(epochTime*params.srate);
    epochedData = epochData(data, epochFrames); 
    fs = params.srate;

    %% Get the oscillatory representation of the data.
    fprintf('Computing the oscillatory representation\n');
    oscil = getSpinkySignalDecomposition(epochedData, fs);

    %% Get the threshold range
    if isempty(thresholds)
       frequencyRange = params.spinkySpindleFrequencyRange;
       fs = params.srate;
       thresholds = spinkyGetThresholdRange(oscil, fs, frequencyRange);
    end
    %% Run the test
    fprintf('Thresholding the oscillations to calculate the spindles\n');
    spinkySpindles = spinkyCalculateSpindles(oscil, thresholds, params);
    params.thresholds = thresholds;
    numThresholds = length(thresholds);
    spindles(numThresholds) = struct('threshold', 0, ...
                   'numberSpindles', 0, 'spindleTime', 0, 'events', NaN);
    for k = 1:numThresholds
        spindles(k) = spindles(end);
        spindles(k).threshold = spinkySpindles(k).threshold;
        events = epochedToList(spinkySpindles(k).spindleList, epochTime);
        events = combineEvents(events, params.spindleLengthMin, ...
                               params.spindleSeparationMin);
        spindles(k).events = events;
        if ~isempty(events)
            spindles(k).numberSpindles = size(events, 1);
            spindles(k).spindleTime = sum(events(:, 2) - events(:, 1));
        end
    end
end