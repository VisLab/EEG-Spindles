function [spindles, params, atomParams, scaledGabors] = ...
                 extractSpindles(EEG, channelNumbers, expertEvents, params)
%% Calculate spindle events from different Gabor reconstructions 
%  
%  Parameters:
%    EEG              Input EEG structure (EEGLAB format)
%    channelNumbers   Vector of channel numbers to analyze
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
params = processSpindleParameters('extractEvents', nargin, 3, params);
params.srate = EEG.srate;
params.frames = size(EEG.data, 2);
params.channelNumbers = channelNumbers;
channelLabels = EEG.chanlocs(channelNumbers);
params.channelLabels = {channelLabels.labels};
if isempty(channelNumbers)
    error('extractSpindles:NoChannels', 'Channels must be non-empty');
elseif isempty(expertEvents)
    doPerformance = false;
else
    doPerformance = true;
    expertEvents = ...
        removeOverlapEvents(expertEvents, params.spindleOverlapMethod);
end  
atomsPerSecond = params.spindleAtomsPerSecond;
baseThresholds = params.spindleBaseThresholds;
minLength = params.spindleMinLength;
minSeparation = params.spindleMinSeparation;

%% Extract the channels and filter the EEG signal before MP
[numChans, numFrames] = size(EEG.data);
if max(channelNumbers) > numChans
    error('extractSpindles:BadChannel', 'The EEG does not have channels needed');
end
srate = EEG.srate;
EEG.data = EEG.data(channelNumbers, :);
numChans = size(channelNumbers(:), 1);
EEG.nbchan = numChans;
totalTime = (numFrames - 1)/EEG.srate;
maxVoteChannels = round(params.spindleMaxVoteChannels);
if numChans > maxVoteChannels
    voteWeight = 1/maxVoteChannels;
else
    voteWeight = 1/numChans;   
end

%% Generate the Gabor dictionary for the MP decomposition
[gabors, sigmaFreq] = getGabors(EEG.srate, params);

%% Bandpass filter the EEG
lowFreq = max(1, min(sigmaFreq(:, 2)));
highFreq = min(ceil(EEG.srate/2.1), max(sigmaFreq(:, 2)));
EEGFilt = pop_eegfiltnew(EEG, lowFreq, highFreq);

%% Reconstruct the signal using MP with a Gabor dictionary
theAtoms = round(atomsPerSecond*totalTime);
maxAtoms = max(theAtoms);
atomParams = zeros(numChans, maxAtoms, 3);
R2Values = zeros(numChans, maxAtoms);
for k = 1:numChans
    [~, atomParams(k, :, :), scaledGabors, R2Values(k, :)] = ...
        temporalMP(squeeze(EEGFilt.data(k, :)), gabors, false, maxAtoms); 
end

%% Combine adjacent spindles and eliminate items that are too short.
padsize = size(scaledGabors, 1);
rgdelta  = 1:padsize;
rgdelta  = rgdelta - mean(rgdelta);
yp = zeros(numChans, 2*padsize + numFrames);
numAtoms = size(theAtoms(:), 1);
numThresholds = size(baseThresholds(:), 1);
if doPerformance
   spindles(numAtoms*numThresholds) = ...
            struct('atomsPerSecond', 0, 'numberAtoms', 0, ...
                   'baseThreshold', 0', 'numberSpindles', 0, ...
                   'spindleTime', 0, 'spindleTimeRatio', 0, ...
                   'events', NaN, 'meanEventTime', 0, ...
                   'r2', 0, 'eFraction', 0, ...
                   'metricsTimes', NaN, 'metricsHits', NaN, ...
                   'metricsOnsets', NaN, 'metricsIntersects', NaN);
else
   spindles(numAtoms*numThresholds) = ...
             struct('atomsPerSecond', 0, 'numberAtoms', 0, ...
                   'baseThreshold', 0', 'numberSpindles', 0, ...
                   'spindleTime', 0, 'spindleTimeRatio', 0, ...
                   'events', NaN, 'meanEventTime', 0, ...
                   'r2', 0, 'eFraction', 0);
end
atomsPerSecond = sort(atomsPerSecond);
currentAtom = 1;
for k = 1:numAtoms
    for m = currentAtom:theAtoms(k)
        for n = 1:numChans        
            theFrames = atomParams(n, m, 2) + rgdelta;
            yp(n, theFrames) = yp(n, theFrames) + ...
                atomParams(n, m, 3)*scaledGabors(:, atomParams(n, m, 1))';
        end
    end
    currentAtom = theAtoms(k) + 1;
    y = yp(:, padsize + 1:end-padsize);
    r2 = R2Values(:, theAtoms(k));
    for j = 1:numThresholds
        p = (j - 1)*numAtoms + k;
        spindles(p) = spindles(end);
        spindles(p).r2 = r2;
        spindles(p).atomsPerSecond = atomsPerSecond(k);
        spindles(p).numberAtoms = theAtoms(k);
        spindles(p).baseThreshold = baseThresholds(j);
        events = detectEvents(y, srate, baseThresholds(j), voteWeight);
        events = combineEvents(events, minLength, minSeparation);
        yPower = zeros(numChans, 1);
        sPower = zeros(numChans, 1);
        numLabelledEvents = size(events, 1);
        for m = 1:numLabelledEvents
            startFrame = round(events(m, 1)*srate + 1);
            endFrame = round(events(m, 2)*srate + 1);
            yData = y(:, startFrame:endFrame);
            sData = EEG.data(:, startFrame:endFrame);
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
        if doPerformance
            %% Compute hit metrics
            hitConfusion = getConfusionHits(expertEvents, events, totalTime);
            spindles(p).metricsHits = getPerformanceMetrics(hitConfusion.tp,  ...
                hitConfusion.tn, hitConfusion.fp, hitConfusion.fn);
            %% Compute onset metrics
            onsetConfusion = ...
                getConfusionOnsets(expertEvents, events, totalTime, params);
            spindles(p).metricsOnsets = getPerformanceMetrics( ...
                onsetConfusion.tp, onsetConfusion.tn, onsetConfusion.fp, ...
                onsetConfusion.fn);
            
            %% Compute timing metrics
            timeConfusion = getConfusionTimes(expertEvents, events, ...
                numFrames, srate, params);
            spindles(p).metricsTimes = getPerformanceMetrics(timeConfusion.tp,...
                timeConfusion.tn, timeConfusion.fp, timeConfusion.fn);
            
            %% Compute intersection metrics
            intersectConfusion = ...
                getConfusionIntersects(expertEvents, events, totalTime, params);     
            spindles(p).metricsIntersects = getPerformanceMetrics( ...
                   intersectConfusion.tp, intersectConfusion.tn, ...
                   intersectConfusion.fp, intersectConfusion.fn);      
        end
    end
end

