function [optimalMetrics, optimalIndices] = getOptimalMetrics(allMetrics, metricNames, methodNames)


%% Extract the metric values first
numMetrics = length(metricNames);
numMethods = length(methodNames);
numIndices = length(allMetrics);
metricValues = zeros(numIndices, numMetrics, numMethods);

for n = 1:numIndices
  for j = 1:numMethods
      metrics = allMetrics(n).(methodNames{j});
      for k = 1:numMetrics
          metricValues(n, k, j) = metrics.(metricNames{k});
      end
  end
end

%% Now find the optimal values
optimalMetrics = zeros(numMetrics, numMethods);
optimalIndices = zeros(numMetrics, numMethods);
for j = 1:numMethods
    for k = 1:numMetrics
        values = metricValues(:, k, j);
        [optimalMetrics(k, j), optimalIndices(k, j)] = max(values);
    end
end