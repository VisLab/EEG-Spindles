dirName = 'E:\CTADATA\NCTU\Level0\01. NCTU lane-keeping task\session';
outDir = 'D:\TestData\Alpha\DrivingSpindles\NCTULK80_MinTime0p2';
theFiles = getFileList('FILES2', dirName);

%channelLabels = {'T5', 'P3', 'P4', 'Pz', 'T6'};
channelLabels = {'P3', 'P4', 'Pz'};
%channelNumbers = [20, 31, 57];
%channelNumbers = 20;
%channelNumbers = [25, 26];
freqBounds = [6, 14];
atomScales = [0.125, 0.25, 0.5];
freqInc = 1;
atomFrequencies = freqBounds(1):freqInc:freqBounds(2);
atomsPerSecond = 0.02:0.02:0.6;
baseThresholds = [0.0001, 0.001, 0.01, 0.02, 0.03, 0.04, 0.05, 0.1];
timeError = 0.1;
minLength = 0.25;
minTime = 0.20;
onsetTolerance = 0.3;
intersectTolerance = 0.2;
expertEvents = [];

%% Load the files
for k = 1:length(theFiles)
    EEG = pop_loadset(theFiles{k});
    [thePath, theName, theExt] = fileparts(theFiles{k});
    pieces = strsplit(theName, '_');
    session = pieces{6};
    subject = pieces{11};
    specificName = pieces{12};
    outFile = ['NCTUSession' session '_' subject '_' specificName '.mat'];
    theLabels = {EEG.chanlocs.labels};
    channelMask = false(1, length(EEG.chanlocs));
    for j = 1:length(channelLabels)
        channelMask = channelMask | strcmpi(theLabels, channelLabels{j});
    end
    channelNumbers = 1:length(theLabels);
    channelNumbers = channelNumbers(channelMask);
    [spindles, spindleRatios] = getSpindles(EEG, channelNumbers, atomsPerSecond, ...
               atomFrequencies, atomScales, baseThresholds, ...
               timeError, minLength, minTime, ...
               onsetTolerance, intersectTolerance, expertEvents);
  
    %% Save the results
    srate = EEG.srate;
    frames = size(EEG.data, 2);
    channelLabels = EEG.chanlocs(channelNumbers);
    channelLabels = {channelLabels.labels};
    if ~exist(outDir, 'dir')
       mkdir(outDir);
    end;
    save([outDir filesep outFile], 'spindles', 'spindleRatios', 'srate', ...
    'frames', 'channelNumbers', 'channelLabels', 'atomsPerSecond', ...
    'baseThresholds', 'atomFrequencies', 'atomScales', '-v7.3');
end