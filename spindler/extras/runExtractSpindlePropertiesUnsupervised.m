%% Extracts data for a particular collection of unsupervised algorithms
collection = 'mass';
dataDir = 'D:\TestData\Alpha\spindleData\massNew';
% collection = 'dreams';
% dataDir = 'D:\TestData\Alpha\spindleData\dreams';
algorithms = {'spindler', 'cwta7', 'cwta8', 'sem'};
expert = 'expert1';
baseMetricName = 'f1';
methodName = 'time';
summaryDir = 'D:\TestData\Alpha\spindleData\summaryUnsupervised';
propertyFileBase = [summaryDir filesep collection '_properties_'];
crossFraction = 0.5;

%% Get the data files
dataFiles = getFileListWithExt('FILES', [dataDir filesep 'data'], '.set');
numFiles = length(dataFiles);
fileNames = cell(numFiles, 1);
for k = 1:numFiles
    [~, fileNames{k}, ~] = fileparts(dataFiles{k});
end

%% Now extract the values
numAlgorithms = length(algorithms);
propertyNames = {'Fraction spindling', 'Spindle length (s)', 'Spindles/min'};
numProperties = length(propertyNames);
for k = 1:numAlgorithms
    spindleProperties = nan(numFiles, numProperties);
    spindlePropertiesFirst = nan(numFiles, numProperties);
    spindlePropertiesSecond = nan(numFiles, numProperties);
    eventSummary = cell(numFiles, 1);
    totalTimes = nan(numFiles, 1);
    srates = nan(numFiles, 1);
    startFrames = nan(numFiles, 1);
    endFrames = nan(numFiles, 1);
    dirName = [dataDir filesep 'results_' algorithms{k} '_' expert];
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
        [sFraction, sLength, sRate] = ...
            getEventProperties(eventSummary{m}, totalTimes(m));
        spindleProperties(m, :) = [sFraction, sLength, sRate];
        newEvents = getEventsOnInterval(eventSummary{m}, 0, ...
            totalTimes(m)*crossFraction);
        [sFraction, sLength, sRate] = ...
            getEventProperties(newEvents, totalTimes(m)*crossFraction);
        spindlePropertiesFirst(m, :) = [sFraction, sLength, sRate];
        newEvents = getEventsOnInterval(eventSummary{m}, ...
            totalTimes(m)*crossFraction, totalTimes(m));
        [sFraction, sLength, sRate] = ...
            getEventProperties(newEvents, totalTimes(m)*(1 - crossFraction));
        spindlePropertiesSecond(m, :) = [sFraction, sLength, sRate];
    end
    outName = [collection '_properties_' algorithms{k} '.mat'];
    save([summaryDir filesep outName], 'totalTimes', 'eventSummary', ...
       'spindleProperties', 'crossFraction', 'spindlePropertiesFirst', ...
       'spindlePropertiesSecond',  '-v7.3');
end