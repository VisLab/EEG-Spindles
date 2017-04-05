%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

%% Setup the directories for input and output for driving data
dataDir = 'D:\TestData\Alpha\spindleData\BCIT\level0';
eventDir = 'D:\TestData\Alpha\spindleData\BCIT\events';
resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsSpindler';
imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesSpindler';
channelLabels = {'PO7'};
paramsInit = struct();

% dataDir = 'D:\TestData\Alpha\spindleData\nctu\level0';
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsSpindler';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindler';
% channelLabels = {'P3'};
% paramsInit = struct();

% dataDir = 'D:\TestData\Alpha\spindleData\dreams\level0';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpindler';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindler';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% paramsInit.gaborFrequencies = 10:16;
% paramsInit.spindleOnsetTolerance = 0.3;
% paramsInit.spindleTimingTolerance = 0.1;

%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES', dataDir, '.set');
if isempty(eventDir)
    eventFiles = {};
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

%% Create the output file if it doesn't exist
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end;

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end;

%% Process the data
for k = 1%:length(dataFiles)
    %% Load data file
    EEG = pop_loadset(dataFiles{k});
    [~, theName, ~] = fileparts(dataFiles{k});
    %% Load the event file
    if isempty(eventFiles{k})
        expertEvents = [];
        metrics = [];
    else
        expertEvents = readEvents(eventFiles{k});
    end
    
    %% Calculate the spindle representations for a range of parameters
    [channelNumber, channelLabel] = getChannelNumber(EEG, channelLabels);
    [spindles, params] = extractSpindles(EEG, channelNumber, paramsInit);
    totalSeconds = params.frames./params.srate;
    spindlerParameters = ...
        getSpindlerParameters(spindles, totalSeconds, theName, imageDir);
     if ~isempty(eventDir)
        [metrics, expertEvents, params] = ...
                 getSpindlerPerformance(spindles, expertEvents, params);
     end
    %% Save the results
    [~, fileName, ~] = fileparts(dataFiles{k});
    save([resultsDir filesep fileName, '_spindlerResults.mat'], ...
        'spindles', 'metrics', 'params', 'spindlerParameters', '-v7.3');
end