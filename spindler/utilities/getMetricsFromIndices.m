function metrics = getMetricsFromIndices(allMetrics, indices, metricNames, methodNames)


%% Extract the metric values first
numMetrics = length(metricNames);
numMethods = length(methodNames);
metrics = zeros(numMetrics, numMethods);

for j = 1:numMethods
   for k = 1:numMetrics
       indexValue = indices(k, j);
       metrics(k, j) = allMetrics(indexValue).(methodNames{j}).(metricNames{k});
   end
end