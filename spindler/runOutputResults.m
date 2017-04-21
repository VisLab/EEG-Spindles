%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

%% Setup the directories for input and output for driving data
resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsSpindler';
resultSummaryDir = 'D:\TestData\Alpha\spindleData\ResultSummary';
summaryName = 'BCIT_Spindler_Summary.mat';

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
resultFiles = getFiles('FILES', resultsDir, '.mat');

%% Create the array of performance values
results = zeros(length(methodNames), length(metricNames), length(resultFiles));
dataNames = cell(length(resultFiles), 1);
for k = 1:length(resultFiles)
   test = load(resultFiles{k});
   dataNames{k} = test.params.theName;
   results(:, :, k) = consolidateResults(test.metrics, methodNames, metricNames); 
end

%% Save the results files
save([resultSummaryDir filesep summaryName], 'results', 'metricNames', ...
     'methodNames', 'resultFiles', 'dataNames', '-v7.3');
 