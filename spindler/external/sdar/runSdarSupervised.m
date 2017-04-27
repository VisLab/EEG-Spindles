%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

%% Setup the directories for input and output for driving data
splitFileDir = 'D:\TestData\Alpha\spindleData\bcit\splitData';
supervisedResultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSupervisedSdar';
imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSupervisedSdar';
summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_SupervisedSdar_Summary.mat';
channelLabels = {'PO7'};

%% Set up the directory
% dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsSdar';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSdar';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\nctu_Sdar_Summary.mat';
% channelLabels = {'P3'};
% paramsInit = struct();

%% 
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSdar';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSdar';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreams_Sdar_Summary.mat';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% paramsInit.spindlerGaborFrequencies = 10:16;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;

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
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSdar';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSdar';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\Dreams_Sdar_Summary.mat';
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

%% Process the data
for k = 1:length(dataFiles)
    %% Load data split files and process the parameters
    splitData = load(dataFiles{k});
    params = processParameters('runSdarSupervised', 0, 0, splitData.params, sdarGetDefaults());     
    params.figureClose = false;
    %params.figureFormats = {'png', 'fig', 'pdf', 'eps'};
    %% Read in the EEG and find the correct channel number
    EEG1 = splitData.EEG1;
    EEG2 = splitData.EEG2;
    [channelNumber, channelLabel] = getChannelNumber(EEG1, channelLabels);
    if isempty(channelNumber)
        warning('%d: %s does not have the channel in question, cannot compute....', k, dataFiles{k});
        continue;
    end

    %% Find the spindle curves for each part
    [spindles1, params1] = sdarExtractSpindles(EEG1, channelNumber, params);
    [spindles2, params2] = sdarExtractSpindles(EEG2, channelNumber, params);
    
    %% Get the metrics for each part
    expertEvents1 = splitData.expertEvents1;
    params1.name = [params.name '_firstPart'];
    [allMetrics1, params1] = calculatePerformance(spindles1, expertEvents1, params1);
    expertEvents2 = splitData.expertEvents2;
    params2.name = [params.name '_lastPart'];
    [allMetrics2, params2] = calculatePerformance(spindles2, expertEvents2, params2);
    
    %% Show the metric curves for reference
    for n = 1:length(metricNames)
            sdarShowMetric(spindles1, allMetrics1, metricNames{n}, imageDir, params);
    end
    
    for n = 1:length(metricNames)
            sdarShowMetric(spindles1, allMetrics1, metricNames{n}, imageDir, params);
    end
    
    %% Compute the optimal and cross validation metrics
    [optimalMetrics1, optimalIndices1] = ...
                  getOptimalMetrics(allMetrics1, metricNames, methodNames);
    [optimalMetrics2, optimalIndices2] = ...
                  getOptimalMetrics(allMetrics2, metricNames, methodNames);
    supervisedMetrics2 = getMetricsFromIndices(allMetrics1, ...
                 optimalIndices1, metricNames, methodNames);
    supervisedMetrics1 = getMetricsFromIndices(allMetrics2, ...
                 optimalIndices2, metricNames, methodNames);
   
    %% Save the additional information for future analysis
    additionalInfo.spindles1 = spindles1;
    additionalInfo.allMetrics1 = allMetrics1;
    additionalInfo.spindles1 = spindles2;
    additionalInfo.allMetrics1 = allMetrics2;
 
    %% Save the results
    [~, fileName, ~] = fileparts(dataFiles{k});
    save([supervisedResultsDir  filesep fileName, '_spindlerSupervisedResults.mat'],  ...
        'expertEvents1', 'expertEvents2',  'supervisedMetrics1', ...
        'supervisedMetrics2', 'optimalMetrics1', 'optimalMetrics2', ...
        'methodNames', 'metricNames', 'params1', 'params2', 'additionalInfo', '-v7.3');
end


%% Now consolidate the events for the collection and create a summary
[results, dataNames, upperBounds] = consolidateSupervisedResults(supervisedResultsDir, methodNames, metricNames);
save(summaryFile, 'results', 'dataNames', 'methodNames', 'metricNames', ...
                  'upperBounds', '-v7.3');