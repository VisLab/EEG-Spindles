function [spindles, params] = extractSpindlesSdar(EEG, channelNumber, params)
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
defaults = concatenateStructs(getGeneralDefaults(), getSdarDefaults());
params = processParameters('extractSpindlesSdar', nargin, 2, params, defaults);

params.channelNumber = channelNumber;
params.channelLabels = EEG.chanlocs(channelNumber).labels;
if isempty(channelNumber)
    error('extractSpindlesSdar:NoChannels', 'Must have non-empty');
end  

minLength = params.minSpindleLength;
minSeparation = params.minSpindleSeparation;

%% Handle the baseThresholds (making sure thresholds 0 and 1 are included)
baseThresholds = params.sdarBaseThresholds;
% baseThresholds = sort(baseThresholds);
% if baseThresholds(1) ~= 0
%     baseThresholds = [0, baseThresholds];
% end
% if baseThresholds(end) ~= 1
%     baseThresholds = [baseThresholds, 1];
% end
% params.sdarBaseThresholds = baseThresholds;

%% Extract the channels and filter the EEG signal 
if channelNumber > size(EEG.data, 1)
    error('extractSpindlesSdar:BadChannel', 'The EEG does not have channel needed');
end
params.srateOriginal = EEG.srate;
EEG.data = EEG.data(channelNumber, :);
EEG.chanlocs = EEG.chanlocs(channelNumber);
EEG.nbchan = 1;
EEG = resampleToTarget(EEG, params.srateTarget);
srate = EEG.srate;
numFrames = size(EEG.data, 2);
totalTime = (numFrames - 1)/srate;
params.srate = srate;
params.frames = numFrames;

%% Bandpass filter the EEG
lowFreq = max(1, params.sdarFrequencies(1));
highFreq = min(ceil(EEG.srate/2.1), max(params.sdarFrequencies(2)));
EEGFilt = pop_eegfiltnew(EEG, lowFreq, highFreq);

%% Calculate the discounted AR model
order = params.sdarModelOrder;
discountRate = params.sdarDiscountRate;
initialPoints = params.sdarInitialPoints;
[mu, sigma, loss, ~] = SDARv3(EEGFilt.data, order, discountRate, initialPoints);
params.mu = mu;
params.sigma = sigma;

%% Smooth the model
smoothed = moving_average(loss, 5);
baseThresholds = linspace(min(smoothed), max(smoothed), params.sdarNumberThresholds);

%% Combine adjacent spindles and eliminate items that are too short.
numThresholds = size(baseThresholds(:), 1);
spindles(numThresholds) = ...
    struct('baseThresholds', 0', 'numberSpindles', 0, 'spindleTime', 0, ...
          'spindleTimeRatio', 0, 'events', NaN, 'meanEventTime', 0);
               
for k = 1:numThresholds
   spindles(k) = spindles(end);
   spindles(k).baseThresholds = baseThresholds(k);
   eventCells =  applyThreshold(smoothed, EEG.srate, baseThresholds(k), 1/3);
   startEvents = cellfun(@double, eventCells(:, 2));
   endEvents = cellfun(@double, eventCells(:, 3));
   events = [startEvents(:), endEvents(:)];
   events = combineEvents(events, minLength, minSeparation);
   spindles(k).events = events;
    [spindles(k).numberSpindles, spindles(k).spindleTime, ...
        spindles(k).meanEventTime] = getSpindleCounts(events);
    spindles(k).spindleTimeRatio = spindles(k).spindleTime/totalTime;
end


