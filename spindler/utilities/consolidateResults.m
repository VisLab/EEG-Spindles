function [results, dataNames] = consolidateResults(resultsDir, methodNames, metricNames)
%% Consolidate the results for metrics corresponding to methods
%
%  Parameters:
%     

%% Get the data and event file names and check that we have the same number
    resultFiles = getFiles('FILES', resultsDir, '.mat');

%% Create the array of performance values
    results = zeros(length(methodNames), length(metricNames), length(resultFiles));
    dataNames = cell(length(resultFiles), 1);
    for k = 1:length(resultFiles)
       test = load(resultFiles{k});
       dataNames{k} = test.params.name;
       results(:, :, k) = consolidate(test.metrics, methodNames, metricNames); 
    end
end

function result = consolidate(metrics, methodNames, metricNames)
    
    result = zeros(length(methodNames), length(metricNames));
    for k = 1:length(methodNames)
        thisMetric = metrics.(methodNames{k});
        if isempty(thisMetric)
            continue;
        end
        for j = 1:length(metricNames)
            result(k, j) = thisMetric.(metricNames{j});
        end
    end
end