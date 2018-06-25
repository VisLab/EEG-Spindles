%% Script to consolidate and compare performance results across algorithms
%
%  Written by: Kay Robbins, UTSA, 2017
%
%% Example 1: Set up the parameters for comparing algorithms
% resultsDir = 'D:\TestData\Alpha\spindleData\ResultSummary';
% dreamsAlgs = {'Spindler', 'Asd', 'Cwt_a7', 'Cwt_a8', 'Sem'};
% drivingAlgs = {'Spindler', 'Asd', 'Cwt_a7', 'Cwt_a8'};
% drivingTypes = {'', '', '', ''};
% dreamsTypes = {'', '', '', '', ''};

%% Example 2: Set up the parameters for comparing Spindler settings
resultsDir = 'D:\TestData\Alpha\spindleData\ResultSummary';
algorithms = {'Spindler', 'Cwt_a7', 'Cwt_a8', 'Sem'};
ratingTypes = {'Expert1', 'Expert2', ''};

%% Set up algorithms
algColors = [0.8, 0.8, 0.2; 0, 0.7, 0.9; 0, 0, 0.7; 0.8, 0.8, 0.2];
metricNames = {'F1', 'F2', 'G'};

%% Read in all of the summary data
dreamsResults = cell(length(dreamsAlgs), 1);
dreamsBase = [resultsDir filesep 'dreams_'];
for k = 1:length(dreamsResults)
    dreamsFile = [dreamsBase dreamsAlgs{k} '_Summary' dreamsTypes{k} '.mat'];
    dreamsResults{k} = load(dreamsFile);
    dreamsResults{k}.algorithm = dreamsAlgs{k};
end
drivingResults = cell(2*length(drivingAlgs), 1);
bcitBase = [resultsDir filesep 'bcit_'];
nctuBase = [resultsDir filesep 'nctu_'];
for k = 1:length(drivingAlgs)
    bcitFile = [bcitBase drivingAlgs{k} '_Summary' drivingTypes{k} '.mat'];
    drivingResults{k} = load(bcitFile);
    drivingResults{k}.algorithm = [drivingAlgs{k} '_bcit'];
    nctuFile = [nctuBase drivingAlgs{k} '_Summary' drivingTypes{k} '.mat'];
    drivingResults{length(drivingAlgs) + k} = load(nctuFile);
    drivingResults{length(drivingAlgs) + k}.algorithm = [drivingAlgs{k} '_nctu'];
end

%% Construct dreams summary matrix for plotting
numberMethods = length(dreamsResults{1}.methodNames);
numberFiles = length(dreamsResults{1}.dataNames);
numberAlgs = length(dreamsAlgs);
numberMetrics = 3;
dreams = zeros(numberFiles - 2, numberMethods, numberAlgs, numberMetrics);
for k = 1:numberAlgs
    theseResults = dreamsResults{k}.results;
    for n = 1:numberMetrics
        for j = 1:numberFiles - 2
            for m = 1:numberMethods
                dreams(j, m, k, n) = theseResults(m, n, j);
            end
        end
    end
end

%% Plot the dreams summary
theTitle = 'Dreams performance';
for n = 1:numberMetrics
    metricName = metricNames{n};
    theseResults = squeeze(dreams(:, :, :, n));
    figHan = compareMetric(theseResults, metricName, dreamsAlgs, ...
                           algColors, theTitle);
end

%% Perform a paired ttest for statistical significance
hitIndices = 2:4;
baseIndex = 1;
dataSummary = dreams(:, hitIndices, :, :);
fprintf('\nStatistical significance testing for dreams\n');
dreamsStats = getPairedStatistics(dataSummary, baseIndex, dreamsAlgs); 

%% Construct driving results
numberMethods = length(drivingResults{1}.methodNames);
numberFiles = length(drivingResults{1}.dataNames);
numberAlgs = length(drivingAlgs);
numberMetrics = length(metricNames);
driving1 = zeros(numberFiles, numberMethods, numberAlgs, numberMetrics);
for k = 1:numberAlgs
    theseResults = drivingResults{k}.results;
    for n = 1:numberMetrics
        for j = 1:numberFiles
            for m = 1:numberMethods
                driving1(j, m, k, n) = theseResults(m, n, j);
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
for k = 1:numberAlgs
    theseResults = drivingResults2{k}.results;
    for n = 1:numberMetrics
        for j = 1:numberFiles
            for m = 1:numberMethods
                driving2(j, m, k, n) = theseResults(m, n, j);
            end
        end
    end
end
driving = [driving1; driving2];

%% Plot the summary performance
theTitle = 'Driving performance';
for n = 1:numberMetrics
    metricName = metricNames{n};
    theseResults = squeeze(driving(:, :, :, n));
    figHan = compareMetric(theseResults, metricName, drivingAlgs, ...
                           algColors, theTitle);
end

%% Perform a paired ttest for statistical significance
hitIndices = 2:4;
baseIndex = 1;
dataSummary = driving(:, hitIndices, :, :);
fprintf('\nStatistical significance testing for driving\n');
drivingStats = getPairedStatistics(dataSummary, baseIndex, drivingAlgs); 
