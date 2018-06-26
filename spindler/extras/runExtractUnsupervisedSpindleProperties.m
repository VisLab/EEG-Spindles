%% Extracts data for a particular collection
collection = 'mass';
dataDir = 'D:\TestData\Alpha\spindleData\massNew';
% collection = 'dreams';
% dataDir = 'D:\TestData\Alpha\spindleData\dreams';
algorithms = {'cwta7', 'cwta8', 'sem'};
eventExts = {'combined', 'expert1', 'expert2'};
summaryDir = 'D:\TestData\Alpha\spindleData\summaryUnsupervised';

%% Get the data files
dataFiles = getFileListWithExt('FILES', [dataDir filesep 'data'], '.set');
numFiles = length(dataFiles);
fileNames = cell(numFiles, 1);
for k = 1:numFiles
    [~, fileNames{k}, ~] = fileparts(dataFiles{k});
end

%% Now extract the values
numAlgorithms = length(algorithms);
numExperts = length(eventExts);
for k = 1:numAlgorithms
    for n = 1:numExperts
        spindleFraction = nan(numFiles, 1);
        spindleLength = nan(numFiles, 1);
        spindleRate = nan(numFiles, 1);
        expertFraction = nan(numFiles, 1);
        expertLength = nan(numFiles, 1);
        expertRate = nan(numFiles, 1);
        dirName = [dataDir filesep 'results_' algorithms{k} '_' eventExts{n}];
        for m = 1:numFiles
            fileName = [dirName filesep fileNames{m} '.mat'];
            if ~exist(fileName, 'file')
                continue;
            end
            test = load(fileName);
            events = test.events;
            expertEvents = test.expertEvents;
            totalTime = (test.additionalInfo.endFrame - ...
                test.additionalInfo.startFrame)./ ...
                test.additionalInfo.srate;
            [spindleFraction(m), spindleLength(m), spindleRate(m)] = ...
                getEventProperties(events, totalTime);
            [expertFraction(m), expertLength(m), expertRate(m)] = ...
                getEventProperties(expertEvents, totalTime);
        end
        outName = [collection '_' eventExts{n} '_' algorithms{k} ...
            '_properties.mat'];
        save([summaryDir filesep outName], 'events', 'expertEvents', ...
            'totalTime', 'spindleFraction', 'spindleLength', ...
            'spindleRate', 'expertFraction', 'expertLength', ...
            'expertRate', '-v7.3');
    end
end         