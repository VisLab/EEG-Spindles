%% Read the annotation files for sleep stages

%% Set up the locations
inDir = 'D:\TestData\Alpha\spindleData\massNew\events\base';
outDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';

%% Make sure output directory exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get the list of EYE filenames from level 0
fileNames = getFileListWithExt('FILES', inDir, '.mat');

%% Extract the stage 2 event list
for k = 1:length(fileNames)
    test = load(fileNames{k});
    events = test.events;
    eventTypes = test.eventTypes;
    stage2Events = getStageList(events, eventTypes, '2');
    [thePath, theName, theExt] = fileparts(fileNames{k});
    save([outDir filesep theName(1:11) 'PSG.mat'], 'stage2Events', '-v7.3');
end