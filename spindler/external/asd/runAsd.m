%% Set up the directory
% dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
% eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsAsd';
% imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesAsd';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_Asd_Summary.mat';
% channelLabels = {'PO7'};
% paramsInit = struct();
% paramsInit.AsdVisualize = false;

%% NCTU setup
% dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsAsd';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesAsd';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\nctu_Asd_Summary.mat';
% channelLabels = {'P3'};
% paramsInit = struct();

%% Dreams setup
dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsAsd';
imageDirBase = 'D:\TestData\Alpha\spindleData\dreams\imagesAsd';
summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreams_Asd_Summary.mat';
channelLabels = {'C3-A1', 'CZ-A1'};
paramsInit = struct();
paramsInit.AsdPeakFrequencyRange = 10:16;
paramsInit.spindlerOnsetTolerance = 0.3;
paramsInit.spindlerTimingTolerance = 0.1;

%% Common initialization
paramsInit.figureFormats = {'png', 'fig'};
paramsInit.srateTarget = 0;
paramsInit = processParameters('runSem', 0, 0, paramsInit, getGeneralDefaults());

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
   imageDir = [imageDirBase filesep theName '_Ch_' num2str(channelLabel)];
    %% Read events and stages if available
    expertEvents = readEvents(eventDir, [theName '.mat']);
    stageEvents = readEvents(stageDir, [theName '.mat']);
    
    %% Use the longest stretch in the stage events
    [data, startFrame, endFrame, expertEvents] = ...
        getMaxStagedData(data, srate, stageEvents, expertEvents);
    
    [events, params, additionalInfo] = ...
         asdExtractSpindles(data, srate, expertEvents, imageDir, params);
    additionalInfo.startFrame = startFrame;
    additionalInfo.endFrame = endFrame;
    additionalInfo.stageEvents = stageEvents;
    
    %% Save the results
    [~, fileName, ~] = fileparts(dataFiles{k});
    save([resultsDir filesep fileName, '_asdResults.mat'], 'events', ...
        'expertEvents', 'metrics', 'params', 'additionalInfo', '-v7.3');
    
end