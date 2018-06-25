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
% stageDir = [];
% eventDir = 'D:\TestData\Alpha\spindleData\bcit\events2Col';
% resultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSpindler';
% imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindler';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_Spindler_Summary.mat';
% channelLabels = {'PO7'};
% paramsInit = struct();
% paramsInit.spindleFrequencyRange = [6, 13];
% paramsInit.spindleSeparationMin = 0.5;
% paramsInit.figureClose = false;

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
stageDir = [];
dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
channelLabels = {'C3-A1', 'CZ-A1'};
paramsInit = struct();
paramsInit.spindleFrequencyRange = [11, 17];
paramsInit.algorithm = 'spindler';

% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\results_spindler';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\images_spindler';

% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert1';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\results_spindler_expert1';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\images_spindler_expert1';

eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert2';
resultsDir = 'D:\TestData\Alpha\spindleData\dreams\results_spindler_expert2';
imageDir = 'D:\TestData\Alpha\spindleData\dreams\images_spindler_expert2';

%% Example 6: Mass
% dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
% stageDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';
% 
% channelLabels = {'CZ'};
% paramsInit = struct();
% paramsInit.spindleFrequencyRange = [11, 17];
% paramsInit.algorithm = 'spindler';

% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_spindler';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_spindler';

% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert1';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_spindler_expert1';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_spindler_expert1';

% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert2';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_spindler_expert2';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_spindler_expert2';

%% Metrics to calculate
paramsInit.metricNames = {'f1', 'f2', 'G', 'precision', 'recall', 'fdr'};

%% Common initialization
%paramsInit.figureClose = false;
paramsInit.figureFormats = {'png', 'fig'};
paramsInit.srateTarget = 0;
%% Get the data and event file names and check that we have the same number
dataFiles = getFileListWithExt('FILES', dataDir, '.set');

%% Create the output directory if it doesn't exist
if ~isempty(resultsDir) && ~exist(resultsDir, 'dir')
    fprintf('Creating results directory %s \n', resultsDir);
    mkdir(resultsDir);
end
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    fprintf('Creating image directory %s \n', imageDir);
    mkdir(imageDir);
end

%% Process the data
for k = 1:length(dataFiles)
    %% Read in the EEG and find the correct channel number
    params = paramsInit;
    [~, theName, ~] = fileparts(dataFiles{k});
    params.name = theName;
    [data, params.srateOriginal, params.srate, params.channelNumber, ...
        params.channelLabel] = getChannelData(dataFiles{k}, ...
        channelLabels, params.srateTarget);
    if isempty(data)
        warning('No data found for %s\n', dataFiles{k});
        continue;
    end
    
    %% Read events and stages if available 
    expertEvents = readEvents(eventDir, [theName '.mat']);
    stageEvents = readEvents(stageDir, [theName '.mat']);
    
    %% Use the longest stretch in the stage events
    [data, startFrame, endFrame, expertEvents] = ...
         getMaxStagedData(data, stageEvents, expertEvents, params.srate);
    
    %% Call Spindler to find the spindles and metrics
    [spindles, additionalInfo, params] =  ...
                      spindler(data, expertEvents, imageDir, params);
     additionalInfo.algorithm = params.algorithm;            
     additionalInfo.startFrame = startFrame;
     additionalInfo.endFrame = endFrame;
     additionalInfo.srate = params.srate;
     additionalInfo.stageEvents = stageEvents;
     theFile = [resultsDir filesep theName, '.mat'];
     save(theFile, 'spindles', 'expertEvents', 'params', 'additionalInfo', '-v7.3');
end
