%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

%% Setup the directories for input and output for driving data
splitFileDir = 'D:\TestData\Alpha\spindleData\bcit\splitData';
supervisedResultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSupervisedSpindler';
imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSupervisedSpindler';
%summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_Spindler_Summary.mat';
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
dataFiles = getFiles('FILES', splitFileDir, '.mat');

%% Create the output directory if it doesn't exist
if ~exist(supervisedResultsDir, 'dir')
    mkdir(supervisedResultsDir);
end;
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
paramsInit.figureClose = false;
%paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};

%% Process the data
for k = 1%:length(dataFiles)
    %% Load data split files and process the parameters
    splitData = load(dataFiles{k});
    params = processParameters('runSpindlerSupervised', 0, 0, splitData.params, spindlerGetDefaults());     
    params.figureClose = false;
    
    %% Read in the EEG and find the correct channel number
    EEG1 = splitData.EEG1;
    EEG2 = splitData.EEG2;
    [channelNumber, channelLabel] = getChannelNumber(EEG1, channelLabels);
    if isempty(channelNumber)
        warning('%d: %s does not have the channel in question, cannot compute....', k, dataFiles{k});
        continue;
    end

    %% Find the spindle curves for each part
    [spindles1, params1] = spindlerExtractSpindles(EEG1, channelNumber, params);
    [spindles2, params2] = spindlerExtractSpindles(EEG2, channelNumber, params);
    
    %% Get the metrics for each part
    expertEvents1 = splitData.expertEvents1;
    params1.name = [params.name '_firstPart'];
    [spindlerCurves1, warningMsgs1] = spindlerGetParameterCurves(spindles1, imageDir, params1);
    [allMetrics1, params1] = calculatePerformance(spindles1, expertEvents1, params1);
    expertEvents2 = splitData.expertEvents2;
    params2.name = [params.name '_lastPart'];
    [spindlerCurves2, warningMsgs2] = spindlerGetParameterCurves(spindles2, imageDir, params2);
    [allMetrics2, params2] = calculatePerformance(spindles2, expertEvents2, params2);
    
    for n = 1:length(metricNames)
        spindlerShowMetric(spindlerCurves1, allMetrics1, metricNames{n}, ...
                   imageDir, params1);
    end
    for n = 1:length(metricNames)
        spindlerShowMetric(spindlerCurves2, allMetrics2, metricNames{n}, ...
                   imageDir, params2);
    end
   
    %%
    [optimalMetrics1, optimalIndices1] = ...
                  getOptimalMetrics(allMetrics1, metricNames, methodNames);
    [optimalMetrics2, optimalIndices2] = ...
                  getOptimalMetrics(allMetrics2, metricNames, methodNames);
    supervisedMetrics2 = getMetricsFromIndices(allMetrics1, ...
                 optimalIndices1, metricNames, methodNames);
    supervisedMetrics1 = getMetricsFromIndices(allMetrics2, ...
                 optimalIndices2, metricNames, methodNames);
   
    additionalInfo.spindles1 = spindles1;
    additionalInfo.spindlerCurves1 = spindlerCurves1;
    additionalInfo.allMetrics1 = allMetrics1;
    additionalInfo.spindles1 = spindles2;
    additionalInfo.spindlerCurves1 = spindlerCurves2;
    additionalInfo.allMetrics1 = allMetrics2;

    %% Save the results
    [~, fileName, ~] = fileparts(dataFiles{k});
    save([supervisedResultsDir  filesep fileName, '_spindlerSupervisedResults.mat'], 'events', ...
        'expertEvents1', 'expertEvents2',  'supervisedMetrics1', ...
        'supervisedMetrics2', 'params1', 'params2', 'additionalInfo', '-v7.3');
end

% % Now consolidate the events for the collection and create a summary
% [results, dataNames, upperBounds] = consolidateResults(resultsDir, methodNames, metricNames);
% save(summaryFile, 'results', 'dataNames', 'methodNames', ...
%     'metricNames', 'upperBounds', '-v7.3');
