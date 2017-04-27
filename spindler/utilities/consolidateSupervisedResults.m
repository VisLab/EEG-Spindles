function [results, dataNames, upperBounds] = ...
   consolidateSupervisedResults(supervisedResultsDir, methodNames, metricNames)
%% Consolidate the results for metrics corresponding to methods
%
%  Parameters:
%     

%% Get the data and event file names and check that we have the same number
    resultFiles = getFiles('FILES', supervisedResultsDir, '.mat');
    numFiles = length(resultFiles);
    
%% Create the array of performance values
    results = zeros(length(methodNames), length(metricNames), 2*numFiles);
    upperBounds = zeros(length(methodNames), length(metricNames), 2*numFiles);
    dataNames = cell(2*numFiles, 1);
    for k = 1:numFiles
       test = load(resultFiles{k});
       dataNames{k} = test.params1.name;
       dataNames{numFiles + k} = test.params2.name;
       results(:, :, k) = test.supervisedMetrics1; 
       upperBounds(:, :, k) = test.optimalMetrics1;
       results(:, :, numFiles + k) = test.supervisedMetrics2; 
       upperBounds(:, :, numFiles + k) = test.optimalMetrics2;
    end
end
