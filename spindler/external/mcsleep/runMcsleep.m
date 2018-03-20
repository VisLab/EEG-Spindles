%% Wrapper to call the Mcsleep algorithms proposed by Parekh et al.

%% Set up the default parameters
defaults = concatenateStructs(getGeneralDefaults(), mcsleepGetDefaults());
paramsInit = processParameters('runMcsleep', 0, 0, struct(), defaults); 

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
dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';
channelLabels = {{'FP1-A1'}, {'C3-A1', 'CZ-A1'}, {'O1-A1'}};
paramsInit.srateTarget = 200;
summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
    'dreams_mcsleep_Summary.mat'];
resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsMcsleep';
params.lam1 = 0.3;
params.lam2 = 6.5;
params.lam3 = 36;
params.mu = 0.5;
params.Nit = 80;
params.K = 200;
params.O = 100;

% Bandpass filter & Teager operator parameters
params.f1 = 11;
params.f2 = 17;
params.filtOrder = 4;
params.Threshold = 0.5; 

% Other function parameters
%params.channels = [1, 6, 7];
params.channels = [2 3 14];
%% MASS parameters
params.y = Y;
params.lam1 = 0.6;
params.lam2 = 7;
params.lam3 = 45;
params.mu = 0.5;
params.Nit = 40;
params.K = 256;
params.O = 128;
params.fs = fs;

% Bandpass filter & Teager operator parameters
params.f1 = 11;
params.f2 = 16;
params.filtOrder = 4;
params.Threshold = 0.5; 
params.meanEnvelope = 0;
params.desiredChannel = 4;
%% Metrics to calculate and methods to use
metricNames = {'f1', 'f2', 'G'};
methodNames = {'count', 'hit', 'intersect', 'onset', 'time'};

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

%% Create the output and summary directories if they don't exist
if ~isempty(resultsDir) && ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end;
[summaryDir, ~, ~] = fileparts(summaryFile);
if ~isempty(summaryDir) && ~exist(summaryDir, 'dir')
    fprintf('Creating summary directory %s \n', summaryDir);
    mkdir(summaryDir);
end

%% Run the algorithm
for k = 1%:length(dataFiles)
    params = paramsInit;
    %% Load the file and extract the channels
    EEG = pop_loadset(dataFiles{k});
    params.srateOriginal = EEG.srate;
    channelNumbers = zeros(1, length(channelLabels));
    for n = 1:length(channelNumbers)
        theseLabels = channelLabels{n};
        theNumber = getChannelNumber(EEG, theseLabels);
        if isempty(theNumber)
            warning('Dataset %d: %s does not have needed channel %d', ...
                k, dataFiles{k}, n);
            continue;
        end
        channelNumbers(n) = theNumber;
    end
    channelNumbers(channelNumbers == 0) = [];
    if isempty(channelNumbers)
        warning('Dataset %d: %s does not any of the needed channels', ...
                k, dataFiles{k});
        continue;
    end
    
    %% Resample as needed
    EEG.data = EEG.data(channelNumbers, :);
    EEG.chanlocs = EEG.chanlocs(channelNumbers);
    EEG.nbchan = length(channelNumbers);
    EEG.event = [];
    EEG = pop_resample(EEG, params.srateTarget);
    params.srate = EEG.srate;
    params.frames = size(EEG.data, 2);
    data = EEG.data;
    
%     %% Select parameters for McSleep
%     % Adjust parameters to improve performance
%     params.lam1 = 0.3;
%     params.lam2 = 6.5;
%     params.lam3 = 36;
%     params.mu = 0.5;
%     params.Nit = 80;
%     params.K = 200;
%     params.O = 100;
%     
%     % Bandpass filter & Teager operator parameters
%     params.f1 = 11;
%     params.f2 = 17;
%     params.filtOrder = 4;
%     params.Threshold = 0.5;
%     
%     % Other function parameters
%     params.channels = [2 3 14];
%     % Don't calculate cost to save time
    % In order to see cost function behavior, run demo.m
    params.mcsleepCalculateCost = 0;
% %% Run parallel detection for transient separation
% % Start parallel pool. Adjust according to number of virtual
% % cores/processors. Starting the parallel pool for the first time may take
% % few seconds. 
% 
% if isempty(gcp) 
%         p = parpool(8); 
% end
% 
% spindles = parallelSpindleDetection(params);
%     
%        
    spindleMask = mcsleepExtractSpindles(EEG.data, params);
    events = getMaskEvents(spindleMask, params.srate); 
    events = combineEvents(events, params.spindleLengthMin, params.spindleSeparationMin);
    additionalInfo = struct();
    additionalInfo.spindleParameters = params; %#ok<STRNU>
    %% Deal with ground truth if available
    if isempty(eventFiles) || isempty(eventFiles{k})
        expertEvents = [];
        metrics = [];
    else
        expertEvents = readEvents(eventFiles{k});
        totalTime = params.frames/params.srate;
        metrics = getPerformanceMetrics(expertEvents, events, ...
                          totalTime, params);
    end
    [~, theName, ~] = fileparts(dataFiles{k});   
    params.name = theName;
    additionalInfo = struct();
    theFile = [resultsDir filesep theName '_Mcsleep.mat'];
    save(theFile, 'events', 'expertEvents', 'metrics', 'params', 'additionalInfo', '-v7.3');
end

%% Now create a summary of the performance results
if ~isempty(summaryFile)
   [results, dataNames] = consolidateResults(resultsDir, methodNames, metricNames);
    save(summaryFile, 'results', 'dataNames', 'methodNames', 'metricNames', '-v7.3');
end