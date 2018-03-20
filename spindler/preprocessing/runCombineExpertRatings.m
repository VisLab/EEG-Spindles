%% Computes the union of expert annotations to compute a single annotation
%% This function assumes that files are named similarly

%% Set up the locations for MASS dataset
% inDir1 = 'D:\TestData\Alpha\spindleData\mass\events\spindlesE1';
% inDir2 = 'D:\TestData\Alpha\spindleData\mass\events\spindlesE2';
% outDir = 'D:\TestData\Alpha\spindleData\mass\events\spindlesAll';

%% Set up the locations for the DREAMS dataset
inDir1 = 'D:\TestData\Alpha\spindleData\dreams\events\expert1';
inDir2 = 'D:\TestData\Alpha\spindleData\dreams\events\expert2';
outDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';

%% Specify the method of combining overlapping events
method = 'union';
%method = 'longest';
%% Make sure output directory exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end;

%% Get the list of EYE filenames from level 0
filePaths1 = getFiles('FILES', inDir1, '.mat');
fileNames1 = cell(1, length(filePaths1));
for k = 1:length(fileNames1)
   [~, fileNames1{k}, ~] = fileparts(filePaths1{k});
end
filePaths2 = getFiles('FILES', inDir2, '.mat');
fileNames2 = cell(1, length(filePaths2));
for k = 1:length(fileNames2)
   [~, fileNames2{k}, ~] = fileparts(filePaths2{k});
end
uniqueNames = union(fileNames1, fileNames2);

%% Match expert event files with EEG files
for k = 1:length(uniqueNames)
    file1 = [inDir1 filesep uniqueNames{k} '.mat'];
    if exist(file1, 'file')
        test1 = load(file1);
        events1 = test1.events;
        srate1 = test1.srate;
        frames1 = test1.numFrames;
    else
        events1 = [];
        srate1 = [];
        frames1 = [];
    end
    file2 = [inDir2 filesep uniqueNames{k} '.mat'];
    if exist(file2, 'file')
        test2 = load(file2);
        events2 = test2.events;
        srate2 = test2.srate;
        frames2 = test2.numFrames;    
    else
        events2 = [];
        srate2 = [];
        frames2 = [];
    end
    events = [events1; events2];
    events = mergeExpertRatings(events, method);
    if isempty(srate2)
        srate = srate1;
        numFrames = frames1;
    elseif isempty(srate1)
        srate = srate2;
        numFrames = frames2;
    else
        srate = srate1;
        numFrames = max(frames1, frames2);
        if srate1 ~= srate2
            warning('%d: raters have different sampling rates', k);
        elseif frames1 ~= frames2
            warning('%d: raters have different number of frames', k);
        end
    end
    save([outDir filesep uniqueNames{k} '.mat'], 'events', 'srate', ...
        'numFrames', '-v7.3')
end