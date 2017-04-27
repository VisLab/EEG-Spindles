function metrics = getMetricsFromIndices(allMetrics, indices, metricNames, methodNames)


%% Extract the metric values first
numMetrics = length(metricNames);
numMethods = length(methodNames);
metrics = zeros(numMethods, numMetrics);

for j = 1:numMethods
   for k = 1:numMetrics
       indexValue = indices(j, k);
       metrics(j, k) = allMetrics(indexValue).(methodNames{j}).(metricNames{k});
   end
end