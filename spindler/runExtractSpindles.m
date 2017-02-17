dirName = 'D:\Research\AlphaCharacterization\NewVersion\originalDrivingData';
outDir = 'D:\TestData\Alpha\DrivingSpindles\BCITSupervised';

EEGFile = 'S1015.set';
eventFile = 'S1015_labels.mat';
outFile = 'S1015SpindlesGroupNewG.mat';

% EEGFile = 'S1010.set';
% eventFile = 'S1010_labels.mat';
% outFile = 'S1010SpindlesGroupNewG.mat';
%outFile = 'S1010SpindlesGroupNewC.mat';
%channelNumbers = [20, 31, 57];
%channelNumbers = 20;
%channelNumbers = [25, 26];
channelNumbers = [25];
freqBounds = [6, 14];
atomScales = [0.125, 0.25, 0.5];
atomsPerSecond = 0.02:0.02:0.6;
baseThresholds = [0.0001, 0.001, 0.01, 0.02, 0.03, 0.04, 0.05, 0.1];
freqInc = 1;
atomFrequencies = freqBounds(1):freqInc:freqBounds(2);
timeError = 0.1;
minLength = 0.25;
minTime = 0.25;
onsetTolerance = 0.3;
intersectTolerance = 0.2;

%% Load the files
EEG = pop_loadset([dirName filesep EEGFile]);
load([dirName filesep eventFile]);
expertEvents = expert_events;

%% Reconstruct signal
[events, spindles] = getSpindles(EEG, channelNumbers, atomsPerSecond, ...
               atomFrequencies, atomScales, baseThresholds, ...
               timeError, minLength, minTime, ...
               onsetTolerance, intersectTolerance, expertEvents);

%% Save the results
srate = EEG.srate;
frames = size(EEG.data, 2);
channelLabels = EEG.chanlocs(channelNumbers);
channelLabels = {channelLabels.labels};
save([outDir filesep outFile], 'events', 'spindles', 'srate', ...
    'frames', 'channelNumbers', 'channelLabels', 'atomsPerSecond', ...
    'baseThresholds', 'atomFrequencies', 'atomScales', '-v7.3');