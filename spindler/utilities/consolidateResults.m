function [results, dataNames, upperBounds] = consolidateResults(resultsDir, methodNames, metricNames)
%% Consolidate the results for metrics corresponding to methods
%
%  Parameters:
%     

%% Get the data and event file names and check that we have the same number
    resultFiles = getFiles('FILES', resultsDir, '.mat');

%% Create the array of performance values
    results = zeros(length(methodNames), length(metricNames), length(resultFiles));
    upperBounds = zeros(length(methodNames), length(metricNames), length(resultFiles));
    dataNames = cell(length(resultFiles), 1);
    for k = 1:length(resultFiles)
       test = load(resultFiles{k});
       dataNames{k} = test.params.name;
       results(:, :, k) = consolidate(test.metrics, methodNames, metricNames); 
       if isfield(test, 'additionalInfo') && isfield(test.additionalInfo, 'allMetrics')
           upperBounds(:, :, k) = getUpperBound( ...
               test.additionalInfo.allMetrics, methodNames, metricNames);
       end
    end
end

function result = consolidate(metrics, methodNames, metricNames)   
    result = zeros(length(methodNames), length(metricNames));
    if isempty(metrics)
        return;
    end
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

function result = getUpperBound(allMetrics, methodNames, metricNames)   
    result = zeros(length(methodNames), length(metricNames));
    if isempty(allMetrics)
        return;
    end
    
    for k = 1:length(methodNames)
        for j = 1:length(metricNames)
            theseValues = zeros(length(allMetrics), 1);
            for n = 1:length(allMetrics)
                theseValues(n) = allMetrics(n).(methodNames{k}).(metricNames{j});
            end
            result(k, j) = max(theseValues);
        end
    end
end