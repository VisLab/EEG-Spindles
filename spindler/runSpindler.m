%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

%% Setup the directories for input and output for driving data
dataDir = 'D:\TestData\Alpha\spindleData\BCIT\level0';
eventDir = 'D:\TestData\Alpha\spindleData\BCIT\events';
resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsSpindler';
imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesSpindler';
summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\BCIT_Spindler_Summary.mat';
channelLabels = {'PO7'};
paramsInit = struct();

%% Setup the directories for input and output for driving data
% dataDir = 'E:\CTADATA\BCIT\level_0';
% eventDir = '';
% resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsSpindlerNewAgain';
% imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesSpindlerNewAgain';
% channelLabels = {'PO3', 'H27'};
% paramsInit = struct();

% dataDir = 'D:\TestData\Alpha\spindleData\nctu\level0';
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsSpindler';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindler';
% channelLabels = {'P3'};
% paramsInit = struct();

% dataDir = 'D:\TestData\Alpha\spindleData\dreams\level0';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpindlerNew1';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindlerNew1';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% paramsInit.spindlerGaborFrequencies = 10:16;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;

%% Metrics to calculate
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
if ~isempty(resultsDir) && ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end;
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
paramsInit.figureClose = false;
paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};

%% Process the data
for k = 1:length(dataFiles)
    %% Load data file
    EEG = pop_loadset(dataFiles{k});
    [~, theName, ~] = fileparts(dataFiles{k});
 
    %% Calculate the spindle representations for a range of parameters
    [channelNumber, channelLabel] = getChannelNumber(EEG, channelLabels);
    if isempty(channelNumber)
        warning('%d: %s does not have the channel in question, cannot compute....', k, dataFiles{k});
        continue;
    end
    [spindles, params] = extractSpindles(EEG, channelNumber, paramsInit);
    params.name = theName;
    [spindlerCurves, warningMsgs] = getSpindlerCurves(spindles, imageDir, params);
     if spindlerCurves.bestLinearInd > 0
         events = spindles(spindlerCurves.bestLinearInd).events;
     end
    %% Deal with ground truth if available
    if isempty(eventFiles) || isempty(eventFiles{k}) || isempty(spindlerCurves)
        expertEvents = [];
        allMetrics = [];
        metrics = [];
    else
        expertEvents = readEvents(eventFiles{k});
        expertEvents = removeOverlapEvents(expertEvents, params.eventOverlapMethod);
        [allMetrics, params] = calculatePerformance(spindles, expertEvents, params);
        for n = 1:length(metricNames)
            showSpindlerMetric(spindlerCurves, allMetrics, metricNames{n}, ...
                       imageDir, params);
        end
        if spindlerCurves.bestLinearInd > 0
            metrics = allMetrics(spindlerCurves.bestLinearInd);
        end
    end
   
    additionalInfo.spindles = spindles;
    additionalInfo.spindlerCurves = spindlerCurves;
    additionalInfo.allMetrics = allMetrics;
    additionalInfo.warningMsgs = warningMsgs;
    %% Save the results
    [~, fileName, ~] = fileparts(dataFiles{k});
    save([resultsDir filesep fileName, '_spindlerResults.mat'], 'events', ...
        'expertEvents', 'metrics', 'params', 'additionalInfo', '-v7.3');
end

%% Now consolidate the events for the collection and create a summary
[results, dataNames, upperBounds] = consolidateResults(resultsDir, methodNames, metricNames);
save(summaryFile, 'results', 'dataNames', 'methodNames', ...
    'metricNames', 'upperBounds', '-v7.3');
