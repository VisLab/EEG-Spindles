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
% 
%% Example 1: Setup for driving data
dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
resultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSpindlerTest';
imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindlerTest';
summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_Spindler_Summary.mat';
channelLabels = {'PO7'};
paramsInit = struct();

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
% resultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsSpindler';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindler';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\nctu_Spindler_Summary.mat';
% channelLabels = {'P3'};
% paramsInit = struct();

%% Example 4: Set up for the Dreams sleep collection
%dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
%eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
%resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpindler';
%imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindler';
%summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreams_Spindler_Summary.mat';
%channelLabels = {'C3-A1', 'CZ-A1'};
%paramsInit = struct();
%paramsInit.spindlerGaborFrequencies = 10:16;
%paramsInit.spindlerOnsetTolerance = 0.3;
%paramsInit.spindlerTimingTolerance = 0.1;

%% Example 5: Set up for the Dreams sleep collection
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
metricNames = {'f1', 'f2', 'G'};
methodNames = {'hitMetrics', 'intersectMetrics', 'onsetMetrics', 'timeMetrics'};

%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES', dataDir, '.set');
if isempty(eventDir)
    eventFiles = {};
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
paramsInit.figureClose = false;
%paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};

%% Process the data
for k = 1:length(dataFiles)
    %% Read in the EEG and find the correct channel number
    EEG = pop_loadset(dataFiles{k});
    [~, theName, ~] = fileparts(dataFiles{k});
    [channelNumber, channelLabel] = getChannelNumber(EEG, channelLabels);
    if isempty(channelNumber)
        warning('%d: %s does not have the channel in question, cannot compute....', k, dataFiles{k});
        continue;
    end
    
    %% Calculate the spindle representations for a range of parameters
    [spindles, params] = spindlerExtractSpindles(EEG, channelNumber, paramsInit);
    params.name = theName;
    [spindlerCurves, warningMsgs] = spindlerGetParameterCurves(spindles, imageDir, params);
     if spindlerCurves.bestEligibleLinearInd > 0
         events = spindles(spindlerCurves.bestEligibleLinearInd).events;
     end
    %% Deal with ground truth if available
    if isempty(eventFiles) || isempty(eventFiles{k}) || isempty(spindlerCurves)
        expertEvents = [];
        allMetrics = [];
        metrics = [];
    else
        expertEvents = readEvents(eventFiles{k});
        expertEvents = removeOverlapEvents(expertEvents, params.eventOverlapMethod);
        [allMetrics, params] = calculatePerformance(spindles, expertEvents, params);
        for n = 1:length(metricNames)
            spindlerShowMetric(spindlerCurves, allMetrics, metricNames{n}, ...
                       imageDir, params);
        end
        if spindlerCurves.bestEligibleLinearInd > 0
            metrics = allMetrics(spindlerCurves.bestEligibleLinearInd);
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
