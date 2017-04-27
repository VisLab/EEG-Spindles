%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

%% Setup the directories for input and output for driving data
dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
resultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSpindler';
imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindler';
summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_Spindler_Summary.mat';
channelLabels = {'PO7'};
paramsInit = struct();

%% Setup the directories for input and output for driving data
% dataDir = 'E:\CTADATA\BCIT\level_0';
% eventDir = '';
% resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsSpindlerNewAgain';
% imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesSpindlerNewAgain';
% channelLabels = {'PO3', 'H27'};
% paramsInit = struct();

%% NCTU
% dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsSpindler';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindler';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\nctu_Spindler_Summary.mat';
% channelLabels = {'P3'};
% paramsInit = struct();

%% Dreams
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpindler';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindler';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreams_Spindler_Summary.mat';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% paramsInit.spindlerGaborFrequencies = 10:16;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;

%% Metrics to calculate and methods to use
metricNames = {'f1', 'f2', 'G'};
methodNames = {'hitMetrics', 'intersectMetrics', 'onsetMetrics', 'timeMetrics'};

%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES', dataDir, '.set');
if isempty(eventDir)
    error('Must have ground truth to run Spindler in supervised mode');
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
%paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};

%% Process the data
for k = 1%:length(dataFiles)
    %% Load data file
    if isempty(eventFiles{k})
        warning('Data file %s does not have expert events, skipping...', dataFiles{k});
        continue;
    end
    defaults = concatenateStructs(getGeneralDefaults(), tsanasGetDefaults());
    params = processParameters('runSpindlerSupervised', 0, 0, paramsInit, defaults);     
    expertEvents = readEvents(eventFiles{k});
    expertEvents = removeOverlapEvents(expertEvents, params.eventOverlapMethod);
    if isempty(expertEvents)
        warning('No spindles detected by experts for %s, skipping...', dataFiles{k});
    end
    
    %% Read in the EEG and find the correct channel number
    EEG = pop_loadset(dataFiles{k});
    [~, theName, ~] = fileparts(dataFiles{k});
    params.name = theName;
    [channelNumber, channelLabel] = getChannelNumber(EEG, channelLabels);
    if isempty(channelNumber)
        warning('%d: %s does not have the channel in question, cannot compute....', k, dataFiles{k});
        continue;
    end
    
    %% Split the files into training and test portions
    [expertEvents1, expertEvents2, frameSplitPoint] = splitEvents(expertEvents, params);
    [EEG1, EEG2] = splitEEG(EEG, frameSplitPoint);
    
    %% Find the spindle curves for each part
    [spindles1, params] = spindlerExtractSpindles(EEG1, channelNumber, params);
    [spindles2, params] = spindlerExtractSpindles(EEG2, channelNumber, params);
    
    %% Get the metrics for each part
    params1 = params;
    params1.theName = [params.theName '_firstPart'];
    [spindlerCurves1, warningMsgs1] = spindlerGetParameterCurves(spindles1, imageDir, params1);
    [allMetrics1, params1] = calculatePerformance(spindles1, events1, params1);
    params2 = params;
    params2.theName = [params.theName '_lastPart'];
    [spindlerCurves2, warningMsgs2] = spindlerGetParameterCurves(spindles2, imageDir, params2);
    [allMetrics2, params2] = calculatePerformance(spindles1, events2, params2);
    
        for n = 1:length(metricNames)
            spindlerShowMetric(spindlerCurves, allMetrics, metricNames{n}, ...
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
