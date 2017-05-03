%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

%% Setup the directories for input and output for driving data
% dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
% eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
% splitFileDir = 'D:\TestData\Alpha\spindleData\bcit\splitData';

%% NCTU
dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
splitFileDir = 'D:\TestData\Alpha\spindleData\nctu\splitData';

%% Dreams
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
% splitFileDir = 'D:\TestData\Alpha\spindleData\dreams\splitData';

%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES', dataDir, '.set');
if isempty(eventDir)
    error('Must have ground truth to split the EEG');
else
    eFiles = getFiles('FILES', eventDir, '.mat');
    [eventFiles, leftOvers] = matchFileNames(dataFiles, eFiles);
    if ~isempty(leftOvers)
        warning('%d event files were not matched with data files', length(leftOvers));
        for k = 1:length(leftOvers)
            fprintf('---%s\n', leftOvers{k});
        end
    end
    for k = 1:length(eventFiles)
        if isempty(eventFiles{k})
            warning('Data file %s does not have expert events', dataFiles{k});
        end
    end
end

%% Create the output directory if it doesn't exist
if ~exist(splitFileDir, 'dir')
    mkdir(splitFileDir);
end;

%% Process the data
for k = 1:length(dataFiles)
    %% Load data file
    fprintf('%d: %s ....\n', k, dataFiles{k});
    if isempty(eventFiles{k})
        warning('Data file %s does not have expert events, skipping...', dataFiles{k});
        continue;
    end
   
    expertEvents = readEvents(eventFiles{k});
    if isempty(expertEvents)
        warning('No spindles detected by experts for %s, skipping...', dataFiles{k});
    end
    
    params = processParameters('runSplitEEG', 0, 0, struct(), getGeneralDefaults());     
    expertEvents = removeOverlapEvents(expertEvents, params.eventOverlapMethod);
    
    %% Read in the EEG and find the correct channel number
    EEG = pop_loadset(dataFiles{k});
    [~, theName, ~] = fileparts(dataFiles{k});
    params.name = theName;
    
    %% Split the files into training and test portions
    totalFrames = size(EEG.data, 2);
    srate = EEG.srate;
    [expertEvents1, expertEvents2, frameSplitFirst, frameSplitLast] = ...
        splitEvents(expertEvents, srate, params);
    EEG1 = splitEEG(EEG, 1, frameSplitFirst);
    EEG2 = splitEEG(EEG, frameSplitLast, totalFrames);
    expertEvents2 = expertEvents2 - frameSplitLast/srate;
    fprintf('%d: %d events first part and %d events second\n', k, ...
        size(expertEvents1, 1), size(expertEvents1, 1));
    save([splitFileDir filesep theName '.mat'], 'EEG1', 'EEG2', ...
        'expertEvents1', 'expertEvents2', 'params', '-v7.3');
end