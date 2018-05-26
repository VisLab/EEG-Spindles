function [spindles, params] = spindlerExtractSpindles(data, params)
%% Calculate Gabor representation and corresponding spindle events 
%  
%  Parameters:
%    data             1 x n data
%    params           (Input/Output) Structure with parameters for algorithm 
%                              (See getSpindleDefaults)
%    spindles         (Output) Structure with spindles as a function of 
%                              number of atoms/sec and threshold.
%    atomParams       (Output) Array of frequency, scale, and phase indices
%    sigmaFreq        (Output) Table of Gabor frequency and scales
%    scaledGabors     (Output) Gabor atoms that form the dictionary.
%
%  Written by:     J. LaRocco, K. Robbins, UTSA 2016-2017
%

%% Process the input parameters and set up the calculation
defaults = concatenateStructs(getGeneralDefaults(), spindlerGetDefaults());
params = processParameters('spindlerExtractSpindles', nargin, 2, params, defaults);

atomsPerSecond = sort(params.spindlerAtomsPerSecond);
params.spindlerAtomsPerSecond = atomsPerSecond;
minLength = params.spindleLengthMin;
minSeparation = params.spindleSeparationMin;
maxLength = params.spindleLengthMax;
%% Handle the thresholds (making sure thresholds 0 and 1 are included)
thresholds = params.spindlerThresholds;
thresholds = sort(thresholds);
if thresholds(1) ~= 0
    thresholds = [0, thresholds];
end
if thresholds(end) ~= 1
    thresholds = [thresholds, 1];
end
params.spindlerThresholds = thresholds;

%% Extract the channels and filter the signal before MP
numFrames = length(data);
totalTime = (numFrames - 1)/params.srate;
params.frames = numFrames;

%% Generate the Gabor dictionary for the MP decomposition
freqLow = params.spindleFrequencyRange(1);
freqHigh = params.spindleFrequencyRange(2);
freqRes = params.spindlerGaborFrequencyResolution;
params.spindlerGaborFrequencies = freqLow:freqRes:freqHigh;
[gabors, sigmaFreq] = getGabors(params.srate, ...
    params.spindlerGaborSupportFactor, params.spindlerGaborScales, ...
    params.spindlerGaborFrequencies);

%% Bandpass filter the data using pop_eegfiltnew
dataBand = getFilteredData(data, params.srate, ...
    params.spindlerGaborFrequencies(1), params.spindlerGaborFrequencies(end));

%% Reconstruct the signal using MP with a Gabor dictionary
theAtoms = round(atomsPerSecond*totalTime);
maxAtoms = max(theAtoms);
[~, atomParams, scaledGabors] = temporalMP(dataBand, gabors, false, maxAtoms);

%% Combine adjacent spindles and eliminate items that are too short.
padsize = size(scaledGabors, 1);
rgdelta  = 1:padsize;
rgdelta  = rgdelta - mean(rgdelta);
yp = zeros(1, 2*padsize + numFrames);
numAtoms = size(theAtoms(:), 1);
numThresholds = size(thresholds(:), 1);
spindles(numAtoms, numThresholds) = ...
    struct('atomsPerSecond', 0, 'numberAtoms', 0,  'threshold', 0, ...
           'numberSpindles', 0, 'spindleTime', 0, 'events', NaN);

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
    for j = 1:numThresholds
        spindles(k, j) = spindles(numAtoms, numThresholds);
        spindles(k, j).atomsPerSecond = atomsPerSecond(k);
        spindles(k, j).numberAtoms = theAtoms(k);
        spindles(k, j).baseThreshold = thresholds(j);
        events = spindlerDetectEvents(y, params.srate, ...
                thresholds(j), params.signalTrimFactor);
        events = combineEvents(events, minLength, minSeparation, maxLength);
        spindles(k, j).events = events;
        [spindles(k, j).numberSpindles, spindles(k, j).spindleTime] = ...
                getSpindleCounts(events);     
    end
end

params.atomParams = atomParams;
params.sigmaFreq = sigmaFreq;
params.scaledGabors = scaledGabors;