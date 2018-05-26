%% Wrapper to call spinky algorithm proposed by Lajnef et al.
% dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';
% stageDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\resultsSpinkyR';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\imagesSpinkyR';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\massNew_Spinky_SummaryR.mat';
% channelLabels = {'CZ'};
% paramsInit = struct();
% paramsInit.srateTarget = 0;
% paramsInit.figureFormats = {'png', 'fig'};
% % paramsInit.figureClose = false;
%% Set up the directory for dreams
stageDir = [];
dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';
imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpinky';
channelLabels = {'C3-A1', 'CZ-A1'};
resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpinky';
summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreamsNew_Spinky_Summary.mat';
paramsInit = struct();
paramsInit.srateTarget = 0;
paramsInit.figureFormats = {'png', 'fig'};
paramsInit.spindleFrequencyRange = [10.5, 16.5];
paramsInit.toleranceOnset = 0.5;

%% Metrics to calculate and methods to use
paramsInit.metricNames = {'f1', 'f2', 'G', 'precision', 'recall', 'fdr'};

%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES', dataDir, '.set');

%% Create the output and summary directories if they don't exist
if ~isempty(resultsDir) && ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

%% Run the algorithm
for k = 1%:length(dataFiles)
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
    expertEvents = [];
    if ~isempty(eventDir)
        expertEvents = readEvents([eventDir filesep theName '.mat']);
    end
    
    %% Use the longest stetch in the stage events
    stageEvents = [];
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
    
    %% Now call spinky
    params.frames = length(data);
    [spindles, allMetrics, additionalInfo, params] =  ...
                              spinky(data, expertEvents, imageDir, params); 
    
    theFile = [resultsDir filesep theName '_spinky.mat'];
    save(theFile, 'spindles', 'expertEvents', 'allMetrics', ...
        'params', 'additionalInfo', '-v7.3');
 end
