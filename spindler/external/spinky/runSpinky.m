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

% %% Set up for nctu
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
channelLabels = {'C3-A1', 'CZ-A1'};
defaults = concatenateStructs(getGeneralDefaults(), spinkyGetDefaults());
paramsInit = processParameters('runSpinky', 0, 0, struct(), defaults);
paramsInit.srateTarget = 0;
summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
               'dreams_Spinky_Summary.mat'];
resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpinky';
           
%% Metrics to calculate and methods to use
paramsInit.metricNames = {'f1', 'f2', 'G'};
paramsInit.methodNames = {'countMetrics', 'hitMetrics', 'intersectMetrics', 'onsetMetrics', 'timeMetrics'};

%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES', dataDir, '.set');

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
for k = 4:length(dataFiles)
    params = paramsInit;
    EEG = pop_loadset(dataFiles{k});
    [~, theName, ~] = fileparts(dataFiles{k});
     params.name = theName;
   
    %% Now load the events and epoch
    if isempty(eventDir)
       expertEvents = [];
    else
       expertEvents = readEvents([eventDir filesep theName '.mat']);
   
    end
    params.srateOriginal = EEG.srate;
    params.srate = EEG.srate;
    [params.channelNumber, params.channelLabel] = getChannelNumber(EEG, channelLabels);
    if isempty(params.channelNumber)
        warning('Dataset %s does not have needed channels', params.name);
        return;
    end
    
    %% Load the file and extrad the data for the channel
    data = EEG.data(params.channelNumber, :);
    [labeledEvents, metrics, additionalInfo, params] =  ...
                        spinky(data, expertEvents,  params);

    theFile = [resultsDir filesep theName '_spinky.mat'];
    save(theFile, 'labeledEvents', 'expertEvents', 'metrics', ...
        'params', 'additionalInfo', '-v7.3');
 end

%% Now create a summary of the performance results
if ~isempty(summaryFile)
    methodNames = paramsInit.methodNames;
    metricNames = paramsInit.metricNames;
   [results, dataNames] = consolidateResults(resultsDir, methodNames, metricNames);
    save(summaryFile, 'results', 'dataNames', 'methodNames', 'metricNames', '-v7.3');
end