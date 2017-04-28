dreamsAlgs = {'Spindler', 'Asd', 'Tsanas_a7', 'Tsanas_a8', 'Wendt'};
drivingAlgs = {'Spindler', 'Asd', 'Tsanas_a7', 'Tsanas_a8'};
resultsDirBase = {'D:\TestData\Alpha\spindleData\bcit\results'; ...
                  'D:\TestData\Alpha\spindleData\nctu\results'};
algNames = drivingAlgs;

algColors = [0.8, 0.8, 0.2; 0, 0.7, 0.9; 0, 0, 0.7; 0, 0.6, 0];
statNames = {'Spindles/sec', 'Average spindle length', 'Fraction of time spindling'};


%% Consolidate the data from the files
numAlgs = length(algNames);
numTypes = length(resultsDirBase);
eventLists = cell(numAlgs, numTypes);
numStats = length(statNames);
numDatasets = zeros(numAlgs, numTypes);
for k = 2%1:numAlgs
    for m = 1:numTypes
        resultsDir = [resultsDirBase{m} algNames{k}];
        resultFiles = getFiles('FILES', resultsDir, '.mat');
        eventStatistics = zeros(length(resultFiles), numStats);
        numDatasets(k, m) = length(resultFiles);
        for n = 1:length(resultFiles)
            test = load(resultFiles{n});
            events = test.events;
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

%% 
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
    
% 
% 
% %% Create the array of performance values
%     results = zeros(length(algNames), length(metricNames), length(resultFiles));
%     upperBounds = zeros(length(methodNames), length(metricNames), length(resultFiles));
%     dataNames = cell(length(resultFiles), 1);
%     for k = 1:length(resultFiles)
%        test = load(resultFiles{k});
%        dataNames{k} = test.params.name;
%        results(:, :, k) = consolidate(test.metrics, methodNames, metricNames); 
%        if isfield(test, 'additionalInfo') && isfield(test.additionalInfo, 'allMetrics')
%            upperBounds(:, :, k) = getUpperBound( ...
%                test.additionalInfo.allMetrics, methodNames, metricNames);
%        end
%     end
% end
% 
% % [results, dataNames, upperBounds] = consolidateResults(resultsDir, methodNames, metricNames);
% % save(summaryFile, 'results', 'dataNames', 'methodNames', ...
% %     'metricNames', 'upperBounds', '-v7.3');
% % 
% % %% Read in all of the summary data
% % dreamsResults = cell(length(dreamsAlgs), 1);
% % for k = 1:length(dreamsResults)
% %     dreamsResults{k} = load([resultsDir filesep 'dreams_' dreamsAlgs{k} '_Summary.mat']);
% %     dreamsResults{k}.algorithm = dreamsAlgs{k};
% % end
% % drivingResults = cell(2*length(drivingAlgs), 1);
% % for k = 1:length(drivingAlgs)
% %     drivingResults{k} = load([resultsDir filesep 'bcit_' drivingAlgs{k} '_Summary.mat']);
% %     drivingResults{k}.algorithm = [drivingAlgs{k} '_bcit'];
% %     
% %     drivingResults{length(drivingAlgs) + k} = load([resultsDir filesep 'nctu_' drivingAlgs{k} '_Summary.mat']);
% %     drivingResults{length(drivingAlgs) + k}.algorithm = [drivingAlgs{k} '_nctu'];
% % end
% % 
% % %% Construct dreams summary matrix for plotting
% % numberMethods = length(dreamsResults{1}.methodNames);
% % numberFiles = length(dreamsResults{1}.dataNames);
% % numberAlgs = length(dreamsAlgs);
% % numberMetrics = 3;
% % dreams = zeros(numberFiles - 2, numberMethods, numberAlgs, numberMetrics);
% % for k = 1:numberAlgs
% %     theseResults = dreamsResults{k}.results;
% %     for n = 1:numberMetrics
% %         for j = 1:numberFiles - 2
% %             for m = 1:numberMethods
% %                 dreams(j, m, k, n) = theseResults(m, n, j);
% %             end
% %         end
% %     end
% % end
% % 
% % %% Plot the dreams summary
% % theTitle = 'Dreams performance';
% % for n = 1:numberMetrics
% %     metricName = metricNames{n};
% %     theseResults = squeeze(dreams(:, :, :, n));
% %     figHan = compareMetric(theseResults, metricName, dreamsAlgs, algColors, theTitle, dreamsResults);
% % end
% % 
% % %% Construct driving results
% % numberMethods = length(drivingResults{1}.methodNames);
% % numberFiles = length(drivingResults{1}.dataNames);
% % numberAlgs = length(drivingAlgs);
% % numberMetrics = length(metricNames);
% % driving1 = zeros(numberFiles, numberMethods, numberAlgs, numberMetrics);
% % for k = 1:numberAlgs
% %     theseResults = drivingResults{k}.results;
% %     for n = 1:numberMetrics
% %         for j = 1:numberFiles
% %             for m = 1:numberMethods
% %                 driving1(j, m, k, n) = theseResults(m, n, j);
% %             end
% %         end
% %     end
% % end
% % drivingResults2 = drivingResults(numberAlgs + 1:end);
% % numberMethods = length(drivingResults2{1}.methodNames);
% % numberFiles = length(drivingResults2{1}.dataNames);
% % numberAlgs = length(drivingAlgs);
% % numberMetrics = 3;
% % driving2 = zeros(numberFiles, numberMethods, numberAlgs, numberMetrics);
% % for k = 1:numberAlgs
% %     theseResults = drivingResults2{k}.results;
% %     for n = 1:numberMetrics
% %         for j = 1:numberFiles
% %             for m = 1:numberMethods
% %                 driving2(j, m, k, n) = theseResults(m, n, j);
% %             end
% %         end
% %     end
% % end
% % driving = [driving1; driving2];
% % 
% % %% Plot the summary performance
% % theTitle = 'Driving performance';
% % for n = 1:numberMetrics
% %     metricName = metricNames{n};
% %     theseResults = squeeze(driving(:, :, :, n));
% %     figHan = compareMetric(theseResults, metricName, drivingAlgs, algColors, theTitle, drivingResults);
% % end
