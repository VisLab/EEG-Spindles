%% Rename stage2Events as events for MASS

%% Stage2Event directory
dirName = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';

%% Load the files
eventFiles = getFileListWithExt('FILES', dirName, '.mat');

%% Rename the event structures
for k = 1:length(eventFiles)
    temp = load(eventFiles{k});
    events = temp.stage2Events;
    save(eventFiles{k}, 'events', '-v7.3');
end