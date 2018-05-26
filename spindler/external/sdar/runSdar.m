%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

%% Setup the directories for input and output for driving data
dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
stageDir = [];
eventDir = 'D:\TestData\Alpha\spindleData\bcit\events2Col';
resultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSdar';
imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesSdar';
summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_Sdar_Summary.mat';
channelLabels = {'PO7'};
paramsInit = struct();
paramsInit.srateTarget = 128;
%paramsInit.sdarFrequencies = 6:0.5:13;

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
paramsInit.metricNames = {'f1', 'f2', 'G', 'precision', 'recall', 'fdr'};
paramsInit.methodNames = {'count', 'hit', 'intersect', 'onset', 'time'};

%% Create the output directory if it doesn't exist
if ~isempty(resultsDir) && ~exist(resultsDir, 'dir')
    fprintf('Creating results directory %s \n', resultsDir);
    mkdir(resultsDir);
end
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    fprintf('Creating image directory %s \n', imageDir);
    mkdir(imageDir);
end
[summaryDir, ~, ~] = fileparts(summaryFile);
if ~isempty(summaryDir) && ~exist(summaryDir, 'dir')
    fprintf('Creating summary directory %s \n', summaryDir);
    mkdir(summaryDir);
end
paramsInit.figureClose = true;
paramsInit.figureFormats = {'png', 'fig'};

%% Get the data and event file names and check that we have the same number
dataFiles = getFileListWithExt('FILES', dataDir, '.set');

%% Process the data
for k = 1%:length(dataFiles)
     %% Read in the EEG and find the correct channel number
    params = paramsInit;
    [~, theName, ~] = fileparts(dataFiles{k});
    params.name = theName;
    [data, params.srateOriginal, params.channelNumber, params.channelLabel] = ...
           getChannelData(dataFiles{k}, channelLabels, params.srateTarget);
    params.srate = params.srateTarget;
    if isempty(data)
        warning('No data found for %s\n', dataFiles{k});
        continue;
    end
    startFrame = 1;
    endFrame = length(data);
        %% Read events and stages if available 
    expertEvents = [];
    if ~isempty(eventDir)
        expertEvents = readEvents([eventDir filesep theName '.mat']);
    end
    stageEvents = [];
    %% Use the longest stetch in the stage events
    if ~isempty(stageDir)
        stageStuff = load([stageDir filesep theName '.mat']);
        stageEvents = stageStuff.stage2Events;
        stageLengths = stageEvents(:, 2) - stageEvents(:, 1);
        [maxLength, maxInd] = max(stageLengths);
        eventMask = stageEvents(maxInd, 1) <= expertEvents(:, 1) & ...
                    expertEvents(:, 1) <= stageEvents(maxInd, 2);
        expertEvents = expertEvents(eventMask, :) - stageEvents(maxInd, 1);
        startFrame = max(1, round(stageEvents(maxInd, 1)*params.srate));
        endFrame = min(length(data), round(stageEvents(maxInd, 2)*params.srate));
        data = data(startFrame:endFrame);
    end
    
        %% Call Spindler to find the spindles and metrics
    [events, metrics, additionalInfo, params] =  ...
                      sdar(data, expertEvents, imageDir, params);
     additionalInfo.startFrame = startFrame;
     additionalInfo.endFrame = endFrame;
     additionalInfo.srate = params.srate;
     totalMin = (startFrame - endFrame)/60/params.srate;
     fprintf('---%d:%s [%d, %d] %g min %d labeled events %d expert events\n', ...
         k, theName, startFrame, endFrame, totalMin, size(events, 1), ...
         size(expertEvents, 1));
     save([resultsDir filesep theName, '_sdarResults.mat'], 'events', ...
         'expertEvents', 'metrics', 'params', 'additionalInfo', '-v7.3');
end

%% Now consolidate the events for the collection and create a summary
[results, dataNames, upperBounds] = ...
    consolidateResults(resultsDir, paramsInit.methodNames, paramsInit.metricNames);

%% Save the results
methodNames = params.methodNames;
metricNames = params.metricNames;
save(summaryFile, 'results', 'dataNames', 'methodNames', ...
    'metricNames', 'upperBounds', '-v7.3');