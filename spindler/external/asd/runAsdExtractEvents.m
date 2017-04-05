%% Set up the directory
dataDir = 'D:\TestData\Alpha\spindleData\BCIT\level0';
resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsASD';
imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesASD';
channelLabels = {'PO7'};
paramsInit = struct();
paramsInit.AsdVisualize = true;

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

%% Process the data using the ASD algorithm
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

for k = 1%:length(dataFiles) 
   EEG = pop_loadset(dataFiles{k});
   [channelNumber, channelLabel] = getChannelNumber(EEG, channelLabels);
   [~, theName, ~] = fileparts(dataFiles{k});
   paramsInit.AsdImagePathPrefix = ...
                     [imageDir filesep theName '_Ch_' num2str(channelLabel)];
   [events, params, additionalInfo] = ...
                      asdExtractEvents(EEG, channelNumber, paramsInit);
   params.fileName = theName;
   save([resultsDir filesep theName '_Ch_' channelLabel '_asd.mat'], ...
       'events', 'params', 'additionalInfo', '-v7.3');
end