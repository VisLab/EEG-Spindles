%% Computes the union of expert annotations to compute a single annotation
%% This function assumes that files are named similarly

%% Set up the locations for MASS dataset
inDirs = {'D:\TestData\Alpha\spindleData\massNew\events\expert1'; ...
    'D:\TestData\Alpha\spindleData\massNew\events\expert2'};
outDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';

%% Set up the locations for the DREAMS dataset
% inDir1 = 'D:\TestData\Alpha\spindleData\dreams\events\expert1';
% inDir2 = 'D:\TestData\Alpha\spindleData\dreams\events\expert2';
% outDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';

%% Specify the method of combining overlapping events
method = 'union';
%method = 'longest';
%% Make sure output directory exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get the list of EYE filenames from level
filePaths = cell(length(inDirs), 1);
fileNames = cell(length(inDirs), 1);
uniqueNames = {};
for k = 1:length(inDirs)
    theseFiles = getFileListWithExt('FILES', inDirs{k}, '.mat');
    theNames = cell(length(theseFiles), 1);
    for n = 1:length(theNames)
        [~, theNames{n}, ~] = fileparts(theseFiles{n});
    end
    filePaths{k} = theseFiles;
    fileNames{k} = theNames;
    uniqueNames = union(uniqueNames, theNames);
end

%% Match expert event files with EEG files
for k = 1:length(uniqueNames)
    events = [];
    for n = 1:length(inDirs)
        nextFile = [inDirs{n} filesep uniqueNames{k} '.mat'];
        
        if ~exist(nextFile, 'file')
            continue;
        end
        test = load(nextFile);
        events = [events; test.events]; %#ok<*AGROW>
    end
    eventsTemp = events;
    events = mergeExpertRatings(events, method);
    save([outDir filesep uniqueNames{k} '.mat'], 'events', '-v7.3');
end