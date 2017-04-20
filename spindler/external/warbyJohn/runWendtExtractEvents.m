%% Set up the directory
% dataDir = 'D:\TestData\Alpha\spindleData\BCIT\level0';
% resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsWendt';
% imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesWendt';
% channelLabels = {'PO7'};
% paramsInit = struct();
% paramsInit.AsdVisualize = true;

%% Set up the directory

dataDir = 'DREAMS\level0';
eventDir = 'DREAMS\events';
resultsDir = 'DREAMS\resultsA6';
imageDir = 'DREAMS\imagesA6';

%dataDir = 'D:\TestData\Alpha\spindleData\dreams\level0';
%eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
%resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsA6';
%imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesA6';
centralLabels = {'C3-A1', 'CZ-A1'};
occipitalLabels = {'O1-A1'};
paramsInit = struct();
paramsInit.AsdVisualize = true;

%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('excerpt', dataDir, '.set');
if isempty(eventDir)
    eventFiles = {};
else
    eFiles = getFiles('excerpt', eventDir, '.mat');
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
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end;

%% Run the algorithm
for k = 1%:length(dataFiles) 
   EEG = pop_loadset(dataFiles{k});
   [centralNumber, centralLabel] = getChannelNumber(EEG, centralLabels);
   [occipitalNumber, occipitalLabel] = getChannelNumber(EEG, occipitalLabels);
   if isempty(centralNumber) || isempty(occipitalNumber)
       warning('Dataset %d: %s does not have needed channels', k, dataFiles{k});
       continue;
   end
   channelNumber=[centralNumber, occipitalNumber];
   params.channelNumber=channelNumber;
   params.minSpindleLength=.2;
   params.minSpindleSeparation=.2;
   params.wendtFrequencies=[10 16];
   params.minSpindleSeparation=.2;
   
   [spindles, params] =  extractWendtEvents(EEG, params);

   
%   centralData = EEG.data(centralNumber, :);
%   occipitalData = EEG.data(occipitalNumber, :);
%   detection = wendt_spindle_detection(centralData, occipitalData, EEG.srate);
%    [~, theName, ~] = fileparts(dataFiles{k});
%    paramsInit.AsdImagePathPrefix = ...
%                      [imageDir filesep theName '_Ch_' num2str(channelLabel)];
%    [events, params, additionalInfo] = ...
%                       asdExtractEvents(EEG, channelNumber, paramsInit);
%    params.fileName = theName;
%    save([resultsDir filesep theName '_Ch_' channelLabel '_asd.mat'], ...
%        'events', 'params', 'additionalInfo', '-v7.3');
end