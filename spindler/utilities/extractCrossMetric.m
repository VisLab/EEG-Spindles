function [metrics, metricTypes] = extractCrossMetric(crossMetrics, metricName)

metricTypes = {'all', 'first', 'second', 'firstFromSecond', 'secondFromFirst'};
if isempty(crossMetrics)
    metrics = nan;
    return;
end

metrics = nan(length(crossMetrics), 5);
metricPosition = find(strcmpi(crossMetrics(1).metricNames, metricName));
if isempty(metricPosition)
    warning('%s: metric %s could not be extracted', ...
        crossMetrics(1).fileName, metricName);
    return;
end
for k = 1:length(crossMetrics)
    if isnan(crossMetrics(k).valueAll)
        continue;
    end
    metrics(k, 1) = crossMetrics(k).metricsAll(metricPosition);
    metrics(k, 2) = crossMetrics(k).metricsFirst(metricPosition);
    metrics(k, 3) = crossMetrics(k).metricsSecond(metricPosition);
    metrics(k, 4) = crossMetrics(k).metricsFirstFromSecond(metricPosition);
    metrics(k, 5) = crossMetrics(k).metricsSecondFromFirst(metricPosition);
end

x = 3;