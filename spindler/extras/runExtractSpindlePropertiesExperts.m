%% Extracts spindle properties for various expert ratings
% collection = 'mass';
% dataDir = 'D:\TestData\Alpha\spindleData\massNew';
collection = 'dreams';
dataDir = 'D:\TestData\Alpha\spindleData\dreams';
experts = {'combined', 'expert1', 'expert2'};
summaryDir = 'D:\TestData\Alpha\spindleData\summaryUnsupervised';

%% Make the summary directory if it doesn't exist
if ~exist(summaryDir, 'dir')
    mkdir(summaryDir);
end

%% Get the data files
dataFiles = getFileListWithExt('FILES', [dataDir filesep 'data'], '.set');
numFiles = length(dataFiles);
fileNames = cell(numFiles, 1);
for k = 1:numFiles
    [~, fileNames{k}, ~] = fileparts(dataFiles{k});
end

%% Now extract the values
numExperts = length(experts);
for n = 1:numExperts
    spindleFraction = nan(numFiles, 1);
    spindleLength = nan(numFiles, 1);
    spindleRate = nan(numFiles, 1);
    eventSummary = cell(numFiles, 1);
    totalTimes = nan(numFiles, 1);
    srates = nan(numFiles, 1);
    startFrames = nan(numFiles, 1);
    endFrames = nan(numFiles, 1);
    dirName = [dataDir filesep 'events' filesep experts{n}];
    for m = 1:numFiles
        fileName = [dirName filesep fileNames{m} '.mat'];
        if ~exist(fileName, 'file')
            continue;
        end
        test = load(fileName);
        eventSummary{m} = test.events;
        srates(m) = EEG.srate;
        startFrames(m) = 1;
        endFrames(m) = size(EEG.data, 2);
        %% Load the EEG file to get the total time
        EEG = pop_loadset(dataFiles{m});
        totalTimes(m) = (endFrames(m) - 1)./srates(m);
        [spindleFraction(m), spindleLength(m), spindleRate(m)] = ...
            getEventProperties(eventSummary{m}, totalTimes(m));
       
    end
    outName = [collection '_properties_' experts{n} '.mat'];
    save([summaryDir filesep outName], 'totalTimes', 'eventSummary', ...
       'spindleFraction', 'spindleLength', 'spindleRate',  '-v7.3');
end      