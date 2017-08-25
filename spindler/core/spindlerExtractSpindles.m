function [spindles, params, atomParams, scaledGabors] = ...
                      spindlerExtractSpindles(EEG, channelNumber, params)
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
defaults = concatenateStructs(getGeneralDefaults(), spindlerGetDefaults());
params = processParameters('extractSpindles', nargin, 2, params, defaults);

params.channelNumber = channelNumber;
params.channelLabel = EEG.chanlocs(channelNumber).labels;
if isempty(channelNumber)
    error('extractSpindles:NoChannels', 'Must have non-empty');
end  
atomsPerSecond = params.spindlerAtomsPerSecond;
minLength = params.minSpindleLength;
minSeparation = params.minSpindleSeparation;

%% Handle the baseThresholds (making sure thresholds 0 and 1 are included)
baseThresholds = params.spindlerBaseThresholds;
baseThresholds = sort(baseThresholds);
if baseThresholds(1) ~= 0
    baseThresholds = [0, baseThresholds];
end
if baseThresholds(end) ~= 1
    baseThresholds = [baseThresholds, 1];
end
params.spindlerBaseThresholds = baseThresholds;

%% Extract the channels and filter the EEG signal before MP
if channelNumber > size(EEG.data, 1)
    error('spindlerExtractSpindles:BadChannel', 'The EEG does not have channel needed');
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

%% Generate the Gabor dictionary for the MP decomposition
[gabors, sigmaFreq] = getGabors(srate, params);

%% Bandpass filter the EEG
lowFreq = max(1, min(sigmaFreq(:, 2)));
highFreq = min(ceil(EEG.srate/2.1), max(sigmaFreq(:, 2)));
EEGFilt = pop_eegfiltnew(EEG, lowFreq, highFreq);
baseFreq = params.spindlerBaseFrequencies;
if max(baseFreq) >= EEG.srate/2
    EEGBase = pop_eegfiltnew(EEG, baseFreq(1));
else
    EEGBase = pop_eegfiltnew(EEG, baseFreq(1), baseFreq(2));
end

%% Reconstruct the signal using MP with a Gabor dictionary
theAtoms = round(atomsPerSecond*totalTime);
maxAtoms = max(theAtoms);
[~, atomParams, scaledGabors, R2Values] = ...
    temporalMP(EEGFilt.data, gabors, false, maxAtoms);

%% Combine adjacent spindles and eliminate items that are too short.
padsize = size(scaledGabors, 1);
rgdelta  = 1:padsize;
rgdelta  = rgdelta - mean(rgdelta);
yp = zeros(1, 2*padsize + numFrames);
numAtoms = size(theAtoms(:), 1);
numThresholds = size(baseThresholds(:), 1);
spindles(numAtoms*numThresholds) = ...
            struct('atomsPerSecond', 0, 'numberAtoms', 0, ...
                   'baseThreshold', 0', 'numberSpindles', 0, ...
                   'spindleTime', 0, 'spindleTimeRatio', 0, ...
                   'events', NaN, 'meanEventTime', 0, ...
                   'eventTime25Per', NaN, 'eventTime50Per', NaN, ...
                   'eventTime75Per', NaN, 'r2', 0, 'eFraction', 0);

atomsPerSecond = sort(atomsPerSecond);
currentAtom = 1;
for k = 1:numAtoms
    for m = currentAtom:theAtoms(k)  
            theFrames = atomParams(m, 2) + rgdelta;
            yp(theFrames) = yp(theFrames) + ...
                atomParams(m, 3)*scaledGabors(:, atomParams(m, 1))';
    end
    currentAtom = theAtoms(k) + 1;
    y = yp(padsize + 1:end-padsize);
    r2 = R2Values(theAtoms(k));
    for j = 1:numThresholds
        p = (j - 1)*numAtoms + k;
        spindles(p) = spindles(end);
        spindles(p).r2 = r2;
        spindles(p).atomsPerSecond = atomsPerSecond(k);
        spindles(p).numberAtoms = theAtoms(k);
        spindles(p).baseThreshold = baseThresholds(j);
        events = spindlerDetectEvents(y, srate, baseThresholds(j), params.signalTrimFactor);
        events = combineEvents(events, minLength, minSeparation);
        yPower = 0;
        sPower = 0;
        numLabelledEvents = size(events, 1);
        for m = 1:numLabelledEvents
            startFrame = round(events(m, 1)*srate + 1);
            endFrame = round(events(m, 2)*srate + 1);
            yData = EEGFilt.data(startFrame:endFrame);
            sData = EEGBase.data(startFrame:endFrame);
            yPower = yPower + sum(yData.*yData, 2);
            sPower = sPower + sum(sData.*sData, 2);
        end
        if sPower > 0
            spindles(p).eFraction = yPower./sPower;
        end
        spindles(p).events = events;
        [spindles(p).numberSpindles, spindles(p).spindleTime, ...
            spindles(p).meanEventTime] = getSpindleCounts(events);
        spindles(p).spindleTimeRatio = spindles(p).spindleTime/totalTime;
        if ~isempty(events)
            ptimes = prctile(events(:, 2) - events(:, 1), [25, 50, 75]);
            spindles(p).eventTime25Per = ptimes(1);
            spindles(p).eventTime50Per = ptimes(2);
            spindles(p).eventTime75Per = ptimes(3);
        end
    end
end