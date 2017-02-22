function [xMax, yMax, maxPos] = findMaxAfterMin(x, y)
% load('test.mat')
% y = xAll;
% x = atomsPerSecond';
% y = median(xAll, 2);

%%
xMax = [];
yMax = [];
maxPos = [];
ySlope = diff(y);
minPos = find(ySlope > 0, 1, 'first');
if isempty(minPos)
    return;
end
yNewSlope = ySlope(minPos + 1:end);
if isempty(yNewSlope)
    return;
end
maxPos = find(yNewSlope < 0, 1, 'first');
if isempty(maxPos)
    return;
end
maxPos = maxPos + minPos;
yMax = y(maxPos);
xMax = x(maxPos);