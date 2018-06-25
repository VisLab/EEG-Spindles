function metrics = getMetric(allMetrics, metricName)

%% Extract the values to plot
[size1, size2] = size(allMetrics);
countMetric = zeros(size1, size2);
hitMetric = zeros(size1, size2);
intersectMetric = zeros(size1, size2);
onsetMetric = zeros(size1, size2);
timeMetric = zeros(size1, size2);

for k = 1:size1
    for j = 1:size2
        countMetric(k, j) = allMetrics(k, j).count.(metricName);
        hitMetric(k, j) = allMetrics(k, j).hit.(metricName);
        intersectMetric(k, j) = allMetrics(k, j).intersect.(metricName);
        onsetMetric(k, j) = allMetrics(k, j).onset.(metricName);
        timeMetric(k, j) = allMetrics(k, j).time.(metricName);
    end
end

metrics.count = countMetric;
metrics.hit = hitMetric;
metrics.intersect = intersectMetric;
metrics.onset = onsetMetric;
metrics.time = timeMetric;