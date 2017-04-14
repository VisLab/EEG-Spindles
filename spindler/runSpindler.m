%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

% %% Setup the directories for input and output for driving data
% dataDir = 'D:\TestData\Alpha\spindleData\BCIT\level0';
% eventDir = 'D:\TestData\Alpha\spindleData\BCIT\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsSpindlerT1';
% imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesSpindlerT1';
% channelLabels = {'PO7'};
% paramsInit = struct();

%% Setup the directories for input and output for driving data
dataDir = 'E:\CTADATA\BCIT\level_0';
eventDir = '';
resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsSpindlerAll';
imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesSpindlerAll';
channelLabels = {'PO3', 'H27'};
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
% paramsInit.spindlerGaborFrequencies = 10:16;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;

%% Metrics to calculate
metricNames = {'f1', 'f2', 'G'};

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

%% Create the output directory if it doesn't exist
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end;

%paramsInit.figureClose = false;
%paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};

%% Process the data
for k = 1:length(dataFiles)
    %% Load data file
    EEG = pop_loadset(dataFiles{k});
    [~, theName, ~] = fileparts(dataFiles{k});
    %% Load the event file
    if isempty(eventFiles) || isemtpy(eventFiles{k})
        expertEvents = [];
        metrics = [];
    else
        expertEvents = readEvents(eventFiles{k});
    end
    
    %% Calculate the spindle representations for a range of parameters
    [channelNumber, channelLabel] = getChannelNumber(EEG, channelLabels);
    if isempty(channelNumber)
        warning('%d: %s does not have the channel in question, cannot compute....', k, dataFiles{k});
        continue;
    end
    [spindles, params] = extractSpindles(EEG, channelNumber, paramsInit);
    params.name = theName;
    spindlerCurves = getSpindlerCurves(spindles, imageDir, params);
     if ~isempty(eventDir)
        [metrics, expertEvents, params] = ...
                 getSpindlerPerformance(spindles, expertEvents, params);
        for n = 1:length(metricNames)
            showSpindlerMetric(spindlerCurves, metrics, metricNames{n}, ...
                       imageDir, params);
        end
     end
     
    %% Save the results
    [~, fileName, ~] = fileparts(dataFiles{k});
    save([resultsDir filesep fileName, '_spindlerResults.mat'], ...
        'spindles', 'metrics', 'params', 'spindlerCurves', '-v7.3');
end