%% Set up the directory
resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsASD';
eventsDir = 'D:\TestData\Alpha\spindleData\BCIT\events';
dataDir = 'D:\TestData\Alpha\spindleData\BCIT\level0';

%% Set up the directory
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\level0';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsASD';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesASD';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% paramsInit.AsdVisualize = true;
% paramsInit.



%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES', dataDir, '.set');
if isempty(dataFiles)
    error('No data files were available');
end

%% Get results files and indicate if any are unused
resultFiles = getFiles('FILES', resultsDir, '.mat');
[resultFiles, unusedResults]  = matchFileNames(dataFiles, resultFiles);
if ~isempty(unusedResults)
    fprintf('The following results files do not match data files:\n');
    for k = 1:length(unusedResults)
        fprintf('   %s\n', unusedResults{k});
    end
end

%% Get events files and indicate if any are unused
eventFiles = getFiles('FILES', eventsDir, '.mat');
[eventFiles, unusedEvents]  = matchFileNames(dataFiles, eventFiles);
if ~isempty(unusedEvents)
    fprintf('The following event files do not match data files:\n');
    for k = 1:length(unusedEvents)
        fprintf('   %s\n', unusedEvents{k});
    end
end

%% Now process the files
for k = 1%:length(resultFiles) 
    if isempty(resultFiles{k})
        warning('Warning: %d: data file %s has no results', k, dataFiles{k});
        continue;
    elseif isempty(eventFiles{k})
        warning('Warning: %d: data file %s has no expert events', k, dataFiles{k});
        continue;
    end
   theseResults = load(resultFiles{k});
   expertEvents = readEvents(eventFiles{k});
   params = theseResults.params;
   srate = theseResults.params.srate;
   frames = theseResults.params.frames;
   events = theseResults.events;
   [hitMetrics, intersectMetrics, onsetMetrics, timeMetrics] = ...
        getPerformanceMetrics(expertEvents, events, frames, srate, params);
   
end