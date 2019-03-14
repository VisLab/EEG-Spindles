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

%% Example: Set up for the Dreams sleep collection
% stageDir = [];
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% paramsInit.spindleFrequencyRange = [11, 17];

% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\results_spindler_combined';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\images_spindler_combined';

% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert1';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\results_spindler_expert1';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\images_spindler_expert1';

% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert2';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\results_spindler_expert2';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\images_spindler_expert2';

%% Example: Setup for Mass collection
dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
stageDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';

channelLabels = {'CZ'};
paramsInit = struct();
paramsInit.spindleFrequencyRange = [11, 17];

eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';
resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_spindler_combinedTemp';
imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_spindler_combinedTemp';


% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_spindler_combined';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_spindler_combined';

% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert1';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_spindler_expert1';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_spindler_expert1';

% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert2';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_spindler_expert2';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_spindler_expert2';

%% Common initialization
paramsInit.figureClose = false;
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
    [data, srateOriginal, srate, channelNumber, channelLabel] = ...
        getChannelData(dataFiles{k}, channelLabels, params.srateTarget);
    if isempty(data)
        warning('No data found for %s\n', dataFiles{k});
        continue;
    end
    
    %% Read events and stages if available
    expertEvents = readEvents(eventDir, [theName '.mat']);
    stageEvents = readEvents(stageDir, [theName '.mat']);
    
    %% Use the longest stretch in the stage events
    [data, startFrame, endFrame, expertEvents] = ...
        getMaxStagedData(data, srate, stageEvents, expertEvents);
    
    %% Call Spindler to find the spindles and metrics
    [spindles, additionalInfo, params] =  ...
        spindler(data, srate, expertEvents, imageDir, params);
    additionalInfo.srate = srate;
    additionalInfo.srateOriginal = srate;
    additionalInfo.channelNumber = channelNumber;
    additionalInfo.channelLabel = channelLabel;
    additionalInfo.startFrame = startFrame;
    additionalInfo.endFrame = endFrame;
    additionalInfo.stageEvents = stageEvents;
    atomInd = additionalInfo.parameterCurves.bestEligibleAtomInd;
    threshInd = additionalInfo.parameterCurves.bestEligibleThresholdInd;
    if isempty(atomInd) || isempty(threshInd)
        events = nan;
        additionalInfo.atomsPerSecond = nan;
        additionalInfo.numberAtoms = nan;
        additionalInfo.threshold = nan;
        additionalInfo.numberSpindles = nan;
        additionalInfo.spindleTime = nan;
    else
        theseSpindles = spindles(atomInd, threshInd);
        events = theseSpindles.events;
        additionalInfo.atomsPerSecond = theseSpindles.atomsPerSecond;
        additionalInfo.numberAtoms = theseSpindles.numberAtoms;
        additionalInfo.threshold = theseSpindles.threshold;
        additionalInfo.numberSpindles = theseSpindles.numberSpindles;
        additionalInfo.spindleTime = theseSpindles.spindleTime;
    end
    theFile = [resultsDir filesep theName, '.mat'];
    save(theFile, 'events', 'expertEvents', 'params', ...
        'additionalInfo', 'spindles', '-v7.3');
end
