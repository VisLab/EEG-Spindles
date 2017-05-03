%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

%% Setup the directories for input and output for driving data
% splitFileDir = 'D:\TestData\Alpha\spindleData\bcit\splitData';
% supervisedResultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSpindlerSupervised';
% imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindlerSupervised';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummarySupervised\bcit_Spindler_Summary_Supervised.mat';
% channelLabels = {'PO7'};

%% NCTU
% splitFileDir = 'D:\TestData\Alpha\spindleData\nctu\splitData';
% supervisedResultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsSpindlerSupervised';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerSupervised';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummarySupervised\nctu_Spindler_Summary_Supervised.mat';
% channelLabels = {'P3'};

%% Dreams
splitFileDir = 'D:\TestData\Alpha\spindleData\dreams\splitData';
supervisedResultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpindlerSupervised';
imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindlerSupervised';
summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummarySupervised\dreams_Spindler_Summary_Supervised.mat';
channelLabels = {'C3-A1', 'CZ-A1'};

%% Metrics to calculate and methods to use
metricNames = {'f1', 'f2', 'G'};
methodNames = {'hitMetrics', 'intersectMetrics', 'onsetMetrics', 'timeMetrics'};
numMetrics = length(metricNames);
numMethods = length(methodNames);

%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES', splitFileDir, '.mat');

%% Create the output and summary directories if they don't exist
if ~exist(supervisedResultsDir, 'dir')
    mkdir(supervisedResultsDir);
end;
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
[summaryDir, ~, ~] = fileparts(summaryFile);
if ~isempty(summaryDir) && ~exist(summaryDir, 'dir')
    fprintf('Creating summary directory %s \n', summaryDir);
    mkdir(summaryDir);
end
%paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};

%% Process the data
for k = 1:length(dataFiles)
    %% Load data split files and process the parameters
    splitData = load(dataFiles{k});
    params = processParameters('runSpindlerSupervised', 0, 0, splitData.params, spindlerGetDefaults());     
    params.figureClose = false;
    params.spindlerGaborFrequencies = 10:16;
    params.spindlerOnsetTolerance = 0.3;
    params.spindlerTimingTolerance = 0.1;
    
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
   
    %% Compute the optimal and cross validation metrics
    [optimalMetrics1, optimalIndices1] = ...
                  getOptimalMetrics(allMetrics1, metricNames, methodNames);
    [optimalMetrics2, optimalIndices2] = ...
                  getOptimalMetrics(allMetrics2, metricNames, methodNames);
    supervisedMetrics2 = getMetricsFromIndices(allMetrics2, ...
                 optimalIndices1, metricNames, methodNames);
    supervisedMetrics1 = getMetricsFromIndices(allMetrics1, ...
                 optimalIndices2, metricNames, methodNames);
    supervisedEvents1 = cell(numMethods, numMetrics);
    supervisedEvents2 = cell(numMethods, numMetrics);    
    optimalEvents1 = cell(numMethods, numMetrics);
    optimalEvents2 = cell(numMethods, numMetrics);
    for m = 1:numMethods
        for n = 1:numMetrics
            supervisedEvents1{m, n} = spindles1(optimalIndices2(m, n)).events;
            supervisedEvents2{m, n}  = spindles2(optimalIndices1(m, n)).events;
            optimalEvents1{m, n} = spindles1(optimalIndices1(m, n)).events;
            optimalEvents2{m, n}  = spindles2(optimalIndices2(m, n)).events;
        end
    end
    %% Save the additional information for future analysis
    additionalInfo.spindles1 = spindles1;
    additionalInfo.spindlerCurves1 = spindlerCurves1;
    additionalInfo.allMetrics1 = allMetrics1;
    additionalInfo.spindles2 = spindles2;
    additionalInfo.spindlerCurves2 = spindlerCurves2;
    additionalInfo.allMetrics2 = allMetrics2;
    additionalInfo.optimalIndices1 = optimalIndices1;
    additionalInfo.optimalIndices2 = optimalIndices2;
    additionalInfo.optimalEvents1 = optimalEvents1;
    additionalInfo.optimalEvents2 = optimalEvents2;
    additionalInfo.optimalEvents1 = supervisedEvents1;
    additionalInfo.optimalEvents2 = supervisedEvents2;
    additionalInfo.warningMsgs1 = warningMsgs1;
    additionalInfo.warningMsgs2 = warningMsgs2;
    
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