%% Set up the directory
dataDir = 'D:\TestData\Alpha\spindleData\BCIT\level0';
eventDir = 'D:\TestData\Alpha\spindleData\BCIT\events';
resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsASDNew';
imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesASDNew';
channelLabels = {'PO7'};
paramsInit = struct();
paramsInit.AsdVisualize = true;

%% Set up the directory
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\level0';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsASD';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesASD';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% paramsInit.AsdVisualize = true;
% paramsInit.



%% Metrics to calculate
metricNames = {'f1', 'f2', 'G'};

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
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end;

paramsInit.figureClose = false;
paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};
badMask = false(length(dataFiles), 1);


%% Process the data
for k = 1%:length(dataFiles)
    %% Load data file
    EEG = pop_loadset(dataFiles{k});
    [~, theName, ~] = fileparts(dataFiles{k});
    %% Load the event file
    if isempty(eventFiles) || isempty(eventFiles{k})
        expertEvents = [];
        metrics = [];
    else
        expertEvents = readEvents(eventFiles{k});
    end
    
    %% Calculate the spindle representations for a range of parameters
    [channelNumber, channelLabel] = getChannelNumber(EEG, channelLabels);
    if isempty(channelNumber)
        warning('%d: %s does not have the channel in question, cannot compute....', k, dataFiles{k});
        continue;
    end
      paramsInit.AsdImagePathPrefix = ...
                     [imageDir filesep theName '_Ch_' num2str(channelLabel)];
   [events, params, additionalInfo] = ...
                      asdExtractEvents(EEG, channelNumber, paramsInit);
   params.fileName = theName;
   frames = params.frames;
   [hitMetrics, intersectMetrics, onsetMetrics, timeMetrics] = ...
        getPerformanceMetrics(expertEvents, events, params.frames, params.srate, params);

    %% Save the results
    [~, fileName, ~] = fileparts(dataFiles{k});
    save([resultsDir filesep fileName, '_AsdResults.mat'], ...
        'events', 'metrics', 'params',  '-v7.3');
end

%% Now print out a message indicating bad files
badFiles = dataFiles(badMask);
if ~isempty(badFiles)
    fprintf('The following files could not be processed due to artifacts:\n');
    for k = 1:length(badFiles)
        fprintf('--- %s\n', badFiles{k});
    end
end