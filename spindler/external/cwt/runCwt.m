%% Wrapper to call the CWT algorithms proposed by Tsanas et al.

%% Set up the directory for dreams
stageDir = [];
dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';

channelLabels = {'C3-A1', 'CZ-A1'};
defaults = concatenateStructs(getGeneralDefaults(), struct());
paramsInit = processParameters('runCwt', 0, 0, struct(), defaults);
paramsInit.spindleFrequencyRange = [11, 17];
paramsInit.onsetTolerance = 0.3;
paramsInit.timingTolerance = 0.1;     
paramsInit.srateTarget = 100;
paramsInit.algorithm = 'cwta8';

resultsDir = ['D:\TestData\Alpha\spindleData\dreams\results_' ...
               paramsInit.algorithm '_combined'];
eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';

% resultsDir = ['D:\TestData\Alpha\spindleData\dreams\results_' ...
%                paramsInit.algorithm '_expert1'];
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert1';

% resultsDir = ['D:\TestData\Alpha\spindleData\dreams\results_' ...
%                paramsInit.algorithm '_expert2'];
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert2';

%% Set up the directory for mass
% dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
% stageDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';
% 
% channelLabels = {'Cz'};
% defaults = concatenateStructs(getGeneralDefaults(), struct());
% paramsInit = processParameters('runCwt', 0, 0, struct(), defaults);
% paramsInit.spindleFrequencyRange = [11, 17];
% paramsInit.onsetTolerance = 0.3;
% paramsInit.timingTolerance = 0.1;     
% paramsInit.srateTarget = 100;
% paramsInit.algorithm = 'cwta8';
% 
% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';
% resultsDir = ['D:\TestData\Alpha\spindleData\massNew\results_' ...
%                paramsInit.algorithm '_combined'];
           
% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert1';
% resultsDir = ['D:\TestData\Alpha\spindleData\massNew\results_' ...
%                 paramsInit.algorithm '_expert1'];

% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert2';
% resultsDir = ['D:\TestData\Alpha\spindleData\massNew\results_' ...
%                 paramsInit.algorithm '_expert2'];

           
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
    expertEvents = readEvents(eventDir, [theName '.mat']);
    stageEvents = readEvents(stageDir, [theName '.mat']);
    
    %% Use the longest stretch in the stage events
    [data, startFrame, endFrame, expertEvents] = ...
         getMaxStagedData(data, stageEvents, expertEvents, params.srate);
       
%% Now call the algorithm and calculate performance
    [eventFrames, additionalInfo.spindleParameters] = spindle_estimation_FHN2015(data, params.srate, ...
                        params.spindleFrequencyRange, params.algorithm); 
    events = (eventFrames - 1)/params.srate;
    events = combineEvents(events, params.spindleLengthMin, ...
                    params.spindleSeparationMin, params.spindleLengthMax);
    
    if ~isempty(expertEvents)
        totalTime = length(data)/params.srate;
        metrics = getPerformanceMetrics(expertEvents, events, totalTime, params);
    else
        metrics = [];
    end
    additionalInfo.algorithm = params.algorithm;
    additionalInfo.allMetrics = metrics;
    additionalInfo.startFrame = startFrame;
    additionalInfo.endFrame = endFrame;
    additionalInfo.srate = params.srate;
    additionalInfo.stageEvents = stageEvents;
%% Save the results
    theFile = [resultsDir filesep theName '.mat'];
    save(theFile, 'events', 'expertEvents', 'params', 'additionalInfo', '-v7.3');
end