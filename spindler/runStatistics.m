dreamsAlgs = {'Spindler', 'Asd', 'Tsanas_a7', 'Tsanas_a8', 'Wendt'};
drivingAlgs = {'Spindler', 'Asd', 'Tsanas_a7', 'Tsanas_a8'};
drivingAlgsSupervised = {'Spindler', 'Sdar'};
drivingDirBase = {'D:\TestData\Alpha\spindleData\bcit\results'; ...
                  'D:\TestData\Alpha\spindleData\nctu\results'};
dreamsDirBase = {'D:\TestData\Alpha\spindleData\dreams\results'};
algColors = [0.8, 0.8, 0.2; 0, 0.7, 0.9; 0, 0, 0.7; 0, 0.6, 0];
methodNames = {'hitMetrics', 'intersectMetrics', 'onsetMetrics', 'timeMetrics'};
metricNames = {'f1', 'f2', 'g'};
[drivingStatsSupervised, drivingNamesSupervised] = ...
        getSummaryStatisticsSupervised(drivingDirBase, drivingAlgs, ...
                                     methodNames, metricNames);
% [drivingStats, statNames1] = getSummaryStatistics(drivingDirBase, drivingAlgs);
% [dreamsStats, statNames2] = getSummaryStatistics(dreamsDirBase, dreamsAlgs);
% 
% 
% %% Plot the Driving statistics
% statsBase = squeeze(drivingStats(1, :, :));
% statsOthers = squeeze(drivingStats(2, :, :));
% baseAlgorithm = drivingAlgs{1};
% otherAlgorithms = drivingAlgs(2);
% for k = 1:length(statNames1)
%     theTitle = 'Driving';
%     figHan = compareStatistic(squeeze(statsBase(:, k)), ...
%          squeeze(statsOthers(:, k)), statNames1{k}, ...
%          baseAlgorithm, otherAlgorithms, algColors, theTitle);
% end
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
