function [optimalMetrics, optimalIndices] = getOptimalMetrics(allMetrics, metricNames, methodNames)


%% Extract the metric values first
numMetrics = length(metricNames);
numMethods = length(methodNames);
numIndices = length(allMetrics);
metricValues = zeros(numIndices, numMethods, numMetrics);

for n = 1:numIndices
  for j = 1:numMethods
      metrics = allMetrics(n).(methodNames{j});
      for k = 1:numMetrics
          metricValues(n, j, k) = metrics.(metricNames{k});
      end
  end
end

%% Now find the optimal values
optimalMetrics = zeros(numMethods, numMetrics);
optimalIndices = zeros(numMethods, numMetrics);
for j = 1:numMethods
    for k = 1:numMetrics
        values = metricValues(:, j, k);
        [optimalMetrics(j, k), optimalIndices(j, k)] = max(values);
    end
end