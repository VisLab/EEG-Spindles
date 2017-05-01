%% Script to compare the supervised versions of the algorithms

resultsDir = 'D:\TestData\Alpha\spindleData\resultSummarySupervised';
dreamsAlgs = {'Spindler', 'Sdar'};
drivingAlgs = {'Spindler', 'Sdar'};
%algColors = [0.8, 0.8, 0.2; 0, 0.7, 0.9; 0, 0, 0.7; 0, 0.6, 0];
algColors = [0, 0, 0.7; 0, 0.7, 0.9; 0, 0.6, 0];
algColorsOptimal = [0.8, 0.8, 0.2; 0.8, 0.8, 0.8];
metricNames = {'F1', 'F2', 'G'};
methodLegends = {'H', 'I', 'O', 'T'};
methodMarkers = {'o', 's', '^', 'v'};
% methodIndices = 1:4;
methodIndices = 2:4;
%% Read in all of the summary data
dreamsResults = cell(length(dreamsAlgs), 1);
for k = 1:length(dreamsResults)
    dreamsResults{k} = load([resultsDir filesep 'dreams_' dreamsAlgs{k} '_Summary_Supervised.mat']);
    dreamsResults{k}.algorithm = dreamsAlgs{k};
end
drivingResults = cell(length(drivingAlgs), 1);
for k = 1:length(drivingAlgs)
    drivingResults{k} = load([resultsDir filesep 'bcit_' drivingAlgs{k} '_Summary_Supervised.mat']);
    drivingResults{k}.algorithm = [drivingAlgs{k} '_bcit_Supervised'];
    
    drivingResults{length(drivingAlgs) + k} = load([resultsDir filesep 'nctu_' drivingAlgs{k} '_Summary_Supervised.mat']);
    drivingResults{length(drivingAlgs) + k}.algorithm = [drivingAlgs{k} '_nctu_Supervised_'];
end

% %% Construct dreams summary matrix for plotting
numberMethods = length(dreamsResults{1}.methodNames);
numberFiles = length(dreamsResults{1}.dataNames);
numberAlgs = length(dreamsAlgs);
numberMetrics = 3;
dreams = zeros(numberFiles - 2, numberMethods, numberAlgs, numberMetrics);
dreamsOptimal = zeros(numberFiles - 2, numberMethods, numberAlgs, numberMetrics);
for k = 1:numberAlgs
    theseResults = dreamsResults{k}.results;
    theseOptimal = dreamsResults{k}.upperBounds;
    for n = 1:numberMetrics
        for j = 1:numberFiles - 2
            for m = 1:numberMethods
                dreams(j, m, k, n) = theseResults(m, n, j);
                dreamsOptimal(j, m, k, n) = theseOptimal(m, n, j);
            end
        end
    end
end

%% Plot the dreams summary
dreams = squeeze(dreams(:, methodIndices, :, :));
dreamsOptimal = squeeze(dreamsOptimal(:, methodIndices, :, :));
theTitle = 'Dreams performance';
for n = 1:numberMetrics
    metricName = metricNames{n};
    theseResults = squeeze(dreams(:, :, :, n));
    theseResultsOptimal = squeeze(dreamsOptimal(:, :, :, n));
    figHan = compareMetricSupervised(theseResults, theseResultsOptimal, ...
           metricName, drivingAlgs, algColors, algColorsOptimal, ...
           methodLegends(methodIndices), methodMarkers(methodIndices), theTitle);
end

%% Construct driving results
numberMethods = length(drivingResults{1}.methodNames);
numberFiles = length(drivingResults{1}.dataNames);
numberAlgs = length(drivingAlgs);
numberMetrics = length(metricNames);
driving1 = zeros(numberFiles, numberMethods, numberAlgs, numberMetrics);
driving1Optimal = zeros(numberFiles, numberMethods, numberAlgs, numberMetrics);
for k = 1:numberAlgs
    theseResults = drivingResults{k}.results;
    theseOptimal = drivingResults{k}.upperBounds;
    for n = 1:numberMetrics
        for j = 1:numberFiles
            for m = 1:numberMethods
                driving1(j, m, k, n) = theseResults(m, n, j);
                driving1Optimal(j, m, k, n) = theseOptimal(m, n, j);
            end
        end
    end
end

drivingResults2 = drivingResults(numberAlgs + 1:end);
numberMethods = length(drivingResults2{1}.methodNames);
numberFiles = length(drivingResults2{1}.dataNames);
numberAlgs = length(drivingAlgs);
numberMetrics = 3;
driving2 = zeros(numberFiles, numberMethods, numberAlgs, numberMetrics);
driving2Optimal = zeros(numberFiles, numberMethods, numberAlgs, numberMetrics);
for k = 1:numberAlgs
    theseResults = drivingResults2{k}.results;
    theseOptimal = drivingResults2{k}.upperBounds;
    for n = 1:numberMetrics
        for j = 1:numberFiles
            for m = 1:numberMethods
                driving2(j, m, k, n) = theseResults(m, n, j);
                driving2Optimal(j, m, k, n) = theseOptimal(m, n, j);
            end
        end
    end
end
driving = [driving1; driving2];
drivingOptimal = [driving1Optimal; driving2Optimal];

%% Plot the summary performance
theTitle = 'Driving performance';
driving = squeeze(driving(:, methodIndices, :, :));
drivingOptimal = squeeze(drivingOptimal(:, methodIndices, :, :));
for n = 1:numberMetrics
    metricName = metricNames{n};
    theseResults = squeeze(driving(:, :, :, n));
    theseResultsOptimal = squeeze(drivingOptimal(:, :, :, n));
    figHan = compareMetricSupervised(theseResults, theseResultsOptimal, ...
           metricName, drivingAlgs, algColors, algColorsOptimal, ...
           methodLegends(methodIndices), methodMarkers(methodIndices), theTitle);
end
