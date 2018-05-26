%% Wrapper to call the CWT algorithms proposed by Tsanas et al.
%
% The script assumes that the event files have same name as data files.
%% Set up the parameters for BCIT
% dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
% eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
% channelLabels = {'PO7'};
% defaults = concatenateStructs(getGeneralDefaults(), cwtGetDefaults());
% paramsInit = processParameters('runCwt', 0, 0, struct(), defaults);     
% paramsInit.srateTarget = 100;
% paramsInit.cwtAlgorithm = 'a8';
% paramsInit.cwtSpindleFrequencies = 6:14;
% summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
%     'bcit_Cwt_' paramsInit.cwtAlgorithm '_Summary.mat'];
% resultsDir = ['D:\TestData\Alpha\spindleData\bcit\resultsCwt_' ...
%                paramsInit.cwtAlgorithm];

%% Set up for nctu
% dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% channelLabels = {'P3'};
% defaults = concatenateStructs(getGeneralDefaults(), cwtGetDefaults());
% paramsInit = processParameters('runCwt', 0, 0, struct(), defaults);     
% paramsInit.srateTarget = 100;
% paramsInit.cwtAlgorithm = 'a8';
% paramsInit.cwtSpindleFrequencies = 6:14;
% summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
%     'nctu_Cwt_' paramsInit.cwtAlgorithm '_Summary.mat'];
% resultsDir = ['D:\TestData\Alpha\spindleData\nctu\resultsCwt_' ...
%                paramsInit.cwtAlgorithm];

%% Set up the directory for dreams
% stageDir = [];
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';
% channelLabels = {'C3-A1', 'CZ-A1'};
% defaults = concatenateStructs(getGeneralDefaults(), cwtGetDefaults());
% paramsInit = processParameters('runCwt', 0, 0, struct(), defaults);
% 
% paramsInit.onsetTolerance = 0.3;
% paramsInit.timingTolerance = 0.1;     
% paramsInit.srateTarget = 100;
% paramsInit.cwtAlgorithm = 'a7';
% summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
%     'dreams_Cwt_' paramsInit.cwtAlgorithm '_Summary.mat'];
% resultsDir = ['D:\TestData\Alpha\spindleData\dreams\resultsCwt_' ...
%                paramsInit.cwtAlgorithm];

%% Set up the directory for mass
stageDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';
dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';
channelLabels = {'Cz'};
defaults = concatenateStructs(getGeneralDefaults(), cwtGetDefaults());
paramsInit = processParameters('runCwt', 0, 0, struct(), defaults);

paramsInit.onsetTolerance = 0.3;
paramsInit.timingTolerance = 0.1;     
paramsInit.srateTarget = 100;
paramsInit.cwtAlgorithm = 'a7';
summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
    'massNew_Cwt_' paramsInit.cwtAlgorithm '_Summary.mat'];
resultsDir = ['D:\TestData\Alpha\spindleData\massNew\resultsCwt_' ...
               paramsInit.cwtAlgorithm];
           
%% Metrics to calculate and methods to use
paramsInit.metricNames = {'f1', 'f2', 'G', 'precision', 'recall', 'fdr'};
paramsInit.methodNames = {'count', 'hit', 'intersect', 'onset', 'time'};

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
    params.srate = params.srateTarget;
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
    
%% Now call the algorithm and calculate performance
    [eventFrames, additionalInfo.spindleParameters] = spindle_estimation_FHN2015(data, params.srate, ...
                        params.cwtSpindleFrequencies, params.cwtAlgorithm); 
    events = (eventFrames - 1)/params.srate;
    events = combineEvents(events, params.spindleLengthMin, ...
                    params.spindleSeparationMin, params.spindleLengthMax);
    
    if ~isempty(expertEvents)
        totalTime = length(data)/params.srate;
        metrics = getPerformanceMetrics(expertEvents, events, totalTime, params);
    else
        metrics = [];
    end
    
%% Save the results
    theFile = [resultsDir filesep theName '_Cwt_'  params.cwtAlgorithm '.mat'];
    save(theFile, 'events', 'expertEvents', 'metrics', 'params', 'additionalInfo', '-v7.3');
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
