%% Set up the directory
% dataDir = 'D:\TestData\Alpha\spindleData\BCIT\level0';
% eventDir = 'D:\TestData\Alpha\spindleData\BCIT\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsWendt';
% imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesWendt';
% centralLabels = {'CZ'};
% occipitalLabels = {'O1'};
% paramsInit = struct();

%% Set up the directory
dataDir = 'D:\TestData\Alpha\spindleData\dreams\level0';
eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsWendt';
imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesWendt';
centralLabels = {'C3-A1', 'CZ-A1'};
occipitalLabels = {'O1-A1'};
paramsInit = struct();

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

%% Run the algorithm
for k = 1%:length(dataFiles)
    params = processParameters('Wendt_a6', 0, 0, paramsInit, getGeneralDefaults());
    EEG = pop_loadset(dataFiles{k});
    [centralNumber, centralLabel] = getChannelNumber(EEG, centralLabels);
    [occipitalNumber, occipitalLabel] = getChannelNumber(EEG, occipitalLabels);
    if isempty(centralNumber) || isempty(occipitalNumber)
        warning('Dataset %d: %s does not have needed channels', k, dataFiles{k});
        continue;
    end
    
    %% Load the file
    centralData = EEG.data(centralNumber, :)';
    occipitalData = EEG.data(occipitalNumber, :)';
    detection = a6_spindle_detection(centralData, occipitalData, EEG.srate);
    events = getMaskEvents(detection, EEG.srate);
    events = combineEvents(events, params.minSpindleLength, params.minSpindleSeparation);
    params.srate = EEG.srate;
    params.frames = size(EEG.data, 2);
    
    %% Deal with ground
    if isempty(eventFiles) || isempty(eventFiles{k})
        expertEvents = [];
        metrics = [];
    else
        metrics = struct('hitMetrics', NaN, 'intersectMetrics', NaN, ...
            'onsetMetrics', NaN, 'timeMetrics', NaN);
        expertEvents = readEvents(eventFiles{k});
        [metrics.hitMetrics, metrics.intersectMetrics, ...
            metrics.onsetMetrics, metrics.timeMetrics] = ...
            getPerformanceMetrics(expertEvents, events, params.frames, ...
                                  params.srate, params);
    end
    [~, theName, ~] = fileparts(dataFiles{k});
    
    params.fileName = theName;
    save([resultsDir filesep theName '_Ch_' centralLabel '_' occipitalLabel '_warby.mat'], ...
        'events', 'metrics', 'params', '-v7.3');
end