%% Extracts data for a particular collection
collection = 'mass';
dataDir = 'D:\TestData\Alpha\spindleData\massNew';
% collection = 'dreams';
% dataDir = 'D:\TestData\Alpha\spindleData\dreams';
algorithm = 'spindler';
expert = 'combined';
summaryDir = 'D:\TestData\Alpha\spindleData\summaryUnsupervised';

%% Get the data files
dataFiles = getFileListWithExt('FILES', [dataDir filesep 'data'], '.set');
numFiles = length(dataFiles);
fileNames = cell(numFiles, 1);
for k = 1:numFiles
    [~, fileNames{k}, ~] = fileparts(dataFiles{k});
end

%% Now extract the values
spindleFraction = nan(numFiles, 1);
spindleLength = nan(numFiles, 1);
spindleRate = nan(numFiles, 1);
eventSummary = cell(numFiles, 1);
totalTimes = nan(numFiles, 1);
srates = nan(numFiles, 1);
startFrames = nan(numFiles, 1);
endFrames = nan(numFiles, 1);
dirName = [dataDir filesep 'results_' algorithm '_' expert];
for m = 1:numFiles
    fileName = [dirName filesep fileNames{m} '.mat'];
    if ~exist(fileName, 'file')
        continue;
    end
    test = load(fileName);
    eventSummary{m} = test.events;
    startFrames(m) = test.additionalInfo.startFrame;
    endFrames(m) = test.additionalInfo.endFrame;
    srates(m) = test.additionalInfo.srate;
    totalTimes(m) = (endFrames(m) - startFrames(m))./srates(m);
    [spindleFraction(m), spindleLength(m), spindleRate(m)] = ...
        getEventProperties(eventSummary{m}, totalTimes(m));
    
end
outName = [collection '_properties_' algorithms{k} '.mat'];
save([summaryDir filesep outName], 'totalTimes', 'eventSummary', ...
    'spindleFraction', 'spindleLength', 'spindleRate',  '-v7.3');

