%% Wrapper to call spinky algorithm proposed by Lajnef et al.
%
%  Written by Kay Robbins, 2018, UTSA
%
%  Script assumes that events, stages, and data files have same name, but
%  are in different directories.
%
%% Setup for MASS SS2 data collection
% dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
% stageDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';
% channelLabels = {'CZ'};
% paramsInit = struct();
% paramsInit.srateTarget = 0;
% paramsInit.figureFormats = {'png', 'fig'};
% paramsInit.spindleFrequencyRange = [11, 17];
% paramsInit.figureClose = true;
% paramsInit.algorithm = 'spinky';

% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_spinky';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_spinky';
% 
% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert1';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_spinky_expert1';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_spinky_expert1';
% 
% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert2';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_spinky_expert2';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_spinky_expert2';

%% Set up the directory for dreams
stageDir = [];
dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';

channelLabels = {'C3-A1', 'CZ-A1'};
paramsInit = struct();
paramsInit.srateTarget = 0;
paramsInit.figureFormats = {'png', 'fig'};
paramsInit.spindleFrequencyRange = [11, 17];
paramsInit.figureClose = true;
paramsInit.algorithm = 'spinky';

% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\results_spinky_combined';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\images_spinky';

% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert1';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\results_spinky_expert1';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\images_spinky_expert1';

eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert2';
resultsDir = 'D:\TestData\Alpha\spindleData\dreams\results_spinky_expert2';
imageDir = 'D:\TestData\Alpha\spindleData\dreams\images_spinky_expert2';
%% Metrics to calculate and methods to use
paramsInit.metricNames = {'f1', 'f2', 'G', 'precision', 'recall', 'fdr'};

%% Get the data and event file names and check that we have the same number
dataFiles = getFileListWithExt('FILES', dataDir, '.set');

%% Create the output and summary directories if they don't exist
if ~isempty(resultsDir) && ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

%% Run the algorithm
for k = 1:length(dataFiles)
    params = paramsInit;
    [~, theName, ~] = fileparts(dataFiles{k});
    params.name = theName;
    [data, params.srateOriginal, params.channelNumber, params.channelLabel] = ...
           getChannelData(dataFiles{k}, channelLabels, params.srateTarget);
    params.srate = params.srateOriginal;
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
 
    %% Now call spinky
    params.frames = size(data, 2);
    [spindles, additionalInfo, params] =  ...
                             spinky(data, expertEvents, imageDir, params); 
    additionalInfo.algorithm = params.algorithm;
    additionalInfo.startFrame = startFrame;
    additionalInfo.endFrame = endFrame;
    additionalInfo.srate = params.srate;
    additionalInfo.stageEvents = stageEvents;
    theFile = [resultsDir filesep theName '.mat'];
    save(theFile, 'spindles', 'expertEvents', 'params', 'additionalInfo', '-v7.3');
 end
