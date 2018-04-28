%% This script shows how to run the Spindler analysis for a data collection
%  
% You must set up the following information (see examples below)
%   dataDir         path of directory containing EEG .set files to analyze
%   eventDir        directory of labeled event files
%   resultsDir      directory that Spindler uses to write its output
%   imageDir        directory that Spindler users to save images
%   summaryFile     full path name of the file containing the summary analysis
%   channelLabels   cell array containing possible channel labels 
%                      (Spindler uses the first label that matches one in EEG)
%   paramsInit      structure containing the parameter values
%                   (if an empty structure, Spindler uses defaults)
%
% Spindler uses the input to run a batch analysis. If eventDir is not empty, 
% Spindler runs performance comparisons, provided it can match file names for 
% files in eventDir with those in dataDir.  Ideally, the event file names 
% should have the data file names as prefixes, although Spindler tries more
% complicated matching strategies as well.  Event files contain "ground truth"
% in text files with two columns containing the start and end times in seconds.
%

%% Example 1: Setup for driving data
% dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
% eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSpindlerNew';
% imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindlerNew';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_Spindler_SummaryNew.mat';
% channelLabels = {'PO7'};
% paramsInit = struct();
% paramsInit.srateTarget = 128;
% paramsInit.spindlerGaborFrequencies = 6:0.5:13;

%% Example 2: Setup for the BCIT driving collection
% dataDir = 'E:\CTADATA\BCIT\level_0';
% eventDir = '';
% resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsSpindlerNewAgain';
% imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesSpindlerNewAgain';
% channelLabels = {'PO3', 'H27'};
% paramsInit = struct();

%% Example 3: Setup for the NCTU labeled driving collection
% dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsSpindlerNew';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerNew';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\nctu_Spindler_SummaryNew.mat';
% channelLabels = {'P3'};
% paramsInit = struct();
% paramsInit.srateTarget = 128;
% paramsInit.spindlerGaborFrequencies = 6:0.5:13;

%% Example 4: Set up for the Dreams sleep collection
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpindlerNew';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindlerNew';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreams_Spindler_SummaryNew.mat';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% % % paramsInit.spindlerGaborFrequencies = 10.5:0.5:16.5;
% paramsInit.spindlerGaborFrequencies = 10.5:0.5:16.5;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;
% % paramsInit.srateTarget = 200;
% % % paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};

%% Example 4: Set up for the MASS sleep collection
dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';
stageDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';
resultsDir = 'D:\TestData\Alpha\spindleData\massNew\resultsSpindler';
imageDir = 'D:\TestData\Alpha\spindleData\massNew\imagesSpindler';
summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\massNew_Spindler_Summary.mat';
channelLabels = {'CZ'};
paramsInit = struct();
paramsInit.spindlerGaborFrequencies = 10.5:0.5:16.5;
%paramsInit.spindlerGaborFrequencies = 10.5:16.5;
paramsInit.spindlerOnsetTolerance = 0.3;
paramsInit.spindlerTimingTolerance = 0.1;
paramsInit.srateTarget = 128;

%% Example 5: Set up for the Dreams sleep collection
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\dataRestricted';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\eventsRestricted\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsRestrictedSpindler';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesRestrictedSpindler';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreamsRestricted_Spindler_Summary.mat';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% paramsInit.spindlerGaborFrequencies = 10.5:0.5:16.5;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;
% paramsInit.srateTarget = 200;
% paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};

%% Example 6: Driving data supervised 256 Hz
% dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
% eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSpindler256Hz';
% imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindler256Hz';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_Spindler_Summary256.mat';
% channelLabels = {'PO7'};
% paramsInit = struct();
% paramsInit.srateTarget = 256;

%% Example 6: Driving data unsupervised 256 Hz
% dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
% eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSpindlerMoreRes';
% imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindlerMoreRes';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_Spindler_SummaryMoreRes.mat';
% channelLabels = {'PO7'};
% paramsInit = struct();
% paramsInit.srateTarget = 256;
% paramsInit.spindlerGaborFrequencies = 6:0.5:13;

%% Example 7 NCTU data unsupervised 
% dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsSpindlerMoreRes';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerMoreRes';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\nctu_Spindler_SummaryMoreRes.mat';
% channelLabels = {'P3'};
% paramsInit = struct();
% paramsInit.srateTarget = 250;
% paramsInit.spindlerGaborFrequencies = 6:0.5:13;

%% Example 5: Set up for the Dreams sleep collection
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpindlerMoreRes';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindlerMoreRes';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreams_Spindler_SummaryMoreRes.mat';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% paramsInit.srateTarget = 200;
% paramsInit.spindlerGaborFrequencies = 10:0.5:16;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;

%% Example 6: Mas
% dataDir = 'D:\TestData\Alpha\spindleData\mass\data';
% eventDir = [];
% resultsDir = 'D:\TestData\Alpha\spindleData\mass\resultsSpindlerMoreRes';
% imageDir = 'D:\TestData\Alpha\spindleData\mass\imagesSpindlerMoreRes';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\mass_Spindler_SummaryMoreRes.mat';
% channelLabels = {'C3'};
% paramsInit = struct();
% paramsInit.srateTarget = 256;
% paramsInit.spindlerGaborFrequencies = 10:0.5:16;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;
%% Metrics to calculate and methods to use
paramsInit.metricNames = {'f1', 'f2', 'G', 'precision', 'recall', 'fdr'};
paramsInit.methodNames = {'count', 'hit', 'intersect', 'onset', 'time'};
%paramsInit.spindlerGaborFrequencies = 10.5:1:16.5;

%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES', dataDir, '.set');

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
paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};

%% Process the data
for k = 1:length(dataFiles)
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
                      spindler(data, expertEvents, imageDir, params);
     additionalInfo.startFrame = startFrame;
     additionalInfo.endFrame = endFrame;
     additioanlInfo.srate = params.srate;
     totalMin = (startFrame - endFrame)/60/params.srate;
     fprintf('---%d:%s [%d, %d] %g min %d labeled events %d expert events\n', ...
         k, theName, startFrame, endFrame, totalMin, size(events, 1), ...
         size(expertEvents, 1));
     save([resultsDir filesep theName, '_spindlerResults.mat'], 'events', ...
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
