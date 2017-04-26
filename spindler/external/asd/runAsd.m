%% Set up the directory
% dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
% eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsAsd';
% imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesAsd';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_Asd_Summary.mat';
% channelLabels = {'PO7'};
% paramsInit = struct();
%paramsInit.AsdVisualize = true;

%% NCTU setup
dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
resultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsAsd';
imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesAsd';
summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\nctu_Asd_Summary.mat';
channelLabels = {'P3'};
paramsInit = struct();

%% Dreams setup
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsAsd';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesAsd';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreams_Asd_Summary.mat';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% paramsInit.AsdPeakFrequencyRange = 10:16;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;

%% Metrics to calculate and methods to use
metricNames = {'f1', 'f2', 'G'};
methodNames = {'hitMetrics', 'intersectMetrics', 'onsetMetrics', 'timeMetrics'};

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

paramsInit.figureClose = false;
paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};
badMask = false(length(dataFiles), 1);


%% Process the data
for k = 1:length(dataFiles)
    %% Load data file
    EEG = pop_loadset(dataFiles{k});
    [~, theName, ~] = fileparts(dataFiles{k});
    %% Load the event file
    if isempty(eventFiles) || isempty(eventFiles{k})
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
    paramsInit.AsdImagePathPrefix = ...
        [imageDir filesep theName '_Ch_' num2str(channelLabel)];
    [events, params, additionalInfo] = ...
                      asdExtractSpindles(EEG, channelNumber, paramsInit);
    params.name = theName;
    frames = params.frames;
    %% Deal with ground truth if available
    if isempty(eventFiles) || isempty(eventFiles{k})
        expertEvents = [];
        metrics = [];
    else
        metrics = struct('hitMetrics', NaN, 'intersectMetrics', NaN, ...
            'onsetMetrics', NaN, 'timeMetrics', NaN);
        expertEvents = readEvents(eventFiles{k});
        expertEvents = removeOverlapEvents(expertEvents, params.eventOverlapMethod);
        [metrics.hitMetrics, metrics.intersectMetrics, ...
            metrics.onsetMetrics, metrics.timeMetrics] = ...
            getPerformanceMetrics(expertEvents, events, params.frames, ...
            params.srate, params);
    end
    [~, theName, ~] = fileparts(dataFiles{k});
    
    %% Save the results
    [~, fileName, ~] = fileparts(dataFiles{k});
    save([resultsDir filesep fileName, '_asdResults.mat'], 'events', ...
        'expertEvents', 'metrics', 'params', 'additionalInfo', '-v7.3');
    
end

%% Now consolidate the events for the collection and create a summary
[results, dataNames, upperBounds] = consolidateResults(resultsDir, methodNames, metricNames);
save(summaryFile, 'results', 'dataNames', 'methodNames', 'metricNames', ...
    'upperBounds', '-v7.3');
