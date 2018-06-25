
%% Now consolidate the events for the collection and create a summary
[results, dataNames, upperBounds] = ...
                  consolidateResults(resultsDir, paramsInit.metricNames);

%% Save the results
metricNames = params.metricNames;
save(summaryFile, 'results', 'dataNames', 'metricNames', 'upperBounds', '-v7.3');
