%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

%% Setup the directories for input and output for driving data
splitDir = 'D:\TestData\Alpha\spindleData\bcit\dataSplit';
supervisedResultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSpindlerSupervised';
imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindlerSupervised';
summaryFile = 'D:\TestData\Alpha\spindleData\resultSummarySupervised\bcitSpindlerSummarySupervised.mat';
channelLabels = {'PO7'};
paramsInit = struct();
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
dataFiles = getFiles('FILES', splitDir, '.mat');

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
    selfEvents = cell(numEEG, 1);
    warningMsgs = cell(numEEG, 1);
    numExperts = size(splitData.splitEvents, 2);
    selfMetrics = cell(numEEG, numExperts);
    selfParams = cell(numEEG, numExperts);
    
    combinedEvents = cell(numEEG, 1);
    combinedMetrics = cell(numEEG, 1);
    for m = 1:numEEG
        %% Compute the spindle curves
        [spindles{m}, params{m}] = spindlerExtractSpindles(...
            splitData.splitEEG{m}, channelNumber, paramsBase);
        params{m}.name = [splitData.splitEEG{m}.setname '_' num2str(m)];
        [spindlerCurves{m}, warningMsgs{m}] = ...
            spindlerGetParameterCurves(spindles{m}, imageDir, params{m});
        selectedIndex = spindles{m}.bestEligibleInd;
        if selectedIndex > 0
           selfEvents{m} = spindles{m}(selectedIndex).events;
        end
        for n = 1:numExperts
            events = splitData.splitEvents{m, n};
            if isempty(events )
                continue;
            end

            [selfMetrics{m, n}, selfParams{m, n}] = ...
                calculatePerformance(spindles{m}, events, params{m});
            
            for j = 1:length(metricNames)
                spindlerShowMetric(spindlerCurves{m}, selfMetrics{m, n}, metricNames{j}, ...
                    imageDir, selfParams{m, n});
            end
        end
    end
    
    %% Compute the optimal metrics
    optimalMetrics = cell(numEEG, numExperts);
    optimalIndices = cell(numEEG, numExperts);
    selfMetrics = cell(numEEG, numExperts);
    selfIndices = cell(numEEG, numExperts);
    selfEvents = cell(numEEG, numExperts);
    optimalEvents = cell(numEEG, numExperts);
    for m = 1:numEEG
       for n = 1:numExperts
           [optimalMetrics{m, n}, optimalIndices{m, n}] = ...
                  getOptimalMetrics(selfMetrics{m, n}, metricNames, methodNames);
%            selfIndices{m, n} = 
%            selfMetrics = getMetricsFromIndices(allMetrics2, ...
%                  optimalIndices1, metricNames, methodNames);
       end
    end
    
        [spindles, params] = spindlerExtractSpindles(EEG, channelNumber, paramsInit);
    params.name = theName;
    [spindlerCurves, warningMsgs] = spindlerGetParameterCurves(spindles, imageDir, params);
     if spindlerCurves.bestEligibleLinearInd > 0
         events = spindles(spindlerCurves.bestEligibleLinearInd).events;
     end
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
end