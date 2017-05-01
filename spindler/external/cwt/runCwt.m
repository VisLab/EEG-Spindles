%% Wrapper to call the CWT algorithms proposed by Tsanas et al.

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
dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
channelLabels = {'P3'};
defaults = concatenateStructs(getGeneralDefaults(), cwtGetDefaults());
paramsInit = processParameters('runCwt', 0, 0, struct(), defaults);     
paramsInit.srateTarget = 100;
paramsInit.cwtAlgorithm = 'a7';
paramsInit.cwtSpindleFrequencies = 6:14;
summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
    'nctu_cwt_' paramsInit.cwtAlgorithm '_Summary.mat'];
resultsDir = ['D:\TestData\Alpha\spindleData\nctu\resultsCwt_' ...
               paramsInit.cwtAlgorithm];

%% Set up the directory for dreams
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
% channelLabels = {'C3-A1', 'CZ-A1'};
% defaults = concatenateStructs(getGeneralDefaults(), cwtGetDefaults());
% paramsInit = processParameters('runCwt', 0, 0, struct(), defaults);
% 
% paramsInit.onsetTolerance = 0.3;
% paramsInit.timingTolerance = 0.1;     
% paramsInit.srateTarget = 100;
% paramsInit.cwtAlgorithm = 'a8';
% summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
%     'dreams_Cwt_' paramsInit.cwtAlgorithm '_Summary.mat'];
% resultsDir = ['D:\TestData\Alpha\spindleData\dreams\resultsCwt_' ...
%                paramsInit.cwtAlgorithm];
           
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
    mkdir(resultsDir);
end;

%% Run the algorithm
for k = 1:length(dataFiles)
    params = paramsInit;
    EEG = pop_loadset(dataFiles{k});
    params.srateOriginal = EEG.srate;
    [channelNumber, channelLabel] = getChannelNumber(EEG, channelLabels);
    if isempty(channelNumber)
        warning('Dataset %d: %s does not have needed channels', k, dataFiles{k});
        continue;
    end
    
    %% Load the file
    params.srateOriginal = EEG.srate;
    EEG.data = EEG.data(channelNumber, :);
    EEG.chanlocs = EEG.chanlocs(channelNumber);
    EEG.nbchan = 1;
    EEG.event = [];
    EEG = pop_resample(EEG, params.srateTarget);
    params.srate = EEG.srate;
    params.frames = size(EEG.data, 2);
    data = EEG.data;
    [eventFrames, additional] = spindle_estimation_FHN2015(data, EEG.srate, ...
            params.cwtSpindleFrequencies, params.cwtAlgorithm); 
    events = (eventFrames - 1)/EEG.srate;
    events = combineEvents(events, params.minSpindleLength, params.minSpindleSeparation);
    additionalInfo = struct();
    additionalInfo.spindleParameters = additional; %#ok<STRNU>
    %% Deal with ground truth if available
    if isempty(eventFiles) || isempty(eventFiles{k})
        expertEvents = [];
        metrics = [];
    else
        metrics = struct('hitMetrics', NaN, 'intersectMetrics', NaN, ...
            'onsetMetrics', NaN, 'timeMetrics', NaN);
        expertEvents = readEvents(eventFiles{k});
        expertEvents = removeOverlapEvents(expertEvents, params.eventOverlapMethod);
        [metrics.hitMetrics, metrics.intersectMetrics, ...
            metrics.onsetMetrics, metrics.timeMetrics] = ...
            getPerformanceMetrics(expertEvents, events, params.frames, ...
                                  params.srate, params);
    end
    [~, theName, ~] = fileparts(dataFiles{k});   
    params.name = theName;
    additionalInfo = struct();
    theFile = [resultsDir filesep theName '_Cwt_'  params.cwtAlgorithm '.mat'];
    save(theFile, 'events', 'expertEvents', 'metrics', 'params', 'additionalInfo', '-v7.3');
end

%% Now create a summary of the performance results
if ~isempty(summaryFile)
   [results, dataNames] = consolidateResults(resultsDir, methodNames, metricNames);
    save(summaryFile, 'results', 'dataNames', 'methodNames', 'metricNames', '-v7.3');
end