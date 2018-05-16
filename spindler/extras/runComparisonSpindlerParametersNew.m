%% Script to consolidate and compare performance results across algorithms
%
%  Written by: Kay Robbins, UTSA, 2017
%
%% Set the masks
maskDreams = true(8, 1);
maskMass = true(19, 1);
maskDreams(7:8) = false;
maskMass([4, 8, 15, 16]) = false;
maskSleep = [maskDreams; maskMass];
noMask = true(27, 1);

%% Set up the parameters
resultsDir = 'D:\TestData\Alpha\spindleData\ResultSummary';
algorithms = {'Spindler', 'Cwt_a7', 'Cwt_a8', 'Sem'};
% datasets = {'massNew'};
% theTitle = 'Mass data';
% datasets = {'dreams'};
% theTitle = 'Dreams data';
datasets = {'dreams', 'massNew'};
theTitle = 'Sleep data';
%theMask = maskSleep;
theMask = noMask;
%% Set the metrics and methods
metricNames = {'f1', 'f2', 'G', 'precision', 'recall', 'fdr'};
methodNames = {'count', 'hit', 'intersect', 'onset', 'time'};   

algColors = [0, 0.7, 0.9; 0, 0, 0.7; 0, 0.6, 0; 0.8, 0.8, 0.2];

%% Read in all of the summary data
numDatasets = length(datasets);
numAlgorithms = length(algorithms);
results = cell(numAlgorithms, numDatasets);
numFiles = 0;
for n = 1:numDatasets
    for k = 1:numAlgorithms
       results{k, n} = load([resultsDir filesep datasets{n} '_' ...
                             algorithms{k} '_Summary.mat']);
    end
    numFiles = numFiles + length(results{k, n}.dataNames);
end

%% Construct dreams summary matrix for plotting
numMethods = length(methodNames);
numMetrics = length(metricNames);
performData = zeros(numFiles, numMethods, numAlgorithms, numMetrics);
posStart = 1;
for n = 1:numDatasets
   posEnd = posStart + size(results{1, n}.results, 3) - 1;
   for k = 1:numAlgorithms  
       theseResults = results{k, n}.results;
       
       for j = 1:numMetrics
          for m = 1:numMethods
               performData(posStart:posEnd, m, k, j) = theseResults(m, j, :);
          end
       end 
   end
   posStart = posEnd + 1;
end

%% Plot the data
for n = 1:numMetrics
    metricName = metricNames{n};
    theseResults = squeeze(performData(:, :, :, n));
    figHan = compareMetric(theseResults, metricName, algorithms, ...
                           algColors, [theTitle ' performance']);
end

%% Perform a paired ttest for statistical significance
fprintf('\nStatistical significance testing for %s\n', theTitle);
stats = getPairedStatistics(performData(:, :, :, 1:5), 1, algorithms, metricNames(1:5), methodNames); 

%% For metrics and methods individually
for k = 1:numMetrics
   stats = getPairedStatistics(performData(theMask, :, :, k), 1, algorithms, ...
                               metricNames(k), methodNames);
   for n = 1:numMethods
         stats = getPairedStatistics(performData(theMask, n, :, k), 1, algorithms, ...
                               metricNames(k), methodNames(n));
   end
end