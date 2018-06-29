function [optimalValue, optimalIndices] = getMetricOptimal(metric)


[b, indx2] = max(metric, [], 2);
[optimalValue, indx1] = max(b);
optimalIndices = [indx1, indx2(indx1)];