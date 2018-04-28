%% This script creates a dataSplit directory with a specified number of splits
%  This is useful for cross validation or for supervised learning.

%% Setup the directories for input and output for driving data
dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
eventDirs = {'D:\TestData\Alpha\spindleData\bcit\events'};
splitDir = 'D:\TestData\Alpha\spindleData\bcit\dataSplit';
numSplits = 1;

%% NCTU
% dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% splitFileDir = 'D:\TestData\Alpha\spindleData\nctu\splitData';

%% Dreams
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
% splitFileDir = 'D:\TestData\Alpha\spindleData\dreams\splitData';

%% Get the data and event file names and check that we have the same number
EEGFiles = getFiles('FILES', dataDir, '.set');
numFiles = length(EEGFiles);

%% Create the output directory if it doesn't exist
if ~exist(splitDir, 'dir')
    mkdir(splitDir);
end

%% Process the data
numExperts = length(eventDirs);
for k = 1:numFiles
    %% Load the EEG files
    fprintf('%d: %s ....\n', k, EEGFiles{k});
    EEG = pop_loadset(EEGFiles{k});
    [~, theName, ~] = fileparts(EEGFiles{k});
    EEG.setname = theName;
    %% Get the split times
    totalTime = (size(EEG.data, 2) - 1)./EEG.srate;
    splitTimes = getSplitTimes(totalTime, numSplits);
    numPieces = size(splitTimes, 1);
    %% Split the EEG
    splitEEG = getSplitEEG(EEG, splitTimes);
    
    %% Split the events
    splitEvents = cell(numPieces, numExperts);
    for n = 1:numExperts
        eventFile = [eventDirs{n} filesep theName '.mat'];
        if ~exist(eventFile, 'file')
            warning('Event file %s does not exist...', eventFile);
            continue;
        end
        splitEvents(:, n) = getSplitEvents(eventFile, splitTimes);
    end
    save([splitDir filesep theName '.mat'], 'splitEEG', 'splitEvents', ...
        'splitTimes', '-v7.3');
end