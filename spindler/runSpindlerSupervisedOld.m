%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

%% Setup the directories for input and output for driving data
splitDir = 'D:\TestData\Alpha\spindleData\bcit\data';
supervisedResultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSpindlerSupervised';
imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindlerSupervised';
summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummarySupervised\bcit_Spindler_Summary_Supervised.mat';
channelLabels = {'PO7'};

%% NCTU
% splitFileDir = 'D:\TestData\Alpha\spindleData\nctu\splitData';
% supervisedResultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsSpindlerSupervised';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerSupervised';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummarySupervised\nctu_Spindler_Summary_Supervised.mat';
% channelLabels = {'P3'};

% %% Dreams
% splitFileDir = 'D:\TestData\Alpha\spindleData\dreams\splitData';
% supervisedResultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpindlerSupervised';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindlerSupervised';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummarySupervised\dreams_Spindler_Summary_Supervised.mat';
% channelLabels = {'C3-A1', 'CZ-A1'};

%% Mass
% splitFileDir = 'D:\TestData\Alpha\spindleData\mass\dataSplit';
% supervisedResultsDir = 'D:\TestData\Alpha\spindleData\mass\resultsSpindlerSupervised';
% imageDir = 'D:\TestData\Alpha\spindleData\maxx\imagesSpindlerSupervised';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummarySupervised\mass_Spindler_Summary_Supervised.mat';
% channelLabels = {'C3'};
% paramsInit = struct();
% paramsInit.figureClose = false;
% paramsInit.spindlerGaborFrequencies = 10:16;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;
% %paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};

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

%% Process the data
for k = 1%:length(dataFiles)
    %% Load data split files and process the parameters
    splitData = load(dataFiles{k});
    paramsBase = processParameters('runSpindlerSupervised', 0, 0, paramsInit, spindlerGetDefaults());
    [channelNumber, channelLabel] = getChannelNumber(splitData.splitEEG{1}, channelLabels);
    if isempty(channelNumber)
        warning('%d: %s does not have the channel in question, cannot compute....', k, dataFiles{k});
        continue;
    end
    
    numEEG = length(splitData.splitEEG);
    %% Find the spindle curves for each part
    spindles = cell(numEEG, 1);
    params = cell(numEEG, 1);
    spindlerCurves = cell(numEEG, 1);
    warningMsgs = cell(numEEG, 1);
    numExperts = size(splitData.splitEvents, 2);
    selfMetrics = cell(numEEG, numExperts);
    selfParams = cell(numEEG, numExperts);
    
    combinedEvents = cell(numEEG, 1);
    combinedMetrics = cell(numEEG, 1);
    for m = 1:numEEG
        [spindles{m}, params{m}] = spindlerExtractSpindles(...
            splitData.splitEEG{m}, channelNumber, paramsBase);
        params{m}.name = [splitData.splitEEG{m}.setname '_' num2str(m)];
        [spindlerCurves{m}, warningMsgs{m}] = ...
            spindlerGetParameterCurves(spindles{m}, imageDir, params{m});
        comboEvents = [];
        for n = 1:numExperts
            events = splitData.splitEvents{m, n};
            if isempty(events )
                continue;
            end
            comboEvents = [comboEvents; events]; %#ok<AGROW>
            [selfMetrics{m, n}, selfParams{m, n}] = ...
                calculatePerformance(spindles{m}, events, params{m});
            
            for j = 1:length(metricNames)
                spindlerShowMetric(spindlerCurves{m}, selfMetrics{m, n}, metricNames{j}, ...
                    imageDir, selfParams{m, n});
            end
        end
    end
end