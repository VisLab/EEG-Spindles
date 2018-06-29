function metric = getMetric(allMetrics, methodName, metricName)
%% Extract an array of metric values from an allMetrics structure
%
% 
[size1, size2] = size(allMetrics);
metric = zeros(size1, size2);

for k = 1:size1
    for j = 1:size2
        metric(k, j) = allMetrics(k, j).(methodName).(metricName);
    end
end
