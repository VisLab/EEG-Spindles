%% This script generates CSV event file from a mat file
%  

%% Example 1: Setup for driving data
eventDir = 'D:\TestData\Alpha\spindleData\bcit\events2Col';
eventDirOut = 'D:\TestData\Alpha\spindleData\bcit\events2ColCSV';

%% Example 2: Setup for the NCTU labeled driving collection
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events2Col';
% eventDirOut = 'D:\TestData\Alpha\spindleData\nctu\events2ColCSV';


%% Example 3: Set up for the Dreams sleep collection
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDirs = {'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion'; ...
%              'D:\TestData\Alpha\spindleData\dreams\events\expert1'; ...
%              'D:\TestData\Alpha\spindleData\dreams\events\expert2'};
% eventTypes = {'Combined'; 'expert1'; 'expert2'};
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindlerOverlay';
% channelLabels = {'C3-A1', 'CZ-A1'};
% lowFreq = 10;
% highFreq = 17;
% segmentTime = 30;
% baseBand = [1, 20];
% srateTarget = 100;
% figureFormats = {'png', 'fig'};
% scaleFactor = 20;
%% Example 4: Set up for the MASS sleep collection
% dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
% eventDirs = {'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion'; ...
%     'D:\TestData\Alpha\spindleData\massNew\events\expert1'; ...
%     'D:\TestData\Alpha\spindleData\massNew\events\expert2'};
% eventTypes = {'combined', 'expert1', 'expert2'};
% stageDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\imagesEventOverlays';
% channelLabels = {'CZ'};
% lowFreq = 10;
% highFreq = 17;
% segmentTime = 30;
% baseBand = [1, 20];
% srateTarget = 128;
% figureFormats = {'png', 'fig'};
% scaleFactor = 15;
%% Get the data and event file names and check that we have the same number
eventFiles = getFiles('FILES', eventDir, '.mat');

%% Create the output directory if it doesn't exist
if ~exist(eventDirOut, 'dir')
    fprintf('Creating event output directory %s \n', eventDirOut);
    mkdir(eventDirOut);
end

%% Process the data
for k = 1:length(eventFiles)
    %% Get the results file with spindle information
    [~, theName, ~] = fileparts(eventFiles{k});
    
    test = load(eventFiles{k});
    if isfield(test, 'expertEvents')
        events = test.expertEvents;
    elseif isfield(test, 'events')
        events = test.events;
    else
        warning('%d: %s does not have events', k, eventFiles{k});
        continue;
    end
    save(eventFiles{k}, 'events', '-v7.3');
    csvFileName = [eventDirOut filesep theName '.csv'];
    fid = fopen(csvFileName, 'w');
    for n = 1:size(events, 1)
        fprintf(fid, '%12.3f, %12.3f\n', events(n, 1), events(n, 2));
    end
    fclose(fid);
end
