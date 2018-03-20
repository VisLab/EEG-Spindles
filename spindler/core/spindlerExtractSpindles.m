function [spindles, params, atomParams, scaledGabors] = ...
                                     spindlerExtractSpindles(data, params)
%% Calculate spindle events from different Gabor reconstructions 
%  
%  Parameters:
%    data             1 x n data
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

atomsPerSecond = params.spindlerAtomsPerSecond;
minLength = params.spindleLengthMin;
minSeparation = params.spindleSeparationMin;

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

%% Extract the channels and filter the signal before MP
numFrames = length(data);
totalTime = (numFrames - 1)/params.srate;
params.frames = numFrames;

%% Generate the Gabor dictionary for the MP decomposition
gabors = getGabors(params.srate, params);

%% Bandpass filter the data using pop_eegfiltnew
dataBand = getFilteredData(data, params);

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
numThresholds = size(baseThresholds(:), 1);
spindles(numAtoms*numThresholds) = ...
            struct('atomsPerSecond', 0, 'numberAtoms', 0, ...
                   'baseThreshold', 0', 'numberSpindles', 0, ...
                   'spindleTime', 0, 'spindleTimeRatio', 0, ...
                   'events', NaN);

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
        p = (j - 1)*numAtoms + k;
        spindles(p) = spindles(end);
        spindles(p).atomsPerSecond = atomsPerSecond(k);
        spindles(p).numberAtoms = theAtoms(k);
        spindles(p).baseThreshold = baseThresholds(j);
        events = spindlerDetectEvents(y, params.srate, ...
                baseThresholds(j), params.signalTrimFactor);
        events = combineEvents(events, minLength, minSeparation);
        spindles(p).events = events;
        [spindles(p).numberSpindles, spindles(p).spindleTime] = ...
                getSpindleCounts(events);
       
    end
end