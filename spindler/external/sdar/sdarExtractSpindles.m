function [spindles, params] = sdarExtractSpindles(data, params)
%% Calculate spindle events from different Gabor reconstructions 
%  
%  Parameters:
%    EEG              Input EEG structure (EEGLAB format)
%    channelNumber    Channel number to analyze
%    expertEvents     A two-column vector with the start and end times of
%                     spindles (in seconds) giving ground truth. If empty,
%                     no performance metrics are computed.
%    params           (Input/Output) Structure with parameters for algorithm 
%                            (See getSpindleDefaults)
%    spindles         (Output) Structure with MP and performance information
%    atomParams       (Output) Array with frequency, scale, and phase of dictionary
%    scaledGabors     (Output) Gabor atoms that form the dictionary.
%
%  Written by:     J. LaRocco, K. Robbins, UTSA 2016-2017
%

%% Process the input parameters and set up the calculation
defaults = concatenateStructs(getGeneralDefaults(), sdarGetDefaults());
params = processParameters('sdarExtractSpindles', nargin, 2, params, defaults);

%% Bandpass the data to start
lowFreq = max(1, params.sdarFrequencies(1));
highFreq = min(ceil(params.srate/2.1), max(params.sdarFrequencies(2)));
data = getFilteredData(data, params.srate, lowFreq, highFreq);
minLength = params.spindleLengthMin;
minSeparation = params.spindleSeparationMin;
maxLength = params.spindleLengthMax;
%% Calculate the discounted AR model
order = params.sdarModelOrder;
discountRate = params.sdarDiscountRate;
initialPoints = params.sdarInitialPoints;
[mu, sigma, loss, ~] = SDARv3(data, order, discountRate, initialPoints);
params.mu = mu;
params.sigma = sigma;
params.frames = length(data);

%% Smooth the model
smoothed = moving_average(loss, params.sdarSmoothWindow);
% smoothedScale = prctile(abs(smoothed(:)), 99);
% fprintf('max smoothed = %g, scale = %g\n', max(smoothed), smoothedScale);
% baseThresholds = linspace(min(smoothed), max(smoothed), params.sdarNumberThresholds + 1);
% baseThresholds = baseThresholds(2:end);
baseThresholds = min(smoothed) + params.sdarThresholds*(max(smoothed) - min(smoothed));
%% Combine adjacent spindles and eliminate items that are too short.
numThresholds = size(baseThresholds(:), 1);
spindles(numThresholds) = struct('baseThresholds', NaN', ...
           'numberSpindles', NaN, 'spindleTime', NaN, 'events', NaN);
               
for k = 1:numThresholds
   spindles(k) = spindles(end);
   spindles(k).baseThresholds = baseThresholds(k);
   eventCells =  applyThreshold(smoothed, params.srate, baseThresholds(k), 1/3);
   startEvents = cellfun(@double, eventCells(:, 2));
   endEvents = cellfun(@double, eventCells(:, 3));
   events = [startEvents(:), endEvents(:)];
   events = combineEvents(events, minLength, minSeparation, maxLength);
   spindles(k).events = events;
   [spindles(k).numberSpindles, spindles(k).spindleTime] = getSpindleCounts(events);
end