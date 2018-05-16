%% Convert CSV event files to .mat
inDir = 'D:\TestData\Alpha\spindleData\nctu\eventsJohnRerated';
outDir = 'D:\TestData\Alpha\spindleData\nctu\eventsJohnReratedMAT';

%% Create the out directory
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get the file names
fileNames = getFileListWithExt('FILES', inDir, '.csv');

%% Process the files
for k = 1:length(fileNames)
    events = load(fileNames{k});
    [~, theName, ~] = fileparts(fileNames{k});
    save([outDir filesep theName '.mat'], 'events', '-v7.3');
end