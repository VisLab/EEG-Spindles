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
% centralLabels = {'C3-A1', 'CZ-A1'};
% occipitalLabels = {'O1-A1'};
% paramsInit = struct();
% paramsInit.spindleFrequencyRange = [11, 17];
% paramsInit.algorithm = 'sem';

% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';
% resultsDir = ['D:\TestData\Alpha\spindleData\dreams\results_' ...
%               paramsInit.algorithm '_combined'];

% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert1';
% resultsDir = ['D:\TestData\Alpha\spindleData\dreams\results_' ...
%               paramsInit.algorithm '_expert1'];

% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert2';
% resultsDir = ['D:\TestData\Alpha\spindleData\dreams\results_' ...
%               paramsInit.algorithm '_expert2'];

%% Set up the directory for mass
dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
stageDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';
centralLabels = {'Cz'};
occipitalLabels = {'O1'};
paramsInit = struct();
paramsInit.srateTarget = 0;
paramsInit.spindleFrequencyRange = [11, 17];

% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_sem_combined';

% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert1';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_sem_expert1';;

eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert2';
resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_sem_expert2';

%% Initialize the default parameters
paramsInit = processParameters('runSem', 0, 0, paramsInit, getGeneralDefaults());

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
  
    [dataCentral, srateOriginal, srate, channelNumber, channelLabel] ...
         = getChannelData(dataFiles{k}, centralLabels, params.srateTarget);
   
   [dataOccipital, ~,  ~, occipitalNumber, occipitalLabel] ...
         = getChannelData(dataFiles{k}, occipitalLabels, params.srateTarget);
   
    if isempty(dataCentral) || isempty(dataOccipital)
        warning('No occipital or central data found for %s\n', dataFiles{k});
        continue;
    end
    data = [dataCentral; dataOccipital];
    
    %% Read events and stages if available 
    expertEvents = readEvents(eventDir, [theName '.mat']);
    stageEvents = readEvents(stageDir, [theName '.mat']);
    
    %% Use the longest stretch in the stage events
    [data, startFrame, endFrame, expertEvents] = ...
         getMaxStagedData(data, srate, stageEvents, expertEvents);
    
    %% Load the file
   additionalInfo = struct('algorithm', 'sem', 'srate', srate, ...
                           'warningMsgs', [], 'allMetrics', nan);
    detection = a6_spindle_detection(data(1, :)', data(2, :)', srate);
    events = getMaskEvents(detection, srate);
    events = combineEvents(events, params.spindleLengthMin, ...
                 params.spindleSeparationMin, params.spindleLengthMax);
    totalTime = length(data)/srate;                   
    if ~isempty(expertEvents)   
        additionalInfo.allMetrics = getPerformanceMetrics(expertEvents, events, ...
            srate, totalTime, params);
    end
    additionalInfo.srateOriginal = srate;
    additionalInfo.channelNumber = channelNumber;
    additionalInfo.channelLabel = channelLabel;
    additionalInfo.startFrame = startFrame;
    additionalInfo.endFrame = endFrame;
    additionalInfo.stageEvents = stageEvents;
%% Save the results
    theFile = [resultsDir filesep theName '.mat'];
    save(theFile, 'events', 'expertEvents', 'params', 'additionalInfo', '-v7.3');
end
