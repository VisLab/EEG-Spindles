function [events, spindles]=newSDAR(EEG, params, expertEvents)
% Last updated: April 2016, J. LaRocco, K. Robbins

% Details: SDAR wrapper.

% Usage:
% [events, spindles] =newWarby(EEG, channelNumbers, atomFrequencies, algo, expertEvents)

% [events, spindles] =newWarby(EEG, channelNumbers, atomFrequencies, algo)
%
%  EEG:            Input EEG structure (EEGLAB format)
%  channelList:    Vector of channel numbers to analyze
%  freqBounds:     Frequency boundry to restrict reconstruction to. (1x2 vector with positive integers, e.g.,[6 14])
%  expertEvents:   Struct with expert-rated times and durations for spindles (scalar or vector of positive integers).
%
% Output:
%  events:         Matrix of detected events, with first column as start
%                  time and second as end time (both in seconds).
%  spindles:       Struct containing info, and if relevant, performance.

%--------------------------------------------------------------------------
%% Parameters
timeError = params.timeError;
minLength = params.minLength;
minTime = params.minTime;


channelNumbers=params.channelList;
atomFrequencies=params.atomFrequencies;

%% Should we calculate performance.
if nargin == 3
    doPerformance = true;
else
    doPerformance = false;
end
%% Reconstruct signal
lowFreq = max(1, min(atomFrequencies));
highFreq = min(ceil(EEG.srate/2.1), max(atomFrequencies));
% EEG = pop_eegfiltnew(EEG, 1, ceil(EEG.srate/2.1));
EEG = pop_eegfiltnew(EEG, lowFreq, highFreq);

%% Combine adjacent spindles and eliminate items that are too short.

spindles(1) = struct('numberSpindles', NaN, 'spindleTime', NaN, ...
    'metricsTime', NaN, 'metricsHits', NaN);

k=1;
[events1]=detectorSDAR(EEG,channelNumbers,expertEvents);

events = combineEvents(events1, minLength, minTime);

%parameters
spindles(k).params.srate=EEG.srate;
spindles(k).params.frames=EEG.pnts;
spindles(k).params.freqRange=[lowFreq, highFreq];
spindles(k).params.channelNumbers=channelNumbers;
theLabels = {EEG.chanlocs.labels};
for kk=1:length(channelNumbers);
    labels{kk}=theLabels{kk};
end
spindles(k).params.labels=labels;


[spindles(k).numberSpindles, spindles(k).spindleTime] = getSpindleCounts(events);
if doPerformance
    [~, ~, timeInfo] = evaluateTimingErrors(EEG, expertEvents, events, ...
        timeError, EEG.srate);
    
    spindles(k).metricsTime = getPerformanceMetrics(timeInfo.agreement,...
        timeInfo.nullAgreement,timeInfo.falsePositive,timeInfo.falseNegative);
    hitInfo = evaluateHits(expertEvents, events);
    spindles(k).metricsHits = getPerformanceMetrics(hitInfo.tp, hitInfo.tn, ...
        hitInfo.fp, hitInfo.fn);
    
    onsetTolerance = 0.3;
    intersectTolerance = 0.2;
    onsetInfo = evaluateOnsets(expertEvents, events, onsetTolerance);
    onsetInfo.tn = (EEG.pnts/EEG.srate)-(onsetInfo.fp+onsetInfo.tp+onsetInfo.fn);
    spindles(k).metricsOnsets = getPerformanceMetrics( ...
        onsetInfo.tp, onsetInfo.tn, onsetInfo.fp, onsetInfo.fn);
    interInfo = evaluateIntersectHits(expertEvents, ...
        events, intersectTolerance);
    dataTime = size(EEG.data, 2)/EEG.srate;
    reverseTrue = reverseEvents(expertEvents, dataTime);
    reverseLabeled = reverseEvents(events, dataTime);
    interInfoReverse = evaluateIntersectHits(reverseTrue, ...
        reverseLabeled, intersectTolerance);
    
    interInfo.tn = interInfoReverse.tp;
    spindles(k).metricsInter = getPerformanceMetrics( ...
        interInfo.tp, interInfo.tn, interInfo.fp, interInfo.fn);
    
    spindles(k).f1ModOnsets = spindles(k).metricsOnsets.f1Mod;
    spindles(k).f1ModInter = spindles(k).metricsInter.f1Mod;
    
end

end
