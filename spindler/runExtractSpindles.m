%% This script shows how to call getSpindles to get spindles for a range
% of algorithm parameters. The analyzeSpindles selects best parameters.

%% Setup the directories for input and output for driving data
% dataDir = 'D:\TestData\Alpha\spindleData\BCIT\level0';
% eventDir = 'D:\TestData\Alpha\spindleData\BCIT\events';
% spindleDir = 'D:\TestData\Alpha\spindleData\BCIT\spindles';
% channelLabels = {'A25', 'PO7'};
% paramsInit = struct();

% dataDir = 'D:\TestData\Alpha\spindleData\nctu\level0';
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% spindleDir = 'D:\TestData\Alpha\spindleData\nctu\spindles';
% channelLabels = {'PZ'};
% paramsInit = struct();

dataDir = 'D:\TestData\Alpha\spindleData\dreams\level0';
eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
spindleDir = 'D:\TestData\Alpha\spindleData\dreams\spindles';
channelLabels = {'C3-A1', 'CZ-A1'};
paramsInit = struct();
paramsInit.gaborFrequencies = 10:16;
paramsInit.spindleOnsetTolerance = 0.3;
paramsInit.spindleTimingTolerance = 0.1;

%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES', dataDir, '.set');
if isempty(eventDir)
    eventFiles = {};
else
    eventFiles = getFiles('FILES', eventDir, '.mat');
    if length(eventFiles) ~= length(dataFiles)
        error('Must have same number of event files as data files');
    end
end

%% Create the output file if it doesn't exist
if ~exist(spindleDir, 'dir')
    mkdir(spindleDir);
end;

%% Process the data
for k = 1:length(dataFiles)
    %% Load data file
    EEG = pop_loadset(dataFiles{k});
    
    %% Load the event file
    if isempty(eventDir)
        expertEvents = [];
    else
        expertEvents = readEvents(eventFiles{k});
    end
    %% Calculate the spindle representations for a range of parameters
    channelNumbers = getChannelNumbers(EEG, channelLabels);
    [spindles, params] = extractSpindles(EEG, channelNumbers, expertEvents, paramsInit);
    
    %% Save the results
    [~, fileName, ~] = fileparts(dataFiles{k});
    save([spindleDir filesep fileName, '.mat'], 'spindles',  'params', '-v7.3');
end