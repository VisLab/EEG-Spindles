%% Extracts spindle properties for various expert ratings
collection = 'mass';
dataDir = 'D:\TestData\Alpha\spindleData\massNew';
baseAlgorithm = 'spindler';
% collection = 'dreams';
% dataDir = 'D:\TestData\Alpha\spindleData\dreams';
experts = {'combined', 'expert1', 'expert2'};
summaryDir = 'D:\TestData\Alpha\spindleData\summaryUnsupervised';
crossFraction = 0.5;
propertyNames = {'SpindleFraction', 'Spindle length(s)', 'Spindles/min'}; %#ok<NASGU>
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
propertyNames = {'Fraction spindling', 'Spindle length (s)', 'Spindles/min'};
numProperties = length(propertyNames);
for n = 1:numExperts
    spindleProperties = nan(numFiles, numProperties);
    spindlePropertiesFirst = nan(numFiles, numProperties);
    spindlePropertiesSecond = nan(numFiles, numProperties);
    eventSummary = cell(numFiles, 1);
    totalTimes = nan(numFiles, 1);
    samplingRates = nan(numFiles, 1);
    dirName = [dataDir filesep 'results_' baseAlgorithm '_' experts{n}];
    for m = 1:numFiles
        fileName = [dirName filesep fileNames{m} '.mat'];
        if ~exist(fileName, 'file')
            continue;
        end
        test = load(fileName);
       
        eventSummary{m} = test.expertEvents;
        
        totalTimes(m) = test.additionalInfo.totalTime;
        samplingRates(m) = test.additionalInfo.srate;
        if isempty(eventSummary{m})
            continue;
        end
        [sFraction, sLength, sRate] = ...
            getEventProperties(eventSummary{m}, totalTimes(m));
       
        spindleProperties(m, :) = [sFraction, sLength, sRate];
        
        newEvents = getEventsOnInterval(eventSummary{m}, 0, ...
            totalTimes(m)*crossFraction);
        if ~isempty(newEvents)
        [sFraction, sLength, sRate] = ...
            getEventProperties(newEvents, totalTimes(m)*crossFraction);
        spindlePropertiesFirst(m, :) = [sFraction, sLength, sRate];
        end
        newEvents = getEventsOnInterval(eventSummary{m}, ...
            totalTimes(m)*crossFraction, totalTimes(m));
        if ~isempty(newEvents)
        [sFraction, sLength, sRate] = ...
            getEventProperties(newEvents, totalTimes(m)*(1 - crossFraction));
        spindlePropertiesSecond(m, :) = [sFraction, sLength, sRate];
        end
    
    end
    outName = [collection '_properties_' experts{n} '.mat'];
    save([summaryDir filesep outName], 'totalTimes', 'samplingRates',  ...
       'eventSummary', 'spindleProperties', 'crossFraction',  'propertyNames', ...
       'spindlePropertiesFirst', 'spindlePropertiesSecond',  '-v7.3');
end      