%% This script creates a split dataset for training and testing Mass
%
EEGDir = 'D:\TestData\Alpha\spindleData\mass\data';
stage2Dir = 'D:\TestData\Alpha\spindleData\mass\annotations\stage2Events';
expertDirs = {'D:\TestData\Alpha\spindleData\mass\events\spindlesE1'; ...
              'D:\TestData\Alpha\spindleData\mass\events\spindlesE2'};
splitDir  = 'D:\TestData\Alpha\spindleData\mass\dataSplit';
numExperts = length(expertDirs);
numSplits = 2;  % Take the longest n events for mass

%% Create the output directory if it doesn't exist
if ~exist(splitDir, 'dir')
    mkdir(splitDir);
end;

%% Get the EEG file names
EEGFiles = getFiles('FILES', EEGDir, '.set');
numFiles = length(EEGFiles);

%% Process the files

for k = 1:numFiles
    %% Load the EEG file
    splitEEG = cell(numSplits, 1);
    splitEvents = cell(numSplits, numExperts);
    splitTimes = zeros(numSplits, 2);
    EEG = pop_loadset(EEGFiles{k});
    [~, theName, theExt] = fileparts(EEGFiles{k});
    baseFile = [stage2Dir filesep theName(1:11) 'Base.mat'];
    if ~exist(baseFile, 'file')
        warning('%s does not exist', baseFile);
        continue;
    end
    numFrames = size(EEG.data, 2);
    srate = EEG.srate;
 
    %% Load the sleep stage 2 information and find largest two segments
    base = load(baseFile);
    stageEvents = base.stageEvents;
    stageDurations = stageEvents(:, 2) - stageEvents(:, 1);
    [~, sortedIndices] = sort(stageDurations, 'descend');
    
    %% Perform the split
    for m = 1:numSplits
        splitTimes(m, 1) = stageEvents(sortedIndices(m), 1);
        splitTimes(m, 2) = stageEvents(sortedIndices(m), 2);
        splitEEG{m} = getSplitEEG(EEG, splitTimes(m, 1), splitTimes(m, 2));
        for n = 1:numExperts
            expertFile = [expertDirs{n} filesep theName '.mat'];
            splitEvents{m, n} = ...
                readEvents(expertFile, splitTimes(m, 1), splitTimes(m, 2)); 
        end
    end
    save([splitDir filesep theName '.mat'], 'splitEEG', 'splitEvents', ...
        'splitTimes', '-v7.3');
end    