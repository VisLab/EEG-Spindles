function [xMax, yMax, maxPos] = findMaxAfterMin(x, y)
%% Find the first local maximum after the first local minimum
%
%  Parameters:
%    x      Vector of x values
%    y      Vector of y values
%    xMax   (Output) x value of the local maximum
%    yMax   (Output) y value of the local maximum
%    maxPos (Output) index of the local maximum
%
% Written by:  Kay Robbins, UTSA, 2017

%% Initialize the values
xMax = [];
yMax = [];
maxPos = [];

%% Calculate the values
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