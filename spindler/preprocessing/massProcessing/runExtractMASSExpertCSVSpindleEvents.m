%% Read the expert ratings for mass spindles from CR provided CSV files
% inDir = 'D:\TestData\Alpha\spindleData\massNew\eventsCSV\expert1';
% outDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert1FromCSV';

inDir = 'D:\TestData\Alpha\spindleData\massNew\eventsCSV\expert2';
outDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert2FromCSV';
%% Make sure output directory exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get the list of EYE filenames from level 0
fileNames = getFileListWithExt('FILES', inDir, '.csv');

%% Process
srate = [];
eventTypes = {};
for k = 1:length(fileNames)
    data = csvread(fileNames{k}, 1, 0);
    [thePath, theName, theExt] = fileparts(fileNames{k});
    events = [data(:, 2), data(:, 1) + data(:, 2)];
    save([outDir filesep theName(1:11) 'PSG.mat'], 'events', 'srate', ...
                                           'eventTypes',  '-v7.3');
end