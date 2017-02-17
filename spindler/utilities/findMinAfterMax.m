function [xMin, yMin, minPos] = findMinAfterMax(x, y)
% load('test.mat')
% y = xAll;
% x = atomsPerSecond';
% y = median(xAll, 2);

%%
xMin = [];
yMin = [];
minPos = [];
ySlope = diff(y);
maxPos = find(ySlope < 0, 1, 'first');
if isempty(maxPos)
    return;
end
yNewSlope = ySlope(maxPos + 1:end);
if isempty(yNewSlope)
    return;
end
minPos = find(yNewSlope > 0, 1, 'first');
if isempty(minPos)
    return;
end
minPos = maxPos + minPos;
yMin = y(minPos);
xMin = x(minPos);