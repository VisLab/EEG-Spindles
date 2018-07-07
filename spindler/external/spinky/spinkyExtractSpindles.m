function [spindles, params, thresholds, oscil] = ...
                 spinkyExtractSpindles(data, srate, thresholds, params)
%% Run the spinky algorithm on the data.  Given
%
%  Parameters:
%     data        1xn array with data
%     srate       sampling rate in Hz
%     thresholds  hard-coded thresholds (if empty these are computed)
%     params      (input) structure with parameters
%     spindles    (output) Structure with spindles as a structure on
%                  grid of threshold.
%     params      (output) adjusted parameters
%     thresholds  (output) adjusted thresholds
%     oscil       (output) Oscillatory portion of the signal
%
% Written by Kay Robbins, UTSA, 2018
    %% Set the epoch size and number of training frames and epoch the data
    totalTime = length(data)/srate;
    if params.epochLength > totalTime
        warning('%s data is smaller than 1 epoch, resetting epoch', ...
                 params.name);
        params.epochLength = totalTime;
    end
    epochFrames = round(params.epochLength*srate);
    epochedData = epochData(data, epochFrames); 
    totalTime = (size(epochedData, 1)*size(epochedData, 2))/srate;
    
    %% Get the oscillatory representation of the data.
    fprintf('Computing the oscillatory representation\n');
    oscil = getSpinkySignalDecomposition(epochedData, srate);

    %% Get the threshold range
    if isempty(thresholds)
       frequencyRange = params.spindleFrequencyRange;
       thresholds = spinkyGetThresholdRange(oscil, srate, frequencyRange);
    end
    %% Run the test
    fprintf('Thresholding the oscillations to calculate the spindles\n');
    spinkySpindles = spinkyCalculateSpindles(oscil, srate, thresholds, params);
    numThresholds = length(thresholds);
    spindles(numThresholds) = struct('threshold', 0, 'numberSpindles', 0, ...
                       'spindleTime', 0, 'totalTime', 0, 'events', NaN);
    for k = 1:numThresholds
        spindles(k) = spindles(end);
        spindles(k).threshold = spinkySpindles(k).threshold;
        events = ...
            epochedToList(spinkySpindles(k).spindleList, params.epochLength);
        events = combineEvents(events, params.spindleLengthMin, ...
                     params.spindleSeparationMin, params.spindleLengthMax);
        spindles(k).totalTime = totalTime;
        spindles(k).events = events;
        if ~isempty(events)
            spindles(k).numberSpindles = size(events, 1);
            spindles(k).spindleTime = sum(events(:, 2) - events(:, 1));
        end
    end
end