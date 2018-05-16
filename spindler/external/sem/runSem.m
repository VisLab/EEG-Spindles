%% Set up the directory
% dataDir = 'D:\TestData\Alpha\spindleData\BCIT\level0';
% eventDir = 'D:\TestData\Alpha\spindleData\BCIT\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsWendt';
% imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesWendt';
% centralLabels = {'CZ'};
% occipitalLabels = {'O1'};
% paramsInit = struct();

%% Set up the directory for dreams
% stageDir = [];
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSem';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreams_Sem_Summary.mat';
% centralLabels = {'C3-A1', 'CZ-A1'};
% occipitalLabels = {'O1-A1'};
% paramsInit = struct();

%% Set up the directory for mass
stageDir = [];
dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';
resultsDir = 'D:\TestData\Alpha\spindleData\massNew\resultsSem';
summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\massNew_Sem_Summary.mat';
centralLabels = {'Cz'};
occipitalLabels = {'O1'};
paramsInit = struct();

%% Metrics to calculate and methods to use
paramsInit.metricNames = {'f1', 'f2', 'G', 'precision', 'recall', 'fdr'};
paramsInit.methodNames = {'count', 'hit', 'intersect', 'onset', 'time'};

%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES', dataDir, '.set');

%% Create the output and summary directories if they don't exist
if ~isempty(resultsDir) && ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

%% Run the algorithm
for k = 1:length(dataFiles)
    params = processParameters('Wendt_a6', 0, 0, paramsInit, getGeneralDefaults());
    [~, theName, ~] = fileparts(dataFiles{k});
    params.name = theName;
    params.srateTarget = 0;
    [data, params.srateOriginal, params.channelNumber, params.channelLabel] = ...
           getChannelData(dataFiles{k}, centralLabels, params.srateTarget);
    params.srate = params.srateOriginal;
 
   [dataOccipital, params.srateOriginal, params.occipitalNumber, ...
       params.occipitalLabel] = getChannelData(dataFiles{k}, ...
       centralLabels, params.srateTarget);
   
    if isempty(data) || isempty(dataOccipital)
        warning('No occipital or central data found for %s\n', dataFiles{k});
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
        dataOccipital = dataOccipital(startFrame:endFrame);
    end
    
    
    %% Load the file
    detection = a6_spindle_detection(data(:), dataOccipital(:), params.srate);
    events = getMaskEvents(detection, params.srate);
    events = combineEvents(events, params.spindleLengthMin, ...
                           params.spindleSeparationMin);
                       
    if ~isempty(expertEvents)
        totalTime = length(data)/params.srate;
        metrics = getPerformanceMetrics(expertEvents, events, totalTime, params);
    else
        metrics = [];
    end
    additionalInfo = struct();
%% Save the results
    theFile = [resultsDir filesep theName '_Ch_' params.channelLabel ...
               '_' params.occipitalLabel '_Sem.mat'];
    save(theFile, 'events', 'expertEvents', 'metrics', ...
        'params', 'additionalInfo', '-v7.3');

end

%% Now consolidate the events for the collection and create a summary
[results, dataNames, upperBounds] = ...
    consolidateResults(resultsDir, paramsInit.methodNames, paramsInit.metricNames);

%% Save the results
[summaryDir, ~, ~] = fileparts(summaryFile);
if ~isempty(summaryDir) && ~exist(summaryDir, 'dir')
    fprintf('Creating summary directory %s \n', summaryDir);
    mkdir(summaryDir);
end
methodNames = params.methodNames;
metricNames = params.metricNames;
save(summaryFile, 'results', 'dataNames', 'methodNames', ...
      'metricNames', 'upperBounds', '-v7.3');
