%% Show the curves for selecting the paramters
%% Run the spindle parameter selection
spindleDir = 'D:\TestData\Alpha\spindleData\BCIT\spindles';
imageDir = 'D:\TestData\Alpha\spindleData\BCIT\images';
dataDir = 'D:\TestData\Alpha\spindleData\BCIT\level0';
eventDir = 'D:\TestData\Alpha\spindleData\BCIT\events';
channelLabels = {'A25', 'PO7'};

% spindleDir = 'D:\TestData\Alpha\spindleData\dreams\spindles';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\images';
% 
% spindleDir = 'D:\TestData\Alpha\spindleData\nctu\spindles';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\images';

% %% Make sure the outDir exists
% if ~exist(imageDir, 'dir')
%     mkdir(imageDir);
% end
% 
% %% Load the data and initialize variables
% spindleFiles = getFiles('FILES', spindleDir, '.mat');
% for k = 1:length(spindleFiles)
%     results = load(spindleFiles{k});
%     [~, theName, ~] = fileparts(spindleFiles{k});
%     totalSeconds = results.params.frames./results.params.srate;
%     showSpindleParameters(results.spindles, totalSeconds, theName, imageDir);
% end
dataFiles = getFiles('FILES', dataDir, '.set');
spindleFiles = getFiles('FILES', spindleDir, '.mat');
if isempty(eventDir)
    eventFiles = {};
else
    eventFiles = getFiles('FILES', eventDir, '.mat');
    if length(eventFiles) ~= length(dataFiles)
        error('Must have same number of event files as data files');
    end
end
otherEvents = [];
theTitle = 'Who knows';
events = [];
for k = 1%:length(dataFiles)
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
    results = load(spindleFiles{k});
    spindles = results.spindles;
 h = showEventPlots(EEG, channelNumbers, spindles, events, theTitle, expertEvents, otherEvents)
end