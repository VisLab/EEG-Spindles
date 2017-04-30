function [summaryStats1, summaryStats2, statNames] = ...
    getSummaryStatisticsSupervised(baseDirs, algNames, methodNames, metricNames)
%% Consolidate summary statistics from results files named by convention
statNames = {'Spindles/sec', 'Average spindle length', 'Fraction of time spindling'};
numAlgs = length(algNames);
numTypes = length(baseDirs);

numStats = length(statNames);
numDatasets = zeros(numAlgs, numTypes);
numMethods = length(methodNames);
numMetrics = length(metricNames);
eventLists1 = cell(numAlgs, numTypes);
eventLists2 = cell(numAlgs, numTypes);

for k = 1:numAlgs
    for m = 1:numTypes
        resultsDir = [baseDirs{m} algNames{k} 'Supervised'];
        resultFiles = getFiles('FILES', resultsDir, '.mat');
        numFiles = length(resultFiles);
        stats1 = zeros(numMethods, numMetrics, numFiles, numStats);
        stats2 = zeros(numMethods, numMetrics, numFiles, numStats);
        for n = 1:numFiles
            test = load(resultFiles{n});
            frames1 = test.params1.frames;
            srate1 = test.params1.srate;
            frames2 = test.params2.frames;
            srate2 = test.params2.srate;
            datasetTime1 = (frames1 - 1)/srate1;
            datasetTime2 = (frames2 - 1)/srate2;
            optimalEvents1 = test.additionalInfo.expertEvents1;
            expertEvents2 = test.additionalInfo.expertEvents2;
            [numMethods, numMetrics] = size(expertEvents1);
            numDatasets(k, m) = length(resultFiles);
            for i = 1:numMethods
                for j = 1:numMetrics
                    events1 = expertEvents1{i, j};
                    if ~isempty(events1)
                        timeInEvents = sum(events1(:, 2) - events1(:, 1));
                        numberEvents = size(events1, 1);
                        stats1(i, j, n, 1) = numberEvents/datasetTime1;
                        stats1(i, j, n, 2) = timeInEvents/numberEvents;
                        stats1(i, j, n, 3) = timeInEvents/datasetTime1;
                    end
                    events2 = expertEvents2{i, j};
                    if ~isempty(events2)
                        timeInEvents = sum(events2(:, 2) - events2(:, 1));
                        numberEvents = size(events2, 1);
                        stats2(i, j, n, 1) = numberEvents/datasetTime2;
                        stats2(i, j, n, 2) = timeInEvents/numberEvents;
                        stats2(i, j, n, 3) = timeInEvents/datasetTime2;
                    end
                end
            end
        end
        eventLists1{k, m} = stats1;
        eventLists2{k, m} = stats2;
    end
end

totalDatasets = sum(numDatasets(1, :));
summaryStats1 = zeros(numAlgs, numMethods, numMetrics, totalDatasets, numStats);
summaryStats2 = zeros(numAlgs, numMethods, numMetrics, totalDatasets, numStats);

for k = 1:numAlgs
    for i = 1:numMethods;
        for j = 1:numMetrics
           dStart = 1;
           for m = 1:numTypes
              theseStats1 = eventLists1{k, m};
              theseStats2 = eventLists2{k, m};
              dEnd = dStart + size(theseStats, 3) - 1;
              summaryStats1(k, i, j, dStart:dEnd, :) = theseStats1(i, j, :, :);
              summaryStats2(k, i, j, dStart:dEnd, :) = theseStats2(i, j, :, :);
              dStart = dEnd + 1;
           end
        end
    end
end