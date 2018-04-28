%% Read the expert ratings for mass spindles from CR provided CSV files
inDir1 = 'D:\TestData\Alpha\spindleData\massNew\events\expert1';
inDir2 = 'D:\TestData\Alpha\spindleData\massNew\events\expert1FromCSV';

%% Get the list of EYE filenames from level 0
fileNames = getFileListWithExt('FILES', inDir1, '.mat');

%% Process
for k = 1:length(fileNames)
    test = load(fileNames{k});
    events1 = test.events;
    [~, theName, ~] = fileparts(fileNames{k});
    test = load([inDir2 filesep theName '.mat']);
    events2 = test.events;
    
    if length(events1) ~= length(events2)
        fprintf('%d %s: the number of events does not match\n', k, theName);
        continue;
    end
    eventDiff = abs(events1 - events2);
    maxDiff = max(eventDiff(:));
    fprintf('%d %s: max difference = %g\n', k, theName, maxDiff);
end