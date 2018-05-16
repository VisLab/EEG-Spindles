%% Script to consolidate and compare performance results across algorithms
%
%  Written by: Kay Robbins, UTSA, 2017
%
%% Set up the parameters
resultsDir = 'D:\TestData\Alpha\spindleData\ResultSummary';
algorithms = {'Spindler', 'Cwt_a7', 'Cwt_a8', 'Sem'};
datasets = {'dreams'};

%drivingAlgs = {'Spindler', 'Asd', 'Cwt_a7', 'Cwt_a8'};

%% Read in all of the summary data
results = cell(length(algorithms), length(datasets));
totalFiles = 0;
for n = 1:length(datasets)
     for k = 1:length(algorithms)
        results{k, n} = load([resultsDir filesep datasets{n} ...
                             '_' algorithms{k} '_Summary.mat']);
        results{k, n}.algorithm = algorithms{k};
     end
    totalFiles = totalFiles + length(results{1, n}.dataNames);
end

%% Construct dreams summary matrix for plotting
numberMethods = length(results{1, 1}.methodNames);
numberMetrics = length(results{1, 1}.metricNames);
numberAlgorithms = length(algorithms);
numberDatasets = length(datasets);
performanceData = zeros(numberAlgorithms, numberMethods, numberMetrics, totalFiles);
for k = 1:numberAlgorithms
    theseResults = results{k, 1}.results;
    for n = 2:numberDatasets
        theseResults = [theseResults; results{k, n}.results]; %#ok<*AGROW>
    end
    performanceData(k, :, :, :) = theseResults;
end
  
% %% Plot the dreams summary
% theTitle = 'Dreams performance';
% for n = 1:numberMetrics
%     metricName = metricNames{n};
%     theseResults = squeeze(dreams(:, :, :, n));
%     figHan = compareMetric(theseResults, metricName, dreamsAlgs, ...
%                            algColors, theTitle);
% end
% 
% %% Perform a paired ttest for statistical significance
% hitIndices = 2:4;
% baseIndex = 1;
% dataSummary = dreams(:, hitIndices, :, :);
% fprintf('\nStatistical significance testing for dreams\n');
% dreamsStats = getPairedStatistics(dataSummary, baseIndex, dreamsAlgs); 
% 
% %% Construct driving results
% numberMethods = length(drivingResults{1}.methodNames);
% numberFiles = length(drivingResults{1}.dataNames);
% numberAlgorithms = length(drivingAlgs);
% numberMetrics = length(metricNames);
% driving1 = zeros(numberFiles, numberMethods, numberAlgorithms, numberMetrics);
% for k = 1:numberAlgorithms
%     theseResults = drivingResults{k}.results;
%     for n = 1:numberMetrics
%         for j = 1:numberFiles
%             for m = 1:numberMethods
%                 driving1(j, m, k, n) = theseResults(m, n, j);
%             end
%         end
%     end
% end
% drivingResults2 = drivingResults(numberAlgorithms + 1:end);
% numberMethods = length(drivingResults2{1}.methodNames);
% numberFiles = length(drivingResults2{1}.dataNames);
% numberAlgorithms = length(drivingAlgs);
% numberMetrics = 3;
% driving2 = zeros(numberFiles, numberMethods, numberAlgorithms, numberMetrics);
% for k = 1:numberAlgorithms
%     theseResults = drivingResults2{k}.results;
%     for n = 1:numberMetrics
%         for j = 1:numberFiles
%             for m = 1:numberMethods
%                 driving2(j, m, k, n) = theseResults(m, n, j);
%             end
%         end
%     end
% end
% driving = [driving1; driving2];
% 
% %% Plot the summary performance
% theTitle = 'Driving performance';
% for n = 1:numberMetrics
%     metricName = metricNames{n};
%     theseResults = squeeze(driving(:, :, :, n));
%     figHan = compareMetric(theseResults, metricName, drivingAlgs, ...
%                            algColors, theTitle);
% end
% 
% %% Perform a paired ttest for statistical significance
% hitIndices = 2:4;
% baseIndex = 1;
% dataSummary = driving(:, hitIndices, :, :);
% fprintf('\nStatistical significance testing for driving\n');
% drivingStats = getPairedStatistics(dataSummary, baseIndex, drivingAlgs); 
