function [summaryStatistics, statNames] = getSummaryStatistics(baseDirs, algNames)
%% Consolidate summary statistics from results files named by convention
   
statNames = {'Spindles/sec', 'Average spindle length', 'Fraction of time spindling'};
numAlgs = length(algNames);
numTypes = length(baseDirs);
eventLists = cell(numAlgs, numTypes);
numStats = length(statNames);
numDatasets = zeros(numAlgs, numTypes);
for k = 1:numAlgs
    for m = 1:numTypes
        resultsDir = [baseDirs{m} algNames{k}];
        resultFiles = getFiles('FILES', resultsDir, '.mat');
        eventStatistics = zeros(length(resultFiles), numStats);
        numDatasets(k, m) = length(resultFiles);
        for n = 1:length(resultFiles)
            test = load(resultFiles{n});
            events = test.events;
            if isempty(events)
                continue;
            end
            frames = test.params.frames;
            srate = test.params.srate;
            datasetTime = (frames - 1)/srate;
            timeInEvents = sum(events(:, 2) - events(:, 1));
            numberEvents = size(events, 1);
            eventStatistics(n, 1) = numberEvents/datasetTime;
            eventStatistics(n, 2) = timeInEvents/numberEvents;
            eventStatistics(n, 3) = timeInEvents/datasetTime;
        end
        eventLists{k, m} = eventStatistics;
    end
end

totalDatasets = sum(numDatasets(1, :));
summaryStatistics = zeros(numAlgs, totalDatasets, numStats);

for k = 1:numAlgs
    dStart = 1;
    for m = 1:numTypes
        theseStats = eventLists{k, m};
        dEnd = dStart + size(theseStats, 1) - 1;
        summaryStatistics(k, dStart:dEnd, :) = theseStats;
        dStart = dEnd + 1;
    end
end